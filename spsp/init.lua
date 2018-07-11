-- Load the skins
local skins_dir_list = minetest.get_dir_list(minetest.get_modpath("spsp").."/textures")
for _, fn in pairs(skins_dir_list) do
	local skin_name = fn:lower():sub(1,-5) --cut .PNG
	player_api.register_skin(skin_name, {
		textures = fn,
	})
end

-- Override the player_api hook
local player_api_get_skin = player_api.get_skin
function player_api.get_skin(player)
	local assigned_skin, is_default = player_api_get_skin(player)
	if is_default then
		local name = player:get_player_name()
		local player_skin = "player_"..name:lower()
		if player_api.registered_skins[player_skin] then
			assigned_skin = player_skin
		end
	end
	return assigned_skin, is_default
end


minetest.register_chatcommand("skin", {
	params = "list | set <playername> <skin key>",
	description = "list or set skin for a player",
	privs = {server = true},
	func = function(name, param)
		-- parse command line
		local words = param:split(" ")
		local command = words[1]
		if command == "list" then
			local list_sorted = {}
			for skin_key, _ in pairs(player_api.registered_skins) do
				table.insert(list_sorted, skin_key)
			end
			table.sort(list_sorted)
			for _, skin_key in ipairs(list_sorted) do
				minetest.chat_send_player(name, skin_key)
			end
		elseif command == "set" then
			local playername = words[2]
			local selected_skin = words[3]
			if not playername or not selected_skin then
				return false, "skin set requires player and skin key"
			end
			local player = minetest.get_player_by_name(playername)
			if not player then
				return false, "player "..playername.." unknown or offline"
			end
			if not player_api.registered_skins[selected_skin] then
				return false, "invalid skin "..selected_skin..". try /skin list"
			end
			player_api.set_skin(player, selected_skin)
		else
			return false, "parameter required. see /help skin"
		end
	end
})
