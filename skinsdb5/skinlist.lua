-- Check Skin format (code stohlen from stu's multiskin)
function skinsdb5.get_skin_format(file)
	file:seek("set", 1)
	if file:read(3) == "PNG" then
		file:seek("set", 16)
		local ws = file:read(4)
		local hs = file:read(4)
		local w = ws:sub(3, 3):byte() * 256 + ws:sub(4, 4):byte()
		local h = hs:sub(3, 3):byte() * 256 + hs:sub(4, 4):byte()
		if w >= 64 then
			if w == h then
				return "1.8"
			elseif w == h * 2 then
				return "1.0"
			end
		end
	end
end

function skinsdb5.read_textures_and_meta()
	local modpath = minetest.get_modpath(minetest.get_current_modname())
	local skins_dir_list = minetest.get_dir_list(modpath..'/textures/')
	for _, fn in pairs(skins_dir_list) do
		local nameparts = string.gsub(fn, "[.]", "_"):split("_")

		local name, sort_id, assignment, is_preview, playername
		if nameparts[1] == "character" then
			sort_id = 5000
			if nameparts[2] == "preview" then
				name = "character"
				is_preview = true
			elseif not nameparts[2] then
				name = "character"
			elseif tonumber(nameparts[2]) then
				sort_id = sort_id + tonumber(nameparts[2])
				name = "character_"..nameparts[2]
				is_preview = (nameparts[3] == "preview")
			else
				name = nameparts[2]
				is_preview = (nameparts[3] == "preview")
			end
		elseif nameparts[1] == "player" then
			assignment = "player:"..nameparts[2] --TODO: remove all assignment handling
			name = "player_"..nameparts[2]
			playername = nameparts[2]
			if tonumber(nameparts[3]) then
				sort_id = tonumber(nameparts[3])
				is_preview = (nameparts[4] == "preview")
				name = name.."_"..nameparts[3]
			else
				sort_id = 1
				is_preview = (nameparts[3] == "preview")
			end
		end

		if name then
			local skin_obj = skinsdb5.get(name)
			if not skin_obj then
				skin_obj = skinsdb5.new()
				skin_obj:register(name)
			end
			if is_preview then
				skin_obj:set_preview(fn)
			else
				skin_obj:set_meta("_sort_id", sort_id)
				if playername then
					skin_obj:set_meta("playername", playername)
				end
				local file = io.open(modpath.."/textures/"..fn, "r")
				local skinformat = skinsdb5.get_skin_format(file)
				skin_obj:set_meta("format", skinformat)
				skin_obj:set_texture(fn)

				file:close()
				skin_obj:set_meta("name", name)
			end
		end
	end

	local meta_dir_list = minetest.get_dir_list(modpath..'/meta/')
	for _, fn in pairs(meta_dir_list) do
		if fn:sub(-4):lower() == '.txt' then
			local skin_name = fn:lower():sub(1,-5) --cut .txt
			local skin_obj = skinsdb5.get(skin_name)
			if skin_obj then
				local file = io.open(modpath.."/meta/"..fn, "r")
				if file then
					local data = string.split(file:read("*all"), "\n", 3)
					file:close()
					skin_obj:set_meta("name", data[1])
					skin_obj:set_meta("author", data[2])
					skin_obj:set_meta("license", data[3])
				end
			end
		end
	end
end

-- Get skinlist for player. If no player given, public skins only selected
function skinsdb5.get_skinlist_for_player(playername)
	local skinslist = {}
	for _, skin in pairs(player_api.registered_skins) do
		if not skin.__index then
			skin = skinsdb5.new(skin)
		end
		if skin:is_applicable_for_player(playername) and skin:get_meta("in_inventory_list") ~= false then
			table.insert(skinslist, skin)
		end
	end
	table.sort(skinslist, function(a,b) return a:get_meta("_sort_id") < b:get_meta("_sort_id") end)
	return skinslist
end

-- Get skinlist selected by metadata
function skinsdb5.get_skinlist_with_meta(key, value)
	assert(key, "key parameter for skinsdb5.get_skinlist_with_meta() missed")
	local skinslist = {}
	for _, skin in pairs(player_api.registered_skins) do
		if not skin.__index then
			skin = skinsdb5.new(skin)
		end
		if skin:get_meta(key) == value then
			table.insert(skinslist, skin)
		end
	end
	table.sort(skinslist, function(a,b) return a:get_meta("_sort_id") < b:get_meta("_sort_id") end)
	return skinslist
end
