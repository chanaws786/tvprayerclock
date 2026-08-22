
// Copyright Pilgrim Media Productions
// Author Shiraz Chanawala

import java.util.Calendar;

int rtpanex;
int rtpaney;
PImage rightpane;
PImage leftBottomPane;
PImage logo;
int viewWidth;
int viewHeight;
float xRatio;
float yRatio;
volatile Table table;

// Fonts
PFont TimeFont;
PFont SalahTimeFont;
PFont SalahTimeFontBold;
PFont SalahTimeFontHeading;
PFont TodaysDateFont;
PFont CountDownFont;
PFont LargeCountDownFont;
PFont SalahNameFont;
long lastReloadTime = 0;
int reloadInterval;
volatile boolean isReloading = false;
Table backupTable;

// Ramadan grey screen tracking
boolean isRamadan = false;

// Logging system
class Logger {
  private static final String LOG_LEVEL_INFO = "INFO";
  private static final String LOG_LEVEL_WARN = "WARN";
  private static final String LOG_LEVEL_ERROR = "ERROR";
  private static final String LOG_LEVEL_DEBUG = "DEBUG";
  
  private String logLevel = "INFO"; // Default log level
  
  void setLogLevel(String level) {
    this.logLevel = level.toUpperCase();
  }
  
  void info(String message) {
    log(LOG_LEVEL_INFO, message);
  }
  
  void warn(String message) {
    log(LOG_LEVEL_WARN, message);
  }
  
  void error(String message) {
    log(LOG_LEVEL_ERROR, message);
  }
  
  void error(String message, Exception e) {
    log(LOG_LEVEL_ERROR, message + " - " + e.getMessage());
    if (e != null) {
      e.printStackTrace();
    }
  }
  
  void debug(String message) {
    if (logLevel.equals(LOG_LEVEL_DEBUG)) {
      log(LOG_LEVEL_DEBUG, message);
    }
  }
  
  private void log(String level, String message) {
    String timestamp = getCurrentTime();
    println("[" + timestamp + "] [" + level + "] " + message);
  }
}

Logger logger = new Logger();

// Month names array for efficient lookup
String[] MONTH_NAMES = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

// Calendar day constants (Java Calendar values)
final int DAY_SUNDAY = 1;
final int DAY_MONDAY = 2;
final int DAY_TUESDAY = 3;
final int DAY_WEDNESDAY = 4;
final int DAY_THURSDAY = 5;
final int DAY_FRIDAY = 6;
final int DAY_SATURDAY = 7;

// Day name constants for string comparisons
final String DAY_FRIDAY_NAME = "Fri";

void setup() {

  // Load configuration from properties file
  loadConfiguration();

  // Set log level from configuration
  logger.setLogLevel(logLevel);

  fullScreen(P2D);
  pixelDensity(1);
  viewWidth = displayWidth;
  viewHeight = displayHeight;

  xRatio = float(viewWidth) / float(MAX_WIDTH);
  yRatio = float(viewHeight) / float(MAX_HEIGHT);
  rtpanex = int(x(rightPaneTextX));
  rtpaney = int(y(rightPaneTextY));
  frameRate(frameRateValue);

  // Load images with error handling using helper function
  rightpane = loadImageSafely("images/mosque_clock_right_pane_whatsapp.png", "rightpane");
  logo = loadImageSafely("images/mosque_logo.png", "logo");
  leftBottomPane = loadImageSafely("images/mosque_clock_left_bottom_pane_switch_off_old.png", "leftBottomPane");


  // Load fonts with error handling using helper function
  TimeFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(timeFontSize), "TimeFont");
  SalahTimeFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(salahTimeFontSize), "SalahTimeFont");
  SalahTimeFontBold = loadFontSafely("font/AvenirNextLTPro-Bold.otf", x(salahTimeFontSize), "SalahTimeFontBold");
  SalahTimeFontHeading = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(salahTimeHeadingFontSize), "SalahTimeFontHeading");
  TodaysDateFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(todaysDateFontSize), "TodaysDateFont");
  CountDownFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(countDownFontSize), "CountDownFont");
  LargeCountDownFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(largeCountDownFontSize), "LargeCountDownFont");
  SalahNameFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(salahNameFontSize), "SalahNameFont");

  // Set reload interval from configuration
  reloadInterval = reloadIntervalMinutes * 60 * 1000;

  reloadTable(); // Load the table initially

}

// Helper function to load fonts with error handling
PFont loadFontSafely(String fontPath, float fontSize, String fontName) {
  try {
    PFont font = createFont(fontPath, fontSize);
    if (font == null) {
      logger.warn("Failed to load " + fontName);
    } else {
      logger.debug("Successfully loaded " + fontName);
    }
    return font;
  } catch (Exception e) {
    logger.error("Error loading " + fontName, e);
    return null;
  }
}

// Helper function to pad time values with leading zeros
String padTime(int value) {
  String result = str(value);
  if (result.length() == 1) {
    result = "0" + result;
  }
  return result;
}

// Helper function to get the data filename for current year
String getDataFilename() {
  int currentYear = year();
  return "data/mcwas_prayer_timetable_" + currentYear + ".csv";
}

// Helper function to check if current hijri month is Ramadan
boolean isRamadanMonth(String hijriMonth) {
  return hijriMonth != null && (hijriMonth.equalsIgnoreCase("Ramadan") || hijriMonth.equalsIgnoreCase("Ramadhan"));
}

// Helper function to check if current time is within Ramadan grey screen window (configurable via config.properties)
boolean isRamadanGreyScreenTime() {
  int currentHour = hour();
  int currentMinute = minute();

  // Use test time if test mode is enabled
  if (testMode && testTime != null && !testTime.isEmpty()) {
    String[] parts = testTime.split(":");
    if (parts.length == 2) {
      try {
        currentHour = parseInt(parts[0].trim());
        currentMinute = parseInt(parts[1].trim());
      } catch (Exception e) {
        logger.error("Invalid test time format: " + testTime + ", using current time");
      }
    }
  }

  int currentTotalMinutes = currentHour * 60 + currentMinute;

  // Parse configurable start and end times from configuration
  int startMinutes = parseTimeToMinutes(ramadanGreyScreenStart);
  int endMinutes = parseTimeToMinutes(ramadanGreyScreenEnd);

  return currentTotalMinutes >= startMinutes && currentTotalMinutes < endMinutes;
}

// Helper function to parse time string (HH:MM) to minutes since midnight
int parseTimeToMinutes(String timeString) {
  if (timeString == null || timeString.isEmpty()) {
    logger.warn("Empty time string provided, using default 0");
    return 0;
  }

  try {
    String[] parts = timeString.split(":");
    if (parts.length == 2) {
      int hour = parseInt(parts[0].trim());
      int minute = parseInt(parts[1].trim());
      return hour * 60 + minute;
    } else {
      logger.warn("Invalid time format: " + timeString + ", expected HH:MM");
      return 0;
    }
  } catch (Exception e) {
    logger.error("Error parsing time string: " + timeString, e);
    return 0;
  }
}

// Helper function to load images with error handling
PImage loadImageSafely(String imagePath, String imageName) {
  try {
    PImage img = loadImage(imagePath);
    if (img != null) {
      img.resize(x(img.width), y(img.height));
      logger.debug("Successfully loaded " + imageName);
    } else {
      logger.warn("Failed to load " + imageName);
    }
    return img;
  } catch (Exception e) {
    logger.error("Error loading " + imageName, e);
    return null;
  }
}

// Load the timetable file
void reloadTable(){
  if (isReloading) {
    logger.warn("Reload already in progress, skipping...");
    return;
  }

  isReloading = true;
  Table newTable = null;

  try {
    logger.info("Starting table reload at " + getCurrentTime());

    if (fileUrl.length()>1) {
      // Try loading from URL with proper HTTPS handling
      try {
        java.net.URL url = new java.net.URL(fileUrl);
        java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(urlConnectionTimeout);
        conn.setReadTimeout(urlReadTimeout);
        conn.setInstanceFollowRedirects(true); // Follow redirects
        conn.setRequestProperty("User-Agent", "Mozilla/5.0");
        conn.setRequestProperty("Accept", "text/csv");
        conn.setRequestProperty("Cache-Control", "no-cache, no-store, must-revalidate");
        conn.setRequestProperty("Pragma", "no-cache");
        conn.setUseCaches(false);

        int responseCode = conn.getResponseCode();
        logger.info("URL response code: " + responseCode + " for " + fileUrl);
        if (responseCode == 200) {
          java.io.InputStream is = null;
          java.io.BufferedReader reader = null;
          java.io.FileWriter writer = null;
          java.io.File tempFile = null;

          try {
            is = conn.getInputStream();
            reader = new java.io.BufferedReader(new java.io.InputStreamReader(is));
            StringBuilder content = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
              content.append(line).append("\n");
            }

            // Save to temporary file
            tempFile = java.io.File.createTempFile("prayer_timetable", ".csv");
            writer = new java.io.FileWriter(tempFile);
            writer.write(content.toString());

            // Load from temp file
            newTable = loadTable(tempFile.getAbsolutePath(), "header");
            if (newTable == null || newTable.getColumnCount() < 2 || newTable.getRowCount() == 0) {
              logger.warn("URL did not return a valid CSV timetable, falling back to local file");
              newTable = null;
            } else {
              logger.info("Successfully loaded table from URL, rows=" + newTable.getRowCount() + ", cols=" + newTable.getColumnCount());
            }
          } finally {
            // Close resources in finally block to prevent leaks
            if (reader != null) {
              try { reader.close(); } catch (Exception e) { logger.error("Error closing reader", e); }
            }
            if (is != null) {
              try { is.close(); } catch (Exception e) { logger.error("Error closing input stream", e); }
            }
            if (writer != null) {
              try { writer.close(); } catch (Exception e) { logger.error("Error closing writer", e); }
            }
            if (tempFile != null && tempFile.exists()) {
              tempFile.delete();
            }
          }
        } else {
          logger.warn("URL load failed with HTTP code: " + responseCode + ", falling back to local file");
          newTable = null;
        }
        conn.disconnect();
      } catch (Exception e) {
        logger.error("URL load failed, falling back to local file", e);
        newTable = null;
      }
    }

    // Fallback to local file if URL load failed or not configured
    if (newTable == null) {
      logger.info("Loading local file...");
      String filename = getDataFilename();
      try {
        newTable = loadTable(filename, "header");
        if (newTable != null && newTable.getRowCount() > 0) {
          logger.info("Successfully loaded local table: " + filename);
        } else {
          logger.warn("Local table loaded but is null or empty");
          newTable = null;
        }
      } catch (Exception e) {
        logger.error("Error loading local file: " + filename, e);
        newTable = null;
      }
    }

    // Only update the main table if load was successful
    if (newTable != null && newTable.getRowCount() > 0) {
      backupTable = table; // Keep current table as backup
      table = newTable;
      logger.info("Table reloaded successfully at " + getCurrentTime());
    } else {
      logger.error("Reload failed: table is null or empty, keeping current table");
    }

  } catch (Exception e) {
    logger.error("Exception during reload", e);
    // Keep the existing table if reload fails
    if (table == null && backupTable != null) {
      logger.info("Restoring from backup table");
      table = backupTable;
    }
  } finally {
    isReloading = false;
  }
}

