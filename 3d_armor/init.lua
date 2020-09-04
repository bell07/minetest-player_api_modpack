local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()
local last_punch_time = {}
local timer = 0

dofile(modpath.."/api.lua")

-- local functions
local F = minetest.formspec_escape
local S = armor.get_translator

-- integration test
if minetest.settings:get_bool("enable_3d_armor_integration_test") then
        dofile(modpath.."/integration_test.lua")
end


-- Legacy Config Support

local input = io.open(modpath.."/armor.conf", "r")
if input then
	dofile(modpath.."/armor.conf")
	input:close()
end
input = io.open(worldpath.."/armor.conf", "r")
if input then
	dofile(worldpath.."/armor.conf")
	input:close()
end
for name, _ in pairs(armor.config) do
	local global = "ARMOR_"..name:upper()
	if minetest.global_exists(global) then
		armor.config[name] = _G[global]
	end
end
if minetest.global_exists("ARMOR_MATERIALS") then
	armor.materials = table.copy(ARMOR_MATERIALS)
end
if minetest.global_exists("ARMOR_FIRE_NODES") then
	armor.fire_nodes = table.copy(ARMOR_FIRE_NODES)
end

-- Load Configuration

for name, config in pairs(armor.config) do
	local setting = minetest.settings:get("armor_"..name)
	if type(config) == "number" then
		setting = tonumber(setting)
	elseif type(config) == "boolean" then
		setting = minetest.settings:get_bool("armor_"..name)
	end
	if setting ~= nil then
		armor.config[name] = setting
	end
end
for material, _ in pairs(armor.materials) do
	local key = "material_"..material
	if armor.config[key] == false then
		armor.materials[material] = nil
	end
end

-- Skin modifier

player_api.register_skin_modifier(function(textures, player, player_model, player_skin)
	local name = player:get_player_name()
	local player_armor = armor.textures[name] and armor.textures[name].armor
	if textures.armor and player_armor then
		textures.armor = textures.armor..'^'..player_armor
	else
		textures.armor = textures.armor or player_armor or "blank.png"
	end
end)

-- Mod Compatibility

if minetest.get_modpath("technic") then
	armor.formspec = armor.formspec..
		"label[5,2.5;"..F(S("Radiation"))..":  armor_group_radiation]"
	armor:register_armor_group("radiation")
end
if not minetest.get_modpath("moreores") then
	armor.materials.mithril = nil
end
if not minetest.get_modpath("ethereal") then
	armor.materials.crystal = nil
end

dofile(modpath.."/armor.lua")

-- Armor Initialization

armor.formspec = armor.formspec..
	"label[5,1;"..F(S("Level"))..": armor_level]"..
	"label[5,1.5;"..F(S("Heal"))..":  armor_attr_heal]"
if armor.config.fire_protect then
	armor.formspec = armor.formspec.."label[5,2;"..F(S("Fire"))..":  armor_attr_fire]"
end

armor:register_on_damage(function(player, index, stack)
	local name = player:get_player_name()
	local def = stack:get_definition()
	if name and def and def.description and stack:get_wear() > 60100 then
		minetest.chat_send_player(name, S("Your @1 is almost broken!", def.description))
		minetest.sound_play("default_tool_breaks", {to_player = name, gain = 2.0})
	end
end)

armor:register_on_destroy(function(player, index, stack)
	local name = player:get_player_name()
	local def = stack:get_definition()
	if name and def and def.description then
		minetest.chat_send_player(name, S("Your @1 got destroyed!", def.description))
		minetest.sound_play("default_tool_breaks", {to_player = name, gain = 2.0})
	end
end)

