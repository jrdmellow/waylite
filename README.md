# WayLite WoW Addon

WayLite is a World of Warcraft addon that simply creates map pins from `/way` commands commonly shared by the WoW community for players that don't want to install [TomTom](https://www.curseforge.com/wow/addons/tomtom), [Map Pin Enhanced](https://www.curseforge.com/wow/addons/mappinenhanced) or similar multi-purpose addons. If you're looking for more map and waypoint features, check out these addons instead.

## Usage

### Setting the Map Pin

```
/way [zone] x,y [description]
```

The `zone` and `description` parameters are ignored for compatability with TomTom `/way` commands.

This command will overwrite the current map pin whether set by WayLite, another addon, or the player.

### Removing the Map Pin

`/way clear` or `/way remove` will remove the current map pin, regardless of whether it was set by WayLite, another addon, or the player.


### Getting the

## Quirks

* TomTom `/way` coordinates are relative to the players current zone. You are not able to add a map pin for a different zone than the one you are currently in. Travel to the relevant zone, then run the `/way` command.

* If either [TomTom](https://www.curseforge.com/wow/addons/tomtom) or [Map Pin Enhanced](https://www.curseforge.com/wow/addons/mappinenhanced) are enabled WayLite will go into compatibility mode, deferring `/way` commands to them. Use `/waylite` instead.

## References

Command parsing based on [TomTom](https://www.curseforge.com/wow/addons/tomtom) and [Map Pin Enhanced](https://www.curseforge.com/wow/addons/mappinenhanced).