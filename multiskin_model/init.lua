player_api.default_model = "multiskin_model.b3d"

local function concat_texture(base, ext)
	if base == "blank.png" or base == "" or base == nil then
		return ext
	elseif ext == "blank.png" then
		return base
	else
		return base .. "^" .. ext
	end
end


player_api.register_model("multiskin_model.b3d", {
	animation_speed = 30,
	textures = {
		"blank.png", -- V1.0 Skin
		"blank.png", -- V1.8 Skin
		"blank.png", -- Armor
		"blank.png"  -- Wielded item
	},
	animations = {
		stand = {x=0, y=79},
		lay = {x=162, y=166},
		walk = {x=168, y=187},
		mine = {x=189, y=198},
		walk_mine = {x=200, y=219},
		sit = {x=81, y=160},
	},
	skin_modifier = function(model, textures, player)
		if #textures < 4 then
			-- fill up with blanks
			for i = #textures, 4 do
				table.insert(textures, "blank.png")
			end
		end
		if textures.cape then
			textures[1] = concat_texture(textures[1], textures.cape)
			textures.cape = nil
		end
		if textures.clothing then
			textures[2] = concat_texture(textures[2], textures.clothing)
			textures.clothing = nil
		end
		if textures.wielditem then
			textures[4] = textures.wielditem or textures[4]
			textures.wielditem = nil
		end
	end,
})

player_api.register_skin_modifier(function(textures, player, player_model, player_skin)
	if player_model ~= "multiskin_model.b3d" then
		return
	end
	if player_api.registered_skins[player_skin].format == '1.8' then
		table.insert(textures, 1, nil)
	end
end)
