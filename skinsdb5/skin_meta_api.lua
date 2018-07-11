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
	self._sort_id = 0
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
function skin_class:register(name)
	player_api.register_skin(name, self)
end

function skin_class:set_meta(key, value)
	self[key] = value
end

function skin_class:get_meta(key)
	return self[key]
end

function skin_class:get_meta_string(key)
	return tostring(self:get_meta(key) or "")
end

function skin_class:set_texture(value)
	self.textures = value
end

function skin_class:get_texture()
	if type(self.textures) == 'string' then
		return self.textures
	else
		return table.concat(self.textures, "^")
	end
end

function skin_class:set_preview(value)
	self._preview = value
end

function skin_class:get_preview()
	return self._preview or "player.png"
end

function skin_class:set_skin(player)
	player_api.set_skin(player, self._key)
end

function skin_class:is_applicable_for_player(playername)
	local assigned_player = self:get_meta("playername")
	return assigned_player == nil or assigned_player == true or
			(assigned_player:lower() == playername:lower())
end
