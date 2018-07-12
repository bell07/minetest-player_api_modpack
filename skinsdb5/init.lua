-- Rework 2018 by bell07
-- License: GPLv3

skinsdb5 = {}
local modpath = minetest.get_modpath(minetest.get_current_modname())
skinsdb5.modpath = modpath

local S
if minetest.get_modpath("intllib") then
	skinsdb5.S = intllib.Getter()
else
	skinsdb5.S = function(s) return s end
end

dofile(skinsdb5.modpath.."/skin_meta_api.lua")
dofile(modpath.."/skinlist.lua")
dofile(modpath.."/formspecs.lua")
dofile(modpath.."/chatcommands.lua")
-- Unified inventory page/integration
if minetest.get_modpath("unified_inventory") then
	dofile(modpath.."/unified_inventory_page.lua")
end

if minetest.get_modpath("sfinv") then
	dofile(modpath.."/sfinv_page.lua")
end

-- Update skin on join
skinsdb5.ui_context = {}
minetest.register_on_leaveplayer(function(player)
	skinsdb5.ui_context[player:get_player_name()] = nil
end)

-- Read current mod textures- and meta- folder
skinsdb5.read_textures_and_meta()

player_api.register_on_skin_change(function(player, model_name, skin_name)
	if minetest.global_exists("sfinv") and sfinv.enabled then
		sfinv.set_player_inventory_formspec(player)
	end
end)
