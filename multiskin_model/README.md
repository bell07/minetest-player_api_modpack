# Minetest multiskin_model mod

Register and replace the default model in minetest game trough player_api.

The model does support Skins-Format 1.0 and 1.8. 
To get it working the 1.8er Skins needs to have the "format" attribute set to "1.8"
To check the skin format the provided function can be used

```
	local file = io.open(modpath.."/textures/"..filename, "r")
	skin.format = multiskin_model.get_skin_format(file)
	file:close()
```

The model support does additionan skin modifiers
```
player_api.register_skin_modifier(function(textures, player, player_model, player_skin)
	textures.cape = "cape.png"
	textures.clothing = "clothing.png"
	textures.wielditem = "wielded_item.png"
end
```
