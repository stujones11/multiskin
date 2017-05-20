[mod] Multiskin [multiskin] [0.1.1]
===================================

**Minetest Version:** 0.4.16

**Depends:** default

Adds per-player support for version 1.8 minecraft skins.

On its own this mod acts as a replacement for the out-dated player_textures
mod by PilzAdam. Individual player textures can be placed in the mod's
textures directory and will be automatically assigned to a player by naming
the texture file as `player_<player_name>.png`

This mod also supports the following skin-switching mods which can be used
in conjuction with the multiskin default skins and chat commands.
```
[mod] Skins [skins] by Zeg9
[mod] Simple Skins [simple_skins] by TenPlus1
[mod] Unified Skins [u_skins] by SmallJoker
[mod] Wardrobe [wardrobe] by prestidigitator
```
Note that auto skin format detection is only available for these mods if
the multiskin mod is listed in the `secure.trusted_mods` setting.

Configuration
-------------

You can set the default skin by including the following settings in your
minetest.conf

Supported formats are `1.0` and `1.8`
```
multiskin_skin = <texture>
multiskin_format = <format>
```
Chat Commands
-------------

Requires `server` priv in multiplayer mode, no privs required in singleplayer.
```
/multiskin format <player_name> <format>
/multiskin set <player_name> <texture>
/multiskin unset <player_name>
/multiskin help
```
TODO
----

Document the api and add support to my 3d_armor and clothing mods.

