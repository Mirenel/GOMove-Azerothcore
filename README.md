# mod-gomove for AzerothCore

Server module and client addon for in-game GameObject placement, movement, deletion, scaling, and searching.

Originally by [Rochet2](https://rochet2.github.io/). Ported to AzerothCore with a GameObject Browser extension by Project Rx.

## Features

- Spawn, move, delete, and scale GameObjects in-game
- Search gameobject_template by name or entry ID with 3D model preview
- Nudge objects by compass direction, axis, or rotation
- Per-instance scale overrides persisted across restarts
- Select nearby objects or all within a radius
- Phase objects between phase masks
- Favourites list saved across sessions
- Ground-target spell placement mode

## Layout

    server/mod-gomove/          Server module (drop into modules/)
      CMakeLists.txt
      src/GOMove.h
      src/GOMove.cpp
      src/GOMoveScripts.cpp
      src/gomove_loader.cpp

    addon/GOMove/               Client addon (drop into Interface/AddOns/)
      GOMove.toc
      GOMoveFunctions.lua
      GOMoveScripts.lua
      GOMoveScripts_Browser.lua
      MapButton.xml

    sql/gomove_setup.sql        DB schema + command registration
    patches/worlddatabase_gomove.patch   Core source patch

## Install

1. Copy `server/mod-gomove/` into `modules/mod-gomove/`
2. Apply `patches/worlddatabase_gomove.patch` (or add the two prepared statements manually)
3. Run `sql/gomove_setup.sql` on your acore_world database
4. Rebuild (re-run cmake, make, make install)
5. Copy `addon/GOMove/` into `Interface/AddOns/GOMove/`

## Configuration

Edit `GOMOVE_MIN_SECURITY` in `GOMoveScripts.cpp` (default: SEC_GAMEMASTER = 2).
Match the `security` column in `gomove_setup.sql`.

Placement spell defaults to ID 27651. Change in `gomove_setup.sql`.

## Usage

Type `/gomove` in-game or click the minimap button.

## Credits

- **Rochet2** -- Original GOMove addon and server code
- **Project Rx** -- AzerothCore port and GameObject Browser extension

Browser branding references in `GOMoveScripts_Browser.lua` (line 1 comment, line 562 footer).

## License

GNU GPL v2. See LICENSE file.