local function validate_armor_inventory(player)
	-- Workaround for detached inventory swap exploit
	local _, inv = armor:get_valid_player(player, "[validate_armor_inventory]")
	local pos = player:get_pos()
	if not inv then
		return
	end
	local armor_prev = {}
	local attribute_meta = player:get_meta() -- I know, the function's name is weird but let it be like that. ;)
	local armor_list_string = attribute_meta:get_string("3d_armor_inventory")
	if armor_list_string then
		local armor_list = armor:deserialize_inventory_list(armor_list_string)
		for i, stack in ipairs(armor_list) do
			if stack:get_count() > 0 then
				armor_prev[stack:get_name()] = i
			end
		end
	end
	local elements = {}
	local player_inv = player:get_inventory()
	for i = 1, 6 do
		local stack = inv:get_stack("armor", i)
		if stack:get_count() > 0 then
			local item = stack:get_name()
			local element = armor:get_element(item)
			if element and not elements[element] then
				if armor_prev[item] then
					armor_prev[item] = nil
				else
					-- Item was not in previous inventory
					armor:run_callbacks("on_equip", player, i, stack)
				end
				elements[element] = true;
			else
				inv:remove_item("armor", stack)
				minetest.item_drop(stack, player, pos)
				-- The following code returns invalid items to the player's main
				-- inventory but could open up the possibity for a hacked client
				-- to receive items back they never really had. I am not certain
				-- so remove the is_singleplayer check at your own risk :]
				if minetest.is_singleplayer() and player_inv and
						player_inv:room_for_item("main", stack) then
					player_inv:add_item("main", stack)
				end
			end
		end
	end
	for item, i in pairs(armor_prev) do
		local stack = ItemStack(item)
		-- Previous item is not in current inventory
		armor:run_callbacks("on_unequip", player, i, stack)
	end
end

local function init_player_armor(initplayer)
	local name = initplayer:get_player_name()
	local pos = initplayer:get_pos()
	if not name or not pos then
		return false
	end
	local armor_inv = minetest.create_detached_inventory(name.."_armor", {
		on_put = function(inv, listname, index, stack, player)
			validate_armor_inventory(player)
			armor:save_armor_inventory(player)
			armor:set_player_armor(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			validate_armor_inventory(player)
			armor:save_armor_inventory(player)
			armor:set_player_armor(player)
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			validate_armor_inventory(player)
			armor:save_armor_inventory(player)
			armor:set_player_armor(player)
		end,
		allow_put = function(inv, listname, index, put_stack, player)
			local element = armor:get_element(put_stack:get_name())
			if not element then
				return 0
			end
			for i = 1, 6 do
				local stack = inv:get_stack("armor", i)
				local def = stack:get_definition() or {}
				if def.groups and def.groups["armor_"..element]
						and i ~= index then
					return 0
				end
			end
			return 1
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return count
		end,
	}, name)
	armor_inv:set_size("armor", 6)
	if not armor:load_armor_inventory(initplayer) and armor.migrate_old_inventory then
		local player_inv = initplayer:get_inventory()
		player_inv:set_size("armor", 6)
		for i=1, 6 do
			local stack = player_inv:get_stack("armor", i)
			armor_inv:set_stack("armor", i, stack)
		end
		armor:save_armor_inventory(initplayer)
		player_inv:set_size("armor", 0)
	end
	for i=1, 6 do
		local stack = armor_inv:get_stack("armor", i)
		if stack:get_count() > 0 then
			armor:run_callbacks("on_equip", initplayer, i, stack)
		end
	end
	armor.def[name] = {
		init_time = minetest.get_gametime(),
		level = 0,
		state = 0,
		count = 0,
		groups = {},
	}
	for _, phys in pairs(armor.physics) do
		armor.def[name][phys] = 1
	end
	for _, attr in pairs(armor.attributes) do
		armor.def[name][attr] = 0
	end
	for group, _ in pairs(armor.registered_groups) do
		armor.def[name].groups[group] = 0
	end
	armor.textures[name] = {}
end

local orig_init_on_joinplayer = player_api.init_on_joinplayer
function player_api.init_on_joinplayer(player)
	init_player_armor(player)
	orig_init_on_joinplayer(player)
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	armor.def[name] = nil
	armor.textures[name] = nil
end)

if armor.config.drop == true or armor.config.destroy == true then
	minetest.register_on_dieplayer(function(player)
		local name, armor_inv = armor:get_valid_player(player, "[on_dieplayer]")
		if not name then
			return
		end
		local drop = {}
		for i=1, armor_inv:get_size("armor") do
			local stack = armor_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				table.insert(drop, stack)
				armor:run_callbacks("on_unequip", player, i, stack)
				armor_inv:set_stack("armor", i, nil)
			end
		end
		armor:save_armor_inventory(player)
		armor:set_player_armor(player)
		local pos = player:get_pos()
		if pos and armor.config.destroy == false then
			minetest.after(armor.config.bones_delay, function()
				local meta = nil
				local maxp = vector.add(pos, 16)
				local minp = vector.subtract(pos, 16)
				local bones = minetest.find_nodes_in_area(minp, maxp, {"bones:bones"})
				for _, p in pairs(bones) do
					local m = minetest.get_meta(p)
					if m:get_string("owner") == name then
						meta = m
						break
					end
				end
				if meta then
					local inv = meta:get_inventory()
					for _,stack in ipairs(drop) do
						if inv:room_for_item("main", stack) then
							inv:add_item("main", stack)
						else
							armor.drop_armor(pos, stack)
						end
					end
				else
					for _,stack in ipairs(drop) do
						armor.drop_armor(pos, stack)
					end
				end
			end)
		end
	end)
end

if armor.config.punch_damage == true then
	minetest.register_on_punchplayer(function(player, hitter,
			time_from_last_punch, tool_capabilities)
		local name = player:get_player_name()
		if name then
			armor:punch(player, hitter, time_from_last_punch, tool_capabilities)
			last_punch_time[name] = minetest.get_gametime()
		end
	end)
end

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if player and reason.type ~= "drown" and reason.hunger == nil
			and hp_change < 0 then
		local name = player:get_player_name()
		if name then
			local heal = armor.def[name].heal
			if heal >= math.random(100) then
				hp_change = 0
			end
			-- check if armor damage was handled by fire or on_punchplayer
			local time = last_punch_time[name] or 0
			if time == 0 or time + 1 < minetest.get_gametime() then
				armor:punch(player)
			end
		end
	end
	return hp_change
end, true)

-- Fire Protection and water breathing, added by TenPlus1.

if armor.config.fire_protect == true then
	-- override hot nodes so they do not hurt player anywhere but mod
	for _, row in pairs(armor.fire_nodes) do
		if minetest.registered_nodes[row[1]] then
			minetest.override_item(row[1], {damage_per_second = 0})
		end
	end
else
	print (S("[3d_armor] Fire Nodes disabled"))
end

if armor.config.water_protect == true or armor.config.fire_protect == true then
	minetest.register_globalstep(function(dtime)
		armor.timer = armor.timer + dtime
		if armor.timer < armor.config.update_time then
			return
		end
		for _,player in pairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local pos = player:get_pos()
			local hp = player:get_hp()
			if not name or not pos or not hp then
				return
			end
			-- water breathing
			if armor.config.water_protect == true then
				if armor.def[name].water > 0 and
						player:get_breath() < 10 then
					player:set_breath(10)
				end
			end
			-- fire protection
			if armor.config.fire_protect == true then
				local fire_damage = true
				pos.y = pos.y + 1.4 -- head level
				local node_head = minetest.get_node(pos).name
				pos.y = pos.y - 1.2 -- feet level
				local node_feet = minetest.get_node(pos).name
				-- is player inside a hot node?
				for _, row in pairs(armor.fire_nodes) do
					-- check fire protection, if not enough then get hurt
					if row[1] == node_head or row[1] == node_feet then
						if fire_damage == true then
							armor:punch(player, "fire")
							last_punch_time[name] = minetest.get_gametime()
							fire_damage = false
						end
						if hp > 0 and armor.def[name].fire < row[2] then
							hp = hp - row[3] * armor.config.update_time
							player:set_hp(hp)
							break
						end
					end
				end
			end
		end
		armor.timer = 0
	end)
end

-- Update the armor
player_api.register_on_skin_change(function(player, model_name, skin_name)
	armor:set_player_armor(player)
end)
