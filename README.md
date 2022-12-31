# WayLite Addon

WayLite simply creates map pins from /way commands for players that don't want to install TomTom, Map Pins Enhanced or similar multi-purpose addons.

## Usage

```
/way [zone] x,y [description]
```

The `zone` and `description` parameters are ignored for compatability with TomTom `/way` commands.

## Quirks

TomTom `/way` coordinates are relative to the players current zone. You are not able to add a map pin for a different zone than the one you are currently in. Travel to the relevant zone, then run the `/way` command.

## References

Command parsing based on [TomTom](https://www.curseforge.com/wow/addons/tomtom) and [Map Pin Enhanced](https://www.curseforge.com/wow/addons/mappinenhanced).