local skin_class = {}
skin_class.__index = skin_class
skinsdb5.skin_class = skin_class
-----------------------
-- Class methods
-----------------------
-- constructor
function skinsdb5.new(object)
	local self = object or {}
	setmetatable(self, skin_class)
	self.__index = skin_class
	return self
end

-- getter / convert to skinsdb object format
function skinsdb5.get(key)
	local skin = player_api.registered_skins[key]
	if skin then
		if not skin.__index then
			skin = skinsdb5.new(skin)
		end
		return skin
	end
end

-- Skin methods
-- In this implementation it is just access to attrubutes wrapped
-- but this way allow to redefine the functionality for more complex skins provider
function skin_class:get_texture()
	if self.texture == 'string' then
		return self.texture
	elseif self.textures then
		return table.concat(self.textures, "^")
	end
end

function skin_class:set_skin(player)
	player_api.set_skin(player, self._key)
end

function skin_class:is_applicable_for_player(playername)
	local assigned_player = self.playername
	return assigned_player == nil or assigned_player == true or
			(assigned_player:lower() == playername:lower())
end
