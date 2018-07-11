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

## skin:register(key)
Register the skin object in player_api with skin key

## skin:set_textures(textures)
Set the skin textures table - usually at the init time only

## skin:get_textures()
Get the skin textures for any reason. Note to apply them the skin:set_skin() should be used

Could be redefined for dynamic texture generation

## skin:set_preview(texture)
Set the skin preview - usually at the init time only

## skin:get_preview()
Get the skin preview

Could be redefined for dynamic preview texture generation

## skin:set_skin(player)
Hook for dynamic skins updates on select. Is called in skins.set_player_skin()
In skinsdb the default implementation for this function is empty.


## skin:set_meta(key, value)
Add a meta information to the skin object

Note: the information is not stored, therefore should be filled each time during skins registration

## skin:get_meta(key)
The next metadata keys are filled or/and used interally in skinsdb framework
  - name - A name for the skin
  - author - The skin author
  - license - THe skin texture license
  - assignment - (obsolete) is "player:playername" in case the skin is assigned to be privat for a player
  - playername - Player assignment for private skin. Set false for skins not usable by all players (like NPC-Skins), true or nothing for all player skins
  - in_inventory_list - If set to false the skin is not visible in inventory skins selection but can be still applied to the player
  - _sort_id - Thi skins lists are sorted by this field for output (internal key)

## skin:get_meta_string(key)
Same as get_meta() but does return "" instead of nil if the meta key does not exists

## skin:is_applicable_for_player(playername)
Returns whether this skin is applicable for player "playername" or not, like private skins
