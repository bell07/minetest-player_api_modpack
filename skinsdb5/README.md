# skinsdb5

This Minetest mod offers changeable player skins with a graphical interface for multiple inventory mods.

## Features

- player_api Skins management compatible, as proposed for minetest_game-0.5
- Download scripts included for the [Minetest skin database](http://minetest.fensta.bplaced.net)
- Flexible skins API to manage the database
- Skin change menu for sfinv (in minetest_game) and [unified_inventory](https://forum.minetest.net/viewtopic.php?t=12767)
- Own skin change menu and command line using chat command /skinsdb (set | show | list | list private | list public | ui)
- Skin previews supported in selection
- Additional information for each skin
- Support for different skins lists: public and a per-player list are currently implemented
- Compatible to 1.0 and 1.8 Minecraft skins format

## Update tools

In order to download the skins from the skin database,
you may use one of the listed update tools below.
They are located in the `updater/` directory.

- `update_skins_db.sh` bash and jq required
- `update_from_db.py` python3 required
- `MT_skins_updater.*` windows or mono (?) required


## License

If nothing else is specified, it is licensed as GPLv3.

Fritigern:
  - update_skins_db.sh (CC-BY-NC-SA 4.0)

### Credits

- RealBadAngel (unified_inventory)
- Zeg9 (skinsdb)
- cornernote (source code)
- Krock (source code)
- bell07 (source code)
- stujones11 (player models)