String getCurrentTime() {
  return hour() + ":" + minute() + ":" + second();
}

void draw() {

  // Check if we should show grey screen (Ramadan 1:15am to 2:30am)
  boolean showGreyScreen = enableRamadanGreyScreen && isRamadan && isRamadanGreyScreenTime();

  // Debug logging (only log occasionally to avoid spam)
  if (frameCount % 60 == 0) { // Log once per second (assuming 60fps)
    logger.debug("Grey screen check: enableRamadanGreyScreen=" + enableRamadanGreyScreen +
                 ", isRamadan=" + isRamadan +
                 ", isRamadanGreyScreenTime=" + isRamadanGreyScreenTime() +
                 ", showGreyScreen=" + showGreyScreen +
                 ", currentHour=" + hour() + ", currentMinute=" + minute());
  }

  // Always draw background first to prevent white screen
  stroke(0);
  if (showGreyScreen) {
    fill(128); // Grey color for Ramadan night window
  } else {
    fill(backgroundcolor);
  }
  rect(0, 0, viewWidth, viewHeight);

  // RAMADAN GREY SCREEN - Show this BEFORE any data loading errors
  // This ensures grey screen works even if data loading fails
  if (showGreyScreen) {
    // Grey background
    fill(128);
    rect(0, 0, viewWidth, viewHeight);

    // Ramadan night time message
    fill(255);
    textAlign(CENTER, CENTER);
    safeTextFont(TodaysDateFont);
    text("Ramadan - Night Prayer Time", viewWidth/2, viewHeight/2 - 50);
    text(ramadanGreyScreenStart + " - " + ramadanGreyScreenEnd, viewWidth/2, viewHeight/2 + 50);

    return; // Skip drawing all other UI elements
  }

  if (millis() - lastReloadTime > reloadInterval){
    lastReloadTime = millis();
    thread("reloadTable");
  }

  // Safety check: if table is null, try to reload it synchronously
  if (table == null) {
    logger.error("Table is null, attempting emergency reload...");
    try {
      String filename = getDataFilename();
      table = loadTable(filename, "header");
      if (table != null && table.getRowCount() > 0) {
        logger.info("Emergency reload completed: " + filename);
      } else {
        logger.error("Emergency reload failed: table is null or empty");
        throw new Exception("Loaded table is null or empty");
      }
    } catch (Exception e) {
      logger.error("Emergency reload failed", e);
      // Display error message with contrasting background
      fill(0);
      stroke(255);
      rect(viewWidth/2 - x(400), viewHeight/2 - y(50), x(800), y(100));
      fill(255);
      textAlign(CENTER);
      safeTextFont(TodaysDateFont);
      text("Error: Unable to load prayer timetable. Please check data files.", viewWidth/2, viewHeight/2);
      return;
    }
  }

  // Time Background
  stroke(0);
  fill(0);
  rect(0, 0, x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_TIME_BACKGROUND_HEIGHT));

  // Logo
  if (logo != null) {
    // Center logo horizontally within the right pane, position at top
    int logoX = x(LAYOUT_RIGHT_PANE_X + LAYOUT_RIGHT_PANE_WIDTH/2) - logo.width/2;
    image(logo, logoX, 0); // Position at top edge
  } else {
    logger.warn("Logo image is null, skipping display");
  }

  // Right Pane background and default image
  fill(rightpanecolour);
  stroke(0);
  rect(x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_RIGHT_PANE_Y), x(LAYOUT_RIGHT_PANE_WIDTH), y(LAYOUT_RIGHT_PANE_HEIGHT));
  if (rightpane != null) {
    image(rightpane, x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_RIGHT_PANE_Y));
  } else {
    logger.warn("Right pane image is null, skipping display");
  }

  // Get the day of the week to determine if its Jumuah
  Calendar c = Calendar.getInstance();
  int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
  
  //What is today - needs to be in dd mmm
  int h=hour();
  int mi=minute();
  int s=second();
  int hdisplay = h;
  int d = day();
  int m = month();
  int yr = year();
  int CurrentTotalTimeMins;
  String mmm = "";
  String TodaysDate = "";
  String FullTodaysDate = "";
  String FullHijriDate ="";

  //Build the clock using helper function for padding
  String s0 = padTime(s);
  String m0 = padTime(mi);

  // Time String stored in Time variable
  if (hdisplay>12) {
    hdisplay = hdisplay-12;
  };
  String Time = (hdisplay) + ":" + (m0) + ":" + s0;

  //Convert Month to 3 character Month using array lookup
  mmm = MONTH_NAMES[m - 1]; // Array is 0-indexed, months are 1-12

  // Construct Todays Date for compare
  String dsi = str(d);
  TodaysDate = (dsi + " " + mmm);

  // Safety check for table
  if (table == null) {
    fill(0);
    stroke(255);
    rect(viewWidth/2 - x(300), viewHeight/2 - y(50), x(600), y(100));
    fill(255);
    textAlign(CENTER);
    safeTextFont(TodaysDateFont);
    text("Error: Prayer timetable not loaded", viewWidth/2, viewHeight/2);
    return;
  }

  TableRow row = table.findRow(TodaysDate, "normal_date");
  if (row==null) {
    // Error Message with contrasting background
    fill(0);
    stroke(255);
    rect(x(LAYOUT_LEFT_MARGIN), y(LAYOUT_ERROR_BOX_Y), x(LAYOUT_BEGINS_ROW_X), y(80));
    fill(255);
    textAlign(LEFT);
    safeTextFont(TodaysDateFont);
    text("No row found for date '"+TodaysDate +"' in the spreadsheet", x(LAYOUT_LEFT_MARGIN), y(LAYOUT_TIME_Y));
    return;
  }

  FullTodaysDate = (TodaysDate + " " + str(yr));
  CurrentTotalTimeMins = h*60 + mi;

  int rowNum = row.getInt("month_num");
  int nextRowIndex = rowNum % table.getRowCount(); //because rowIndex is always rowNum-1;

  TableRow nextRow = table.getRow(nextRowIndex);
  if (nextRow == null) {
    logger.warn("nextRow is null for index " + nextRowIndex);
    nextRow = row; // Fallback to current row
  }  

  String Date = safeGetString(row, "normal_date");
  String Day = safeGetString(row, "normal_day");
    
    //   Calculate Jumuah time from the spreadsheet.
  int ZeroBasedDayOfWeek = dayOfWeek-1;
  int daysToAddToReachFriday = ZeroBasedDayOfWeek==6?6:(5-ZeroBasedDayOfWeek);
  int jumuahRowIndex = (rowNum-1+daysToAddToReachFriday) % table.getRowCount(); // -1 because rowIndex is always rowNum-1;
  int nextJumuahRowIndex = (jumuahRowIndex+7) % table.getRowCount();
  TableRow jumuahRow = table.getRow(jumuahRowIndex);
  TableRow nextJumuahRow = table.getRow(nextJumuahRowIndex);

  if (jumuahRow == null) {
    logger.warn("jumuahRow is null for index " + jumuahRowIndex);
    jumuahRow = row; // Fallback to current row
  }
  if (nextJumuahRow == null) {
    logger.warn("nextJumuahRow is null for index " + nextJumuahRowIndex);
    nextJumuahRow = nextRow; // Fallback to next row
  }

  Times fajr = getTimesFor("Fajr", "fajr_jamah", "fajr_start", null, row, nextRow, CurrentTotalTimeMins, 0, false, dayOfWeek, TenMinSalahInProgressOffset);
  Times sunrise = getTimesFor("Sunrise", "sunrise", "sunrise", null, row, nextRow, CurrentTotalTimeMins, 0, false, dayOfWeek, SunriseOffset);
  Times dhuhr = getTimesFor("Dhuhr", "dhuhr_jamah", "dhuhr_start", null, row, nextRow, CurrentTotalTimeMins, 0, true, dayOfWeek, SalahInProgressOffset);
  Times asr = getTimesFor("Asr", "asr_jamah", "asr_mitl_1", "asr_mitl_2", row, nextRow, CurrentTotalTimeMins, 12, false, dayOfWeek, SalahInProgressOffset);
  Times maghrib = getTimesFor("Maghrib", "maghrib_jamah","maghrib_start", null, row, nextRow, CurrentTotalTimeMins, 12, false, dayOfWeek, SalahInProgressOffset);
  Times isha = getTimesFor("Isha", "isha_jamah", "isha_start", null, row, nextRow, CurrentTotalTimeMins, 12, false, dayOfWeek, TenMinSalahInProgressOffset);
  Times jummah = getTimesFor("Dhuhr", "dhuhr_jamah", "dhuhr_start", null, jumuahRow, nextJumuahRow, CurrentTotalTimeMins, 0, true, dayOfWeek, JummahLenghthMin);

  // Calculate the actual end time of Jummah (accounting for split times)
  int jummahEndTime = jummah.jamahTimeInMinutes + JummahLenghthMin;
  if (safeGetString(jumuahRow, "normal_day").equals(DAY_FRIDAY_NAME)) {
    String jamah = safeGetString(jumuahRow, "dhuhr_jamah");
    if (jamah.contains("/")) {
      String[] jamahs = split(jamah, "/");
      int secondJummahTime = salahTimeInMinutes(jamahs[1], 0, true);
      jummahEndTime = secondJummahTime + JummahLenghthMin;
    }
  }

  // On Friday after Jummah time has passed, use next day's Dhuhr time
  Times dhuhrToShow = dhuhr;
  if (dayOfWeek == DAY_FRIDAY && CurrentTotalTimeMins >= jummahEndTime && nextRow != null) {
    dhuhrToShow = getTimesFor("Dhuhr", "dhuhr_jamah", "dhuhr_start", null, nextRow, table.getRow((rowNum % table.getRowCount() + 1) % table.getRowCount()), CurrentTotalTimeMins, 0, true, dayOfWeek, SalahInProgressOffset);
  }

  // Determine if we should show Jummah label
  // On Friday: show before Jummah time ends
  // On Thursday: show when displaying next day's (Friday's) Dhuhr/Jummah time
  boolean showJummahLabel = (dayOfWeek == DAY_FRIDAY && CurrentTotalTimeMins < jummahEndTime) ||
                            (dayOfWeek == DAY_THURSDAY && dhuhrToShow.isNextDay);

  int todaysDhuhrStartTime = salahTimeInMinutes(safeGetString(row, "dhuhr_start"), 0, true);
  int karahatTime = todaysDhuhrStartTime - KarahatTimeOffset;
    
  // Hijri Date
  TableRow hiriDateRow = CurrentTotalTimeMins < maghrib.startTimeInMinutes ? row : nextRow;
  String HijriDate = safeGetString(hiriDateRow, "hijri_date");
  String HijriMonth = safeGetString(hiriDateRow, "hijri_month");
  String HijriYear = safeGetString(hiriDateRow, "hijri_year");

  // Check if current month is Ramadan (or force mode for testing)
  isRamadan = forceRamadanMode || isRamadanMonth(HijriMonth);

  // Create Date to display which is Gregoran and Hijri Date
  FullHijriDate = (HijriDate + " " + HijriMonth + " " + HijriYear);

  // Print Time and Todays Date First
  if (Date.equals(TodaysDate)) {
    // Large Clock
    fill(255);
    textAlign(LEFT);
    safeTextFont(TimeFont);
    text(Time, x(LAYOUT_LEFT_MARGIN), y(LAYOUT_TIME_Y));

    // Gregorian Date display
    fill(255);
    textAlign(RIGHT);
    safeTextFont(TodaysDateFont);
    text(FullTodaysDate, x(LAYOUT_JAMAAT_ROW_X + 50), y(LAYOUT_DATE_Y));

    // Hijri Date display
    fill(255);
    textAlign(RIGHT);
    safeTextFont(TodaysDateFont);
    text(FullHijriDate, x(LAYOUT_JAMAAT_ROW_X + 50), y(LAYOUT_TIME_Y));

    // Salah Text Allignment
    int snax = x(LAYOUT_SALAH_NAME_X); //Salah name row
    int snay = y(LAYOUT_SALAH_NAME_Y);
    int snay_gap = y(LAYOUT_SALAH_GAP);
    int stabx = x(LAYOUT_BEGINS_ROW_X); //Begins row
    int stasx = x(LAYOUT_JAMAAT_ROW_X); //Jamat row

    // *** DISPLAY HEADINGS ****
    fill(255);
    textAlign(LEFT);
    textFont(TodaysDateFont);
    text("BEGINS", stabx, y(LAYOUT_HEADINGS_Y));
    textFont(TodaysDateFont);
    textAlign(RIGHT);
    text("JAMAAT", stasx, y(LAYOUT_HEADINGS_Y));

    // *** DISPLAY SALAH NAMES
    safeTextFont(SalahTimeFont);
    textAlign(LEFT);
    text("Fajr", snax, snay);

    // Substitute Jummah for Dhuhr on Fridays and Saturday before Jummah time
   if (showJummahLabel) {
      text("Jum'uah", snax, snay+snay_gap);
    } else {
      text("Dhuhr", snax, snay+snay_gap);
    }

    text("Asr", snax, (snay+2*snay_gap));
    text("Maghrib", snax, snay+3*snay_gap);
    text("Isha", snax, snay+4*snay_gap);

    // *** DISPLAY SALAH JAMAH TIMES
    safeTextFont(SalahTimeFontBold);
    textAlign(RIGHT);

    // Set Prayer Times
    text(fajr.jamahTime, stasx, snay);
    // Show Jummah time instead of Dhuhr when displaying Jum'uah label
    if (showJummahLabel) {
      text(jummah.jamahTime, stasx, snay+snay_gap);
    } else {
      text(dhuhrToShow.jamahTime, stasx, snay+snay_gap);
    }
    text(asr.jamahTime, stasx, snay+2*snay_gap);
    text(maghrib.jamahTime, stasx, snay+3*snay_gap);
    text(isha.jamahTime, stasx, snay+4*snay_gap);

    // *** DISPLAY SALAH JAMAH BEGIN TIMES
    safeTextFont(SalahTimeFont);
    textAlign(LEFT);

    text(fajr.startTime1, stabx, snay);
    // Show Jummah start time instead of Dhuhr when displaying Jum'uah label
    if (showJummahLabel) {
      text(jummah.startTime1, stabx, snay+snay_gap);
    } else {
      text(dhuhrToShow.startTime1, stabx, snay+snay_gap);
    }
    // Set Asr Begins Time - we need to show Mitl 1 and Mitl 2
    text(asr.startTime1 + "/" + asr.startTime2, stabx, snay+2*snay_gap);
    text(maghrib.startTime1, stabx, snay+3*snay_gap);
    text(isha.startTime1, stabx, snay+4*snay_gap);


    // ** Right Pane Text //
    // 60 seconds timer.
    if (!fajr.isNextDay && CurrentTotalTimeMins == fajr.jamahTimeInMinutes-1) {
      show60SecondsTimerFor(fajr);
    } else if (!dhuhrToShow.isNextDay && CurrentTotalTimeMins == dhuhrToShow.jamahTimeInMinutes-1 && !showJummahLabel) {
      show60SecondsTimerFor(dhuhrToShow);
    } else if (!jummah.isNextDay && CurrentTotalTimeMins == jummah.jamahTimeInMinutes-1 && showJummahLabel) {
      showTimerFor("Time to Jum'uah", SalahCountDownStart - second(), "seconds");
    } else if (!asr.isNextDay && CurrentTotalTimeMins == asr.jamahTimeInMinutes-1) {
      show60SecondsTimerFor(asr);
    } else if (!maghrib.isNextDay && CurrentTotalTimeMins == maghrib.startTimeInMinutes-1) {
      show60SecondsTimerFor(maghrib);
    } else if (!isha.isNextDay && CurrentTotalTimeMins == isha.jamahTimeInMinutes-1) {
      show60SecondsTimerFor(isha);
    }
    // Minute Timers
    else if (!fajr.isNextDay && (CurrentTotalTimeMins > fajr.jamahTimeInMinutes-LargeCountDown && CurrentTotalTimeMins < fajr.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(fajr, CurrentTotalTimeMins);
    } else if (dayOfWeek != DAY_THURSDAY && CurrentTotalTimeMins >= karahatTime && CurrentTotalTimeMins < todaysDhuhrStartTime) {
      showTimerFor("Zawal Time", todaysDhuhrStartTime-CurrentTotalTimeMins, "minutes");
    } else if (!dhuhrToShow.isNextDay && CurrentTotalTimeMins >= (dhuhrToShow.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (dhuhrToShow.jamahTimeInMinutes-1) && !showJummahLabel) {
      showMinutesTimerFor(dhuhrToShow, CurrentTotalTimeMins);
    } else if (!jummah.isNextDay && dayOfWeek == DAY_FRIDAY && CurrentTotalTimeMins >= todaysDhuhrStartTime && CurrentTotalTimeMins < (jummah.jamahTimeInMinutes-1) && showJummahLabel) {
      showTimerFor("Time to Jum'uah", jummah.jamahTimeInMinutes-CurrentTotalTimeMins, "minutes");
    } else if (!asr.isNextDay && CurrentTotalTimeMins >= (asr.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (asr.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(asr, CurrentTotalTimeMins);
    } else if (!maghrib.isNextDay && CurrentTotalTimeMins >= (maghrib.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (maghrib.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(maghrib, CurrentTotalTimeMins);
    } else if (!isha.isNextDay && CurrentTotalTimeMins >= (isha.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (isha.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(isha, CurrentTotalTimeMins);
    }

    // In Progress
    else if (!fajr.isNextDay && CurrentTotalTimeMins >= fajr.jamahTimeInMinutes && CurrentTotalTimeMins < (fajr.jamahTimeInMinutes + TenMinSalahInProgressOffset)) {
      showPrayerInProgressFor(fajr.name);
    } else if (!sunrise.isNextDay && CurrentTotalTimeMins >= sunrise.jamahTimeInMinutes && CurrentTotalTimeMins < (sunrise.jamahTimeInMinutes+SunriseOffset)) {
      showPrayerInProgressFor("sunrise");
    } else if (!dhuhrToShow.isNextDay && CurrentTotalTimeMins >= dhuhrToShow.jamahTimeInMinutes && CurrentTotalTimeMins < (dhuhrToShow.jamahTimeInMinutes + SalahInProgressOffset) && !showJummahLabel) {
      showPrayerInProgressFor("Dhuhr");
    } else if (!jummah.isNextDay && CurrentTotalTimeMins >= jummah.jamahTimeInMinutes && CurrentTotalTimeMins < (jummah.jamahTimeInMinutes + JummahLenghthMin) && showJummahLabel) {
      showPrayerInProgressFor("Jum'uah");
    } else if (!asr.isNextDay && CurrentTotalTimeMins >= asr.jamahTimeInMinutes && CurrentTotalTimeMins < (asr.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(asr.name);
    } else if (!maghrib.isNextDay && CurrentTotalTimeMins >= maghrib.jamahTimeInMinutes && CurrentTotalTimeMins < (maghrib.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(maghrib.name);
    } else if (!isha.isNextDay && CurrentTotalTimeMins >= isha.jamahTimeInMinutes && CurrentTotalTimeMins < (isha.jamahTimeInMinutes + TenMinSalahInProgressOffset)) {
      showPrayerInProgressFor(isha.name);
    }

    // Display Sunrise and Jum'uah times in right pane
    fill(0);
    stroke(0);
    rect(x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_BOTTOM_PANE_Y), x(LAYOUT_RIGHT_PANE_WIDTH), y(LAYOUT_BOTTOM_PANE_HEIGHT));
    textAlign(CENTER);
    safeTextFont(TodaysDateFont);
    fill(255);
    text("Sunrise " + sunrise.jamahTime + " | Jum'uah " + jummah.jamahTime , rtpanex, rtpaney+y(615));
  } // iterate whilst todays date is the date in the file
} // void draw()

/**
 Translates the value on the X axis
 */
int x(int x) {
  return int(float(x) * xRatio);
}

/**
 Translates the value on the Y axis
 */
int y(int y) {
  return int(float(y) * yRatio);
}

int salahTimeInMinutes(String timeInString, int hoursOffset, boolean isDhuhrORJumuah) {
  String[] timeArray = split(timeInString, ':');
  if (isDhuhrORJumuah) {
    int hour = parseInt(timeArray[0]);
    hoursOffset = hour<=10?12:0;
  }

  return (((parseInt(timeArray[0])+hoursOffset)*60) +  parseInt(timeArray[1]));
}

Times getTimesFor(String name, String colJamah, String colStart1, String colStart2, TableRow row, TableRow nextRow, int CurrentTotalTimeMins, int hoursOffset, boolean isDhuhrORJumuah, int dayOfWeek, int inProgressOffset) {
  // Safety check for null rows
  if (row == null) {
    logger.error("row is null in getTimesFor for " + name);
    return new Times(name, "00:00", "00:00", "", 0, 0, false);
  }

  String jamah = safeGetString(row, colJamah);
  String start1 = safeGetString(row, colStart1);
  String start2 = colStart2!=null?safeGetString(row, colStart2):"";

  // Safety check for null values
  if (jamah == null || jamah.isEmpty()) jamah = "00:00";
  if (start1 == null || start1.isEmpty()) start1 = "00:00";

  int jamahTimeInMinutes = salahTimeInMinutes(jamah, hoursOffset, isDhuhrORJumuah);
  int originalJamahTimeInMinutes = jamahTimeInMinutes; // Save original for condition check
  boolean isNextDay = false; // Track if we're showing next day's time

  //Set jummah's split time to show in progress
  if (safeGetString(row, "normal_day").equals(DAY_FRIDAY_NAME)){
    if (jamah.contains("/")) {
      String[] jamahs =  split(jamah,"/");
      int firstJummahEnd = salahTimeInMinutes(jamahs[0], hoursOffset, true)+JummahLenghthMin;
      int secondJummahEnd = salahTimeInMinutes(jamahs[1], hoursOffset, true)+JummahLenghthMin;

      // Only use split times if we haven't passed the last Jummah time
      if (firstJummahEnd >= CurrentTotalTimeMins) {
        jamahTimeInMinutes = salahTimeInMinutes(jamahs[0], hoursOffset, isDhuhrORJumuah);
      } else if (secondJummahEnd >= CurrentTotalTimeMins) {
        jamahTimeInMinutes = salahTimeInMinutes(jamahs[1], hoursOffset, true);
      }
      // If we've passed both Jummah times, keep the original jamahTimeInMinutes
    }
  }

  //Set next jummah's salah time and show dhur for saturday
  if (dayOfWeek == DAY_SATURDAY && (jamahTimeInMinutes+JummahLenghthMin <= CurrentTotalTimeMins)){
    if (nextRow != null) {
      start1 = safeGetString(nextRow, colStart1);
      start2 = colStart2!=null?safeGetString(nextRow, colStart2):"";
      jamah = safeGetString(nextRow, colJamah);
      jamahTimeInMinutes = salahTimeInMinutes(jamah, hoursOffset, isDhuhrORJumuah);
      isNextDay = true;
    }
  }

  //Show tomorrow's salah time after jamat in progress is finished
  // Don't apply this logic for Jummah (inProgressOffset == JummahLenghthMin)
  if (CurrentTotalTimeMins>=originalJamahTimeInMinutes+inProgressOffset && inProgressOffset != JummahLenghthMin) {
    if (nextRow != null) {
      jamah = safeGetString(nextRow, colJamah);
      start1 = safeGetString(nextRow, colStart1);
      start2 = colStart2!=null?safeGetString(nextRow, colStart2):"";
      jamahTimeInMinutes = salahTimeInMinutes(jamah, hoursOffset, isDhuhrORJumuah);
      isNextDay = true;
    }
  }

  return new Times(name, jamah, start1, start2, jamahTimeInMinutes, salahTimeInMinutes(start1, hoursOffset, isDhuhrORJumuah), isNextDay);
}

void show60SecondsTimerFor(Times prayer) {
  showTimerFor("Time to "+prayer.name, SalahCountDownStart - second(), "seconds");
}

void showMinutesTimerFor(Times prayer, int currentTotalTimeMins) {
  if (prayer.name == "Maghrib") {
    showTimerFor("Time to "+prayer.name, prayer.startTimeInMinutes-currentTotalTimeMins, "minutes");
  } else {
    showTimerFor("Time to "+prayer.name, prayer.jamahTimeInMinutes-currentTotalTimeMins, "minutes");
  }
}

void showTimerFor(String text, int amount, String unit) {
  drawRightPaneBackground();
  fill(255);
  safeTextFont(SalahTimeFont);
  textAlign(CENTER);
  text(text, rtpanex, rtpaney-y(800));
  safeTextFont(LargeCountDownFont);
  textAlign(CENTER);
  text(amount, rtpanex, rtpaney+y(200));
  safeTextFont(SalahTimeFont);
  textAlign(CENTER);
  text(unit, rtpanex, rtpaney+y(450));
}

void showPrayerInProgressFor(String salahName) {
  drawRightPaneBackground();
  fill(255);
  safeTextFont(SalahNameFont);
  textAlign(CENTER);
  textSize(x(300));
  text(salahName, rtpanex, rtpaney-y(300));
  safeTextFont(SalahTimeFont);
  textAlign(CENTER);
  text("in progress", rtpanex, rtpaney-y(50));
}

// Helper function to safely set fonts with fallback
void safeTextFont(PFont font) {
  if (font != null) {
    textFont(font);
  } else {
    // Fallback to default font if the specified font is null
    textFont(createFont("Arial", 16));
  }
}

// Helper function to draw right pane background
void drawRightPaneBackground() {
  fill(rightpanecolour);
  stroke(0);
  rect(x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_RIGHT_PANE_Y), x(LAYOUT_RIGHT_PANE_WIDTH), y(LAYOUT_RIGHT_PANE_HEIGHT));
}

// Helper function to safely get string from table row with null check
String safeGetString(TableRow row, String columnName) {
  if (row == null) return "";
  String value = row.getString(columnName);
  return (value == null) ? "" : value;
}

class Times {
  String name;
  String jamahTime;
  String startTime1;
  String startTime2;
  int jamahTimeInMinutes;
  int startTimeInMinutes;
  boolean isNextDay;

  Times(String name, String jamahTime, String startTime1, String startTime2, int jamahTimeInMinutes, int startTimeInMInutes) {    
    this.name = name;
    this.jamahTime = jamahTime;
    this.startTime1 = startTime1;
    this.startTime2 = startTime2;
    this.jamahTimeInMinutes = jamahTimeInMinutes;
    this.startTimeInMinutes = startTimeInMInutes;
    this.isNextDay = false;
  }

  Times(String name, String jamahTime, String startTime1, String startTime2, int jamahTimeInMinutes, int startTimeInMInutes, boolean isNextDay) {    
    this.name = name;
    this.jamahTime = jamahTime;
    this.startTime1 = startTime1;
    this.startTime2 = startTime2;
    this.jamahTimeInMinutes = jamahTimeInMinutes;
    this.startTimeInMinutes = startTimeInMInutes;
    this.isNextDay = isNextDay;
  }
}
