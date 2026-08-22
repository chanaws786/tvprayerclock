# MCWAS TV Prayer Clock

A full-screen digital clock display system designed for TV screens in mosques, showing prayer times, countdowns, and important Islamic timing information.

## Features

- **Real-time Clock Display**: Shows current time with date (Gregorian and Hijri calendars)
- **Prayer Times**: Displays 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) with start and congregation (Jama'ah) times
- **Smart Countdowns**: 
  - 60-second countdown before prayers
  - 20-minute countdown for major prayers
  - Zawal time notification
  - Sunrise notification
- **Prayer-in-Progress Indicators**: Visual notifications when prayers are ongoing
- **Jumu'ah (Friday) Handling**: Special display for Friday prayers with split time support
- **Ramadan Features**: Grey screen during night hours (1:15am - 2:30am) in Ramadan
- **Dynamic Data Loading**: Loads prayer timetables from CSV files or Google Sheets
- **Automatic Updates**: Refreshes timetable every 5 minutes
- **Error Recovery**: Robust fallback mechanisms for data loading failures
- **Display Scaling**: Automatically scales to any screen size (base 4K resolution)

## Requirements

- Processing 3.x or higher
- Java 8 or higher
- Display screen (TV or monitor recommended)

## Installation

1. **Clone or download this repository**

2. **Install Processing**:
   - Download from [processing.org](https://processing.org/download/)
   - Install for your operating system

3. **Open the Project**:
   - Launch Processing
   - File → Open → Select `MCWAS_MosqueClock.pde`
   - The project will load with all associated files

4. **Verify File Structure**:
   ```
   tvprayerclock/
   ├── MCWAS_MosqueClock.pde
   ├── Config.pde
   ├── README.md
   ├── data/
   │   ├── mcwas_prayer_timetable_2025.csv
   │   ├── mcwas_prayer_timetable_2026.csv
   │   └── config.txt
   ├── images/
   │   ├── mosque_logo.png
   │   ├── mosque_clock_right_pane_whatsapp.png
   │   └── mosque_clock_left_bottom_pane_switch_off_old.png
   └── font/
       ├── AvenirNextLTPro-Regular.otf
       └── AvenirNextLTPro-Bold.otf
   ```

## Configuration

### Configuration Files

The application uses a hierarchical configuration system:

1. **config.properties** - Base configuration (committed to git)
2. **config.properties.local** - Local overrides (not committed, use for personal settings)

### Configuration Properties

Edit `config.properties` to customize:

```properties
# Colors (hex format)
backgroundcolor=165D42
rightpanecolour=5D1631

# Timing Offsets (in minutes)
TenMinSalahInProgressOffset=10
SalahInProgressOffset=5
SalahCountDownStart=60
JummahLenghthMin=20
LargeCountDown=20
KarahatTimeOffset=20
SunriseOffset=10
NextDayTriggerInMinutes=5

# Ramadan Settings
enableRamadanGreyScreen=true

# Data Source
fileUrl=https://docs.google.com/spreadsheets/d/e/...

# Display Configuration
MAX_WIDTH=3840
MAX_HEIGHT=2160
frameRate=30
reloadIntervalMinutes=5

# Logging Configuration
logLevel=INFO  # Options: DEBUG, INFO, WARN, ERROR

# Network Configuration
urlConnectionTimeout=30000
urlReadTimeout=30000

# Font Sizes (base values before scaling)
timeFontSize=300
salahTimeFontSize=160
salahTimeHeadingFontSize=104
todaysDateFontSize=90
countDownFontSize=700
largeCountDownFontSize=900
salahNameFontSize=600

# Layout Coordinates (base values before scaling)
LAYOUT_RIGHT_PANE_X=2400
LAYOUT_RIGHT_PANE_Y=400
# ... (and more layout coordinates)
```

### Local Overrides

For local development or personal settings:

1. Copy `config.properties` to `config.properties.local`
2. Modify values in the local file
3. Local overrides take precedence over base configuration
4. `config.properties.local` is automatically ignored by git

### Legacy Configuration

The old `Config.pde` file is still maintained for backwards compatibility but configuration values are now loaded from properties files by default.

### Data Source Configuration

The application can load prayer times from:

1. **Local CSV Files**: Automatically loads `data/mcwas_prayer_timetable_YYYY.csv` for current year
2. **Google Sheets**: Set `fileUrl` in Config.pde to your published CSV URL

#### CSV Format Requirements

The CSV file must have these columns:
```
month_num,hijri_date,hijri_month,hijri_year,normal_day,normal_date,fajr_start,fajr_jamah,sunrise,dhuhr_start,dhuhr_jamah,asr_mitl_1,asr_mitl_2,asr_jamah,maghrib_start,maghrib_jamah,isha_start,isha_jamah
```

Example row:
```
1,12,Rajab,1447,Thu,1 Jan,6:26,7:00,8:03,12:09,1:15,1:46,2:17,1:50,4:05,4:05,5:42,8:00
```

### Display Configuration

The application is designed for 4K displays (3840x2160) but automatically scales to any resolution. Key layout constants are defined in `MCWAS_MosqueClock.pde`:

```processing
final int MAX_WIDTH = 3840;
final int MAX_HEIGHT = 2160;
```

## Running the Application

1. **In Processing IDE**:
   - Click the Run button (▶) or press Ctrl+R (Cmd+R on Mac)
   - The application will open in full-screen mode

2. **Export for Standalone Use**:
   - File → Export Application
   - Select target platforms (Windows, Mac, Linux)
   - Exported applications will be in the `application` folder

3. **Run Exported Application**:
   - Navigate to the exported application folder
   - Run the executable for your platform

## Usage

- **Automatic Operation**: The application runs automatically once started
- **Date Display**: Shows current Gregorian date and Hijri date
- **Prayer Times**: Left side shows prayer names, start times, and Jama'ah times
- **Countdowns**: Right pane displays countdowns to next prayer
- **In-Progress**: Shows "in progress" when prayers are ongoing
- **Jumu'ah**: Automatically switches to Jumu'ah display on Fridays
- **Ramadan**: Grey screen appears during 1:15am - 2:30am in Ramadan

## Troubleshooting

### Screen appears white
- Check that all image files exist in the `images/` folder
- Verify font files exist in the `font/` folder
- Check console for error messages

### Prayer times not displaying
- Verify CSV file exists for current year in `data/` folder
- Check CSV format matches required columns
- If using Google Sheets, verify URL is accessible
- Check internet connection for remote data loading

### Application not full-screen
- Ensure display settings allow full-screen applications
- Try running as administrator (Windows) or with appropriate permissions

### Performance issues
- Reduce frame rate in `setup()`: `frameRate(30)` to `frameRate(24)`
- Disable automatic reload by increasing `reloadInterval`
- Check system resources and close other applications

### Data loading errors
- Check console logs for specific error messages
- Verify CSV file format and encoding (UTF-8)
- Test Google Sheets URL in browser
- Ensure local CSV file exists as fallback

## Development

### Project Structure

- `MCWAS_MosqueClock.pde` - Main application logic (762 lines)
- `Config.pde` - Configuration settings
- `data/` - Prayer timetable CSV files
- `images/` - UI assets and images
- `font/` - Font files
- `test/` - Unit tests (if added)

### Key Functions

- `setup()` - Initialize application, load resources
- `draw()` - Main rendering loop (30 FPS)
- `reloadTable()` - Load/reload prayer timetable data
- `getTimesFor()` - Calculate prayer times for display
- `showTimerFor()` - Display countdown timers
- `showPrayerInProgressFor()` - Show prayer-in-progress notifications

### Adding New Features

1. **New Prayer Times**: Add columns to CSV and update `getTimesFor()`
2. **Custom Colors**: Modify color constants in `Config.pde`
3. **Additional Notifications**: Add new timer logic in `draw()` function
4. **New Data Sources**: Extend `reloadTable()` function

### Testing

Unit tests are provided for time calculation logic:

1. **Time Calculation Tests**:
   - Open Processing IDE
   - File → Open → Select `test/TimeCalculationTest.pde`
   - Click Run button
   - View console for test results

Test coverage includes:
- Time padding and formatting
- Prayer time calculations
- Ramadan detection logic
- Grey screen timing logic

See `test/README.md` for detailed testing instructions.

## Maintenance

### Updating Prayer Timetables

1. **For New Year**:
   - Create new CSV file: `mcwas_prayer_timetable_YYYY.csv`
   - Place in `data/` folder
   - Application automatically loads current year's file

2. **For Google Sheets**:
   - Update spreadsheet with new times
   - Ensure CSV export URL is correct
   - Application reloads every 5 minutes automatically

### Updating Images/Fonts

1. Replace files in respective folders
2. Maintain same filenames or update references in code
3. Test display after changes

## License

Copyright Pilgrim Media Productions
Author Shiraz Chanawala

## Support

For issues or questions:
- Check the Troubleshooting section
- Review console logs for error messages
- Verify file structure and configuration

## Changelog

### Recent Improvements (2025)
- **Configuration Management**: Externalized all configuration to properties files
  - Added `config.properties` for base configuration
  - Added `config.properties.local` for local overrides
  - Made colors, timing offsets, font sizes, and layout coordinates configurable
  - Added network timeout and logging configuration
- **Structured Logging**: Implemented comprehensive logging system
  - Added Logger class with multiple log levels (DEBUG, INFO, WARN, ERROR)
  - Replaced all println statements with structured logging
  - Added timestamps and consistent formatting
  - Configurable log level via properties file
- **Code Quality**: Made hardcoded values configurable
  - Font sizes now configurable
  - Network timeouts now configurable
  - Right pane text position now configurable
  - All layout coordinates now configurable
- **Testing**: Added unit tests for critical functions
  - Created `test/TimeCalculationTest.pde` for time calculation logic
  - Tests cover padTime, salahTimeInMinutes, isRamadanMonth, and isRamadanGreyScreenTime
  - Added test documentation and instructions
- **Documentation**: Comprehensive README with setup, configuration, and troubleshooting

### Previous Updates
- Added Ramadan grey screen during night hours (1:15am to 2:30am)
- Fixed screen freezing issues with thread-safe data reloading
- Improved URL connection timeout handling
- Enhanced error handling and recovery mechanisms
- Fixed logo positioning and display scaling
- Added comprehensive error checking and null safety