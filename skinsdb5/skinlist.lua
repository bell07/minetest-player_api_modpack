function skinsdb5.read_textures_and_meta()
	local modpath = minetest.get_modpath(minetest.get_current_modname())
	local skins_dir_list = minetest.get_dir_list(modpath..'/textures/')
	for _, fn in pairs(skins_dir_list) do
		local nameparts = string.gsub(fn, "[.]", "_"):split("_")

		local name, sort_id, is_preview, playername
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
			local skin_obj = player_api.registered_skins[name]
			if not skin_obj then
				skin_obj = {}
				player_api.register_skin(name, skin_obj)
			end
			if is_preview then
				skin_obj.preview = fn
			else
				skin_obj.sort_id = sort_id
				skin_obj.texture = fn
				if playername then
					skin_obj.playername = playername
				end
				if minetest.global_exists("multiskin_model") then
					local file = io.open(modpath.."/textures/"..fn, "r")
					skin_obj.format = multiskin_model.get_skin_format(file)
					file:close()
				end
			end
		end
	end

	local meta_dir_list = minetest.get_dir_list(modpath..'/meta/')
	for _, fn in pairs(meta_dir_list) do
		if fn:sub(-4):lower() == '.txt' then
			local skin_name = fn:lower():sub(1,-5) --cut .txt
			local skin_obj = player_api.registered_skins[skin_name]
			if skin_obj then
				local file = io.open(modpath.."/meta/"..fn, "r")
				if file then
					local data = string.split(file:read("*all"), "\n", 3)
					file:close()
					skin_obj.description = data[1]
					skin_obj.author = data[2]
					skin_obj.license = data[3]
				end
			end
		end
	end
end

-- Get skinlist for player. If no player given, public skins only selected
function skinsdb5.get_skinlist_for_player(playername)
	local skinslist = {}
	for _, skin in pairs(player_api.registered_skins) do
		if skin.in_inventory_list ~= false and
				(not skin.playername or (playername and skin.playername:lower() == playername:lower())) then
			table.insert(skinslist, skin)
		end
	end
	table.sort(skinslist, function(a,b) return tostring(a.sort_id or
			a.description or a.name or "") < tostring(b.sort_id or b.description or b.name or "") end)
	return skinslist
end

-- Get skinlist selected by metadata
function skinsdb5.get_skinlist_with_meta(key, value)
	assert(key, "key parameter for skinsdb5.get_skinlist_with_meta() missed")
	local skinslist = {}
	for _, skin in pairs(player_api.registered_skins) do
		if skin[key] == value then
			table.insert(skinslist, skin)
		end
	end
	table.sort(skinslist, function(a,b) return (tostring(a.sort_id) or
			a.description or a.name or "") < (tostring(b.sort_id) or b.description or b.name or "") end)
	return skinslist
end
