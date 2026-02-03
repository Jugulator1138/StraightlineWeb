# Subwoofer Enclosure Designer

Automated design tool for custom subwoofer enclosures. Takes client specifications from Google Forms (via CSV export) and generates SketchUp models with cut lists.

## Folder Structure

```
SubwooferEnclosures/
├── enclosure_designer.rb      # Main script
├── lib/                       # Core modules
│   ├── subwoofer_database.rb  # Sub specs lookup
│   ├── port_calculator.rb     # Port tuning calculations
│   ├── enclosure_calculator.rb# Volume/dimension calculations
│   ├── sketchup_builder.rb    # SketchUp model generator
│   ├── cut_list_generator.rb  # Cut list & nesting
│   └── csv_parser.rb          # Google Sheets CSV parser
├── CSV_Imports/               # Drop CSV exports here
├── Generated_SKP/             # Output SketchUp scripts
├── CutLists/                  # HTML and TXT cut lists
└── SubwooferDatabase/         # Custom subwoofer specs
```

## Quick Start

### Option 1: Process CSV from Google Sheets

1. Export your Google Form responses as CSV
2. Place the CSV file in `CSV_Imports/`
3. Run: `ruby enclosure_designer.rb`
4. Select the CSV file from the menu

### Option 2: Interactive Mode

```bash
ruby enclosure_designer.rb -i
```

### Option 3: Direct CSV Path

```bash
ruby enclosure_designer.rb path/to/your/file.csv
```

## Loading Generated Models in SketchUp

1. Open SketchUp Pro 2021
2. Go to **Window → Ruby Console**
3. In the console, type:
   ```ruby
   load 'D:/ClaudeCode/SubwooferEnclosures/Generated_SKP/YourFile_builder.rb'
   ```
4. The model will be created and saved automatically

Or use the Extensions menu:
1. **Extensions → Ruby Console**
2. Paste the load command

## Output Files

For each client, the system generates:

1. **SketchUp Builder Script** (`*_builder.rb`)
   - Load this in SketchUp to create the 3D model
   - Creates assembled view and exploded view
   - Includes dimensions and labels

2. **Cut List HTML** (`*_cutlist.html`)
   - Print-ready cut list
   - Visual nesting diagrams showing panel layout on sheets
   - Material usage summary

3. **Cut List TXT** (`*_cutlist.txt`)
   - Plain text version for quick reference

## Supported Enclosure Types

- **Sealed** - Simple sealed box
- **Ported** - Slot port using box walls
- **4th Order Bandpass** - Dual chamber with ported output

## Features

### Automatic Calculations
- Net internal volume (after displacements)
- Port dimensions for target tuning frequency
- Sub/port/bracing displacement subtraction
- Material usage optimization

### Construction Options
- Double baffle (1.5" total baffle thickness)
- Window bracing with 45° corners
- Separate chambers for multiple subs
- Terminal cup placement

### Material Optimization
- Panel nesting on 4'x8' sheets
- 1/8" kerf allowance
- Efficiency percentage tracking
- Visual cutting diagrams

## Subwoofer Database

Common subs are built into the database:
- Skar Audio (VXF, EVL, ZVX, SDR series)
- Sundown Audio (X, SA series)
- American Bass (XFL, HD)
- Kicker (CompR, L7R)
- JL Audio (W6, W7)
- Rockford Fosgate (P3, T1)
- DC Audio (Level 3, Level 5)
- And more...

If a sub isn't found, you'll be prompted to enter specs manually. These are saved to `SubwooferDatabase/custom_subs.json` for future use.

## Port Calculation Notes

The port calculator uses standard formulas:
- `Fb = (c / 2π) × √(Sp / (Vb × Lp))`
- End correction factor: 0.825 × √(port area)

Port area is calculated based on power level:
- Daily: 12 sq in per cubic foot
- SQL: 14 sq in per cubic foot
- SPL: 18 sq in per cubic foot

## Adjusting Designs

### Change Tuning Frequency
Modify the `tuning_frequency` in your CSV or interactive input. The port length will automatically recalculate.

### Change Box Volume
The system uses the dimensions you provide. To hit a specific volume, you may need to adjust max width/height/depth.

### Port Won't Fit?
If the port is too long for the available space, options are:
1. Increase port height (larger area = shorter length)
2. Raise tuning frequency (higher Hz = shorter port)
3. Increase box depth

## Troubleshooting

**"Port doesn't fit" warning**
The L-shaped port path length exceeds available internal dimensions. Either increase box depth or raise tuning frequency.

**Subwoofer not found**
Enter specs manually when prompted. They'll be saved for future use.

**SketchUp script errors**
Ensure you're using SketchUp Pro 2021. Open Ruby Console to see error messages.

## CSV Column Headers

The parser is flexible with column names. Recognized patterns include:

| Field | Accepted Headers |
|-------|-----------------|
| Client Name | "Full Name", "Name", "Client" |
| Sub Model | "Brand/Model", "Subwoofer", "Sub Model" |
| Quantity | "Quantity", "How many", "Drivers" |
| Width | "Max width", "Width", "Available width" |
| Tuning | "Desired tuning", "Tuning frequency", "Tuning" |
| ... | (see csv_parser.rb for full list) |

## License

Internal tool for custom enclosure builds.
