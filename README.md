# WayLite WoW Addon

WayLite is a World of Warcraft addon that simply creates map pins from `/way` commands commonly shared by the WoW community for players that don't want to install [TomTom](https://www.curseforge.com/wow/addons/tomtom), [Map Pin Enhanced](https://www.curseforge.com/wow/addons/mappinenhanced) or similar multi-purpose addons. If you're looking for more map and waypoint features, check out these addons instead.

## Usage

### Setting the Map Pin

```
/way [zoneID] x,y [description]
```

*Parameters in square brackets are optional. Zone IDs always start with a `#` (hash) symbol, such as `#2024`.*

The `description` parameter is ignored for compatability with TomTom `/way` commands commonly used on Wowhead comments.

**WARNING:** This command will overwrite the current map pin whether set by WayLite, another addon, or manually by the player.

### Removing the Map Pin

`/way clear` or `/way remove` will remove the current map pin, regardless of whether it was set by WayLite, another addon, or the player.


### Getting a `/way` Command for Your Current Location

Use `/way here` to get the zone and coordinates for your current location.

## Quirks

* TomTom `/way` coordinates are relative to the players current zone, by default. If you need a pin in a specific zone, either travel to the zone first, or make sure the command includes the zone ID parameter.

* If either [TomTom](https://www.curseforge.com/wow/addons/tomtom) or [Map Pin Enhanced](https://www.curseforge.com/wow/addons/mappinenhanced) are enabled WayLite will go into compatibility mode, deferring `/way` commands to them. Use `/waylite` instead.

## References

Command parsing based on [TomTom](https://www.curseforge.com/wow/addons/tomtom) and [Map Pin Enhanced](https://www.curseforge.com/wow/addons/mappinenhanced).