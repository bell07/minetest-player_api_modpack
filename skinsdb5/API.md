# Skinsdb Interface

## skinsdb5.read_textures_and_meta()
Read the textures folder and register all files found as skins. Include corresponding metadata from meta folder
- Use the same functionaltiy as in skinsdb5 for other mods providing skins

## skinsdb5.get_skin_format(file)
Returns the skin format version ("1.0" or "1.8"). File is an open file handle to the texture file

## skinsdb5.get_skinlist_for_player(playername)
Get all allowed skins for player. All public and all player's private skins. If playername not given only public skins returned

## skinsdb5.get_skinlist_with_meta(key, value)
Get all skins with metadata key is set to value. Example:
skinsdb5.get_skinlist_with_meta("playername", playername) - Get all private skins (w.o. public) for playername


## skinsdb5.new(object)
Create a new skin object for given key (Setup object methods)
  - object: Optional. Could be a prepared object. If nothing given a new object is created

## skinsdb5.get(key)
Get object for already registered skin


# Skin object

## skin:get_texture()
Get the raw skin texture for any reason. Note to apply them the skin:set_skin() should be used

## skin:set_skin(player)
Hook for dynamic skins updates on select. Is called in skins.set_player_skin()
In skinsdb the default implementation for this function is empty.

## skin:is_applicable_for_player(playername)
Returns whether this skin is applicable for player "playername" or not, like private skins
