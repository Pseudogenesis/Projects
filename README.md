# Seed Planter 2.0

A comprehensive seed logging mod for **The Binding of Isaac: Repentance+** that automatically tracks your runs and saves detailed information about each seed.

## Features

### Core Functionality
- **Automatic Seed Logging**: Saves every run's seed to a readable log file
- **Character Tracking**: Records which character you played, including full support for Tainted characters
- **Item Tracking**: Two-tier system for tracking items:
  - **Notable Items**: Curated list of powerful and run-defining items
  - **Quality Items**: All items above a configurable quality threshold (configurable in code)
- **Transformation Tracking**: Records all transformations (Guppy, Stompy, Super Bum, etc.)
- **Run Statistics**: Tracks floor reached and game mode (Normal, Hard, Greed, Greedier, Challenges)
- **In-Game UI**: View your seed history directly in-game without opening files!

### New in Version 2.0

✨ **Repentance+ Compatibility**: Updated for all Repentance content
✨ **Tainted Character Support**: Properly detects and logs tainted characters
✨ **Item Quality System**: Logs items based on the game's quality rating (0-4)
✨ **In-Game UI**: Press F2 to view your recent seeds while playing
✨ **Floor Tracking**: See how far you got in each run
✨ **Expanded Item List**: Includes hundreds of new Repentance items
✨ **Updated Transformations**: Includes Stompy and Super Bum

## Installation

1. Subscribe to this mod on the Steam Workshop, or
2. Download and extract to your Isaac mods folder:
   - Windows: `%USERPROFILE%/Documents/My Games/Binding of Isaac Repentance+ Mods/`
   - Mac: `~/Library/Application Support/Binding of Isaac Repentance+ Mods/`
   - Linux: `~/.local/share/binding of isaac repentance+ mods/`

## Usage

### Automatic Logging
The mod works automatically! Just play the game normally. After each run, your seed data will be saved.

### Viewing Seed History

**In-Game (New!)**
- Press **F2** during a run to open the seed history UI
- View your last 8 seeds with full details
- Press **F2** again to close

**From File**
- Find your seed log at: `[Isaac Save Folder]/[Mod Name]/save1.dat`
- Open with any text editor (Notepad, VS Code, etc.)

### Example Seed Entry
```
{
  Seed: "9RJ6 4H04"
  Name: "Tainted Isaac"
  Floor: "Depths"
  Mode: "Hard"
  Transformations: "Guppy, Bookworm"
  Items: "Sacred Heart, Godhead, Brimstone, Tech X, Cricket's Head"
  Quality Items: "Sacred Heart, Godhead, Brimstone, Tech X, Cricket's Head, Magic Mushroom, Polyphemus"
}
```

## Configuration

You can customize the mod by editing `SeedPlanter.lua`:

### Item Quality Threshold
```lua
local QUALITY_THRESHOLD = 2  -- Only log items of quality 2+ (0-4 scale)
local LOG_ALL_QUALITIES = false  -- Set to true to log all items
```

Quality levels:
- **4**: Top-tier items (Sacred Heart, Godhead, etc.)
- **3**: Excellent items (Brimstone, Mom's Knife, etc.)
- **2**: Good items (most special items)
- **1**: Decent items
- **0**: Basic items

### Adding Custom Notable Items
The mod includes a curated list of notable items, but you can easily add more!

1. Find the item ID at [platinumgod.co.uk](https://platinumgod.co.uk/)
2. Open `SeedPlanter.lua` and find the `NotableItemsDict` table (around line 54)
3. Add your entry in the Repentance items section (line 74+):

```lua
[ItemID] = "Item Name",  -- e.g., [569] = "Blood Oath"
```

**Note:** Some Repentance item IDs may be incorrect in the default list. Please verify IDs at platinumgod.co.uk and feel free to correct any errors!

## Features in Detail

### Tainted Character Detection
The mod automatically detects when you're playing as a tainted character (PlayerType 21-38) and logs the name correctly with the "Tainted" prefix.

### Quality-Based Item Logging
In addition to the curated notable items list, the mod scans all items you've collected and logs those meeting the quality threshold. This ensures you never miss tracking a powerful item, even if it's not in the manual list.

### In-Game UI
The in-game overlay shows:
- Seed code
- Character name
- Game mode and difficulty
- Floor reached
- Transformations achieved
- Items collected

Press F2 to toggle the UI on/off. You can also use the console command:
```
lua seedMod:ToggleUI()
```

### Victory Lap Handling
Victory laps are NOT recorded, as they use the same seed and don't provide new information.

## Compatibility

- **Isaac Version**: Repentance+
- **Multiplayer**: Tracks Player 1 only
- **Challenges**: Supported (marked as "Challenge (Normal)")
- **Mods**: Compatible with most mods

## Known Limitations

- Items that are rerolled may not be tracked perfectly
- Active items that are replaced may not show in the final list
- Only Player 1 is tracked in co-op sessions
- Date/time stamps are not available due to API limitations

## Credits

- **Original Mod**: Pseudogenesis (/u/Pseudogenesis)
- **Pretty Printer**: Andre Segura (https://github.com/andrensegura/)
- **Testing Help**: Taiga, budj
- **Repentance+ Update**: Claude AI

## Support

For bug reports or feature requests:
- Original GitHub: https://github.com/Pseudogenesis
- Or open an issue on this mod's page

## License

Feel free to modify and share! Credit appreciated but not required.

## Changelog

### Version 2.0 (2024)
- Added Repentance+ compatibility
- Added tainted character support
- Added item quality filtering system
- Added in-game UI (F2 to toggle)
- Added floor tracking
- Updated transformations list (Stompy, Super Bum)
- Expanded notable items with 100+ Repentance items
- Improved character name detection
- Code cleanup and optimization

### Version 1.5 (Original)
- Initial Afterbirth+ release
- Basic seed logging
- Notable items tracking
- Transformation tracking
