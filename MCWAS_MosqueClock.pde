
// Copyright Pilgrim Media Productions
// Author Shiraz Chanawala

import java.util.Calendar;

int rtpanex = 3122;
int rtpaney = 1500;
PImage rightpane;
PImage leftBottomPane;
PImage logo;
int viewWidth;
int viewHeight;
int MAX_WIDTH = 3840;
int MAX_HEIGHT = 2160;
float xRatio;
float yRatio;
Table table;

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
int reloadInterval = 5 * 60 * 1000; // 5 min in milliseconds
volatile boolean isReloading = false;
Table backupTable;

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

// Layout coordinate constants (base values before scaling)
final int LAYOUT_RIGHT_PANE_X = 2400;
final int LAYOUT_RIGHT_PANE_Y = 400;
final int LAYOUT_RIGHT_PANE_WIDTH = 1440;
final int LAYOUT_RIGHT_PANE_HEIGHT = 1760;
final int LAYOUT_TIME_BACKGROUND_HEIGHT = 400;
final int LAYOUT_LEFT_MARGIN = 10;
final int LAYOUT_SALAH_NAME_X = 50;
final int LAYOUT_SALAH_NAME_Y = 848;
final int LAYOUT_SALAH_GAP = 280;
final int LAYOUT_BEGINS_ROW_X = 800;
final int LAYOUT_JAMAAT_ROW_X = 2300;
final int LAYOUT_HEADINGS_Y = 600;
final int LAYOUT_TIME_Y = 320;
final int LAYOUT_DATE_Y = 200;
final int LAYOUT_LOGO_Y = 20;
final int LAYOUT_ERROR_BOX_Y = 280;
final int LAYOUT_BOTTOM_PANE_Y = 1996;
final int LAYOUT_BOTTOM_PANE_HEIGHT = 164;

void setup() {

  fullScreen(P2D);
  pixelDensity(1);
  viewWidth = displayWidth;
  viewHeight = displayHeight;

  xRatio = float(viewWidth) / float(MAX_WIDTH);
  yRatio = float(viewHeight) / float(MAX_HEIGHT);
  rtpanex = int(x(3122));
  rtpaney = int(y(1500));
  frameRate(30);

  // Load images with error handling using helper function
  rightpane = loadImageSafely("images/mosque_clock_right_pane_whatsapp.png", "rightpane");
  logo = loadImageSafely("images/mosque_logo.png", "logo");
  leftBottomPane = loadImageSafely("images/mosque_clock_left_bottom_pane_switch_off_old.png", "leftBottomPane");


  // Load fonts with error handling using helper function
  TimeFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(300), "TimeFont");
  SalahTimeFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(160), "SalahTimeFont");
  SalahTimeFontBold = loadFontSafely("font/AvenirNextLTPro-Bold.otf", x(160), "SalahTimeFontBold");
  SalahTimeFontHeading = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(104), "SalahTimeFontHeading");
  TodaysDateFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(90), "TodaysDateFont");
  CountDownFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(700), "CountDownFont");
  LargeCountDownFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(900), "LargeCountDownFont");
  SalahNameFont = loadFontSafely("font/AvenirNextLTPro-Regular.otf", x(600), "SalahNameFont");
  
  reloadTable(); // Load the table initially

}

// Helper function to load fonts with error handling
PFont loadFontSafely(String fontPath, float fontSize, String fontName) {
  try {
    PFont font = createFont(fontPath, fontSize);
    if (font == null) {
      println("Warning: Failed to load " + fontName);
    }
    return font;
  } catch (Exception e) {
    println("Error loading " + fontName + ": " + e.getMessage());
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

// Helper function to load images with error handling
PImage loadImageSafely(String imagePath, String imageName) {
  try {
    PImage img = loadImage(imagePath);
    if (img != null) {
      img.resize(x(img.width), y(img.height));
    } else {
      println("Warning: Failed to load " + imageName);
    }
    return img;
  } catch (Exception e) {
    println("Error loading " + imageName + ": " + e.getMessage());
    return null;
  }
}

// Load the timetable file
void reloadTable(){
  if (isReloading) {
    println("Reload already in progress, skipping...");
    return;
  }

  isReloading = true;
  Table newTable = null;

  try {
    println("Starting table reload at " + getCurrentTime());

    if (fileUrl.length()>1) {
      // Try loading from URL with proper HTTPS handling
      try {
        java.net.URL url = new java.net.URL(fileUrl);
        java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(30000); // 30 second timeout
        conn.setReadTimeout(30000);    // 30 second read timeout
        conn.setInstanceFollowRedirects(true); // Follow redirects
        
        int responseCode = conn.getResponseCode();
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
            println("Successfully loaded table from URL");
          } finally {
            // Close resources in finally block to prevent leaks
            if (reader != null) {
              try { reader.close(); } catch (Exception e) { println("Error closing reader: " + e.getMessage()); }
            }
            if (is != null) {
              try { is.close(); } catch (Exception e) { println("Error closing input stream: " + e.getMessage()); }
            }
            if (writer != null) {
              try { writer.close(); } catch (Exception e) { println("Error closing writer: " + e.getMessage()); }
            }
            if (tempFile != null && tempFile.exists()) {
              tempFile.delete();
            }
          }
        } else {
          println("URL load failed with HTTP code: " + responseCode + ", falling back to local file");
          newTable = null;
        }
        conn.disconnect();
      } catch (Exception e) {
        println("URL load failed: " + e.getMessage() + ", falling back to local file");
        e.printStackTrace();
        newTable = null;
      }
    }

    // Fallback to local file if URL load failed or not configured
    if (newTable == null) {
      println("Loading local file...");
      String filename = getDataFilename();
      try {
        newTable = loadTable(filename, "header");
        if (newTable != null && newTable.getRowCount() > 0) {
          println("Successfully loaded local table: " + filename);
        } else {
          println("Warning: Local table loaded but is null or empty");
          newTable = null;
        }
      } catch (Exception e) {
        println("Error loading local file: " + e.getMessage());
        e.printStackTrace();
        newTable = null;
      }
    }

    // Only update the main table if load was successful
    if (newTable != null && newTable.getRowCount() > 0) {
      backupTable = table; // Keep current table as backup
      table = newTable;
      println("Table reloaded successfully at " + getCurrentTime());
    } else {
      println("Reload failed: table is null or empty, keeping current table");
    }

  } catch (Exception e) {
    println("Exception during reload: " + e.getMessage());
    e.printStackTrace();
    // Keep the existing table if reload fails
    if (table == null && backupTable != null) {
      println("Restoring from backup table");
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

  // Always draw background first to prevent white screen
  stroke(0);
  fill(backgroundcolor);
  rect(0, 0, viewWidth, viewHeight);

  if (millis() - lastReloadTime > reloadInterval){
    lastReloadTime = millis();
    thread("reloadTable");
  }

  // Safety check: if table is null, try to reload it synchronously
  if (table == null) {
    println("Table is null, attempting emergency reload...");
    try {
      String filename = getDataFilename();
      table = loadTable(filename, "header");
      if (table != null && table.getRowCount() > 0) {
        println("Emergency reload completed: " + filename);
      } else {
        println("Emergency reload failed: table is null or empty");
        throw new Exception("Loaded table is null or empty");
      }
    } catch (Exception e) {
      println("Emergency reload failed: " + e.getMessage());
      e.printStackTrace();
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
    image(logo, x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_LOGO_Y));
  } else {
    println("Warning: Logo image is null, skipping display");
  }

  // Right Pane background and default image
  fill(rightpanecolour);
  stroke(0);
  rect(x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_RIGHT_PANE_Y), x(LAYOUT_RIGHT_PANE_WIDTH), y(LAYOUT_RIGHT_PANE_HEIGHT));
  if (rightpane != null) {
    image(rightpane, x(LAYOUT_RIGHT_PANE_X), y(LAYOUT_RIGHT_PANE_Y));
  } else {
    println("Warning: Right pane image is null, skipping display");
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
    println("Warning: nextRow is null for index " + nextRowIndex);
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
    println("Warning: jumuahRow is null for index " + jumuahRowIndex);
    jumuahRow = row; // Fallback to current row
  }
  if (nextJumuahRow == null) {
    println("Warning: nextJumuahRow is null for index " + nextJumuahRowIndex);
    nextJumuahRow = nextRow; // Fallback to next row
  }

  Times fajr = getTimesFor("Fajr", "fajr_jamah", "fajr_start", null, row, nextRow, CurrentTotalTimeMins, 0, false, dayOfWeek);
  Times sunrise = getTimesFor("Sunrise", "sunrise", "sunrise", null, row, nextRow, CurrentTotalTimeMins, 0, false, dayOfWeek);
  Times dhuhr = getTimesFor("Dhuhr", "dhuhr_jamah", "dhuhr_start", null, row, nextRow, CurrentTotalTimeMins, 0, true, dayOfWeek);
  Times asr = getTimesFor("Asr", "asr_jamah", "asr_mitl_1", "asr_mitl_2", row, nextRow, CurrentTotalTimeMins, 12, false, dayOfWeek);
  Times maghrib = getTimesFor("Maghrib", "maghrib_jamah","maghrib_start", null, row, nextRow, CurrentTotalTimeMins, 12, false, dayOfWeek);
  Times isha = getTimesFor("Isha", "isha_jamah", "isha_start", null, row, nextRow, CurrentTotalTimeMins, 12, false, dayOfWeek);
  Times jummah = getTimesFor("Dhuhr", "dhuhr_jamah", "dhuhr_start", null, jumuahRow, nextJumuahRow, CurrentTotalTimeMins, 0, false, dayOfWeek);

  int karahatTime = dhuhr.startTimeInMinutes - KarahatTimeOffset;
    
  // Hijri Date
  TableRow hiriDateRow = CurrentTotalTimeMins < maghrib.startTimeInMinutes ? row : nextRow;
  String HijriDate = safeGetString(hiriDateRow, "hijri_date");
  String HijriMonth = safeGetString(hiriDateRow, "hijri_month");
  String HijriYear = safeGetString(hiriDateRow, "hijri_year");

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
    
    // Substitute Jummah for Dhuhr on Fridays

   if ((dayOfWeek == DAY_FRIDAY && h >= 14) || (dayOfWeek == DAY_SATURDAY && h < 15)) { 
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
    text(dhuhr.jamahTime, stasx, snay+snay_gap);
    text(asr.jamahTime, stasx, snay+2*snay_gap);
    text(maghrib.jamahTime, stasx, snay+3*snay_gap);
    text(isha.jamahTime, stasx, snay+4*snay_gap);

    // *** DISPLAY SALAH JAMAH BEGIN TIMES
    safeTextFont(SalahTimeFont);
    textAlign(LEFT);

    text(fajr.startTime1, stabx, snay);
    text(dhuhr.startTime1, stabx, snay+snay_gap);
    // Set Asr Begins Time - we need to show Mitl 1 and Mitl 2
    text(asr.startTime1 + "/" + asr.startTime2, stabx, snay+2*snay_gap);
    text(maghrib.startTime1, stabx, snay+3*snay_gap);
    text(isha.startTime1, stabx, snay+4*snay_gap);


    // ** Right Pane Text //
    // 60 seconds timer.
    if (CurrentTotalTimeMins == fajr.jamahTimeInMinutes-1) {
      show60SecondsTimerFor(fajr);
    } else if (CurrentTotalTimeMins == dhuhr.jamahTimeInMinutes-1 && !Day.equals(DAY_FRIDAY_NAME)) {
      show60SecondsTimerFor(dhuhr);
    } else if (CurrentTotalTimeMins == asr.jamahTimeInMinutes-1) {
      show60SecondsTimerFor(asr);
    } else if (CurrentTotalTimeMins == maghrib.startTimeInMinutes-1) {
      show60SecondsTimerFor(maghrib);
    } else if (CurrentTotalTimeMins == isha.jamahTimeInMinutes-1) {
      show60SecondsTimerFor(isha);
    }
    // Minute Timers
    else if ((CurrentTotalTimeMins > fajr.jamahTimeInMinutes-LargeCountDown && CurrentTotalTimeMins < fajr.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(fajr, CurrentTotalTimeMins);
    } else if (CurrentTotalTimeMins >= karahatTime && CurrentTotalTimeMins < dhuhr.startTimeInMinutes) {
      showTimerFor("Zawal Time", dhuhr.startTimeInMinutes-CurrentTotalTimeMins, "minutes");
    } else if (CurrentTotalTimeMins >= (dhuhr.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (dhuhr.jamahTimeInMinutes-1) && !Day.equals(DAY_FRIDAY_NAME)) {
      showMinutesTimerFor(dhuhr, CurrentTotalTimeMins);
    } else if (CurrentTotalTimeMins >= (asr.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (asr.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(asr, CurrentTotalTimeMins);
    } else if (CurrentTotalTimeMins >= (maghrib.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (maghrib.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(maghrib, CurrentTotalTimeMins);
    } else if (CurrentTotalTimeMins >= (isha.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (isha.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(isha, CurrentTotalTimeMins);
    }

    // In Progress
    else if (CurrentTotalTimeMins >= fajr.jamahTimeInMinutes && CurrentTotalTimeMins < (fajr.jamahTimeInMinutes + TenMinSalahInProgressOffset)) {
      showPrayerInProgressFor(fajr.name);
    } else if (CurrentTotalTimeMins >= sunrise.jamahTimeInMinutes && CurrentTotalTimeMins < (sunrise.jamahTimeInMinutes+SunriseOffset)) {
      showPrayerInProgressFor("sunrise");
    } else if (CurrentTotalTimeMins >= dhuhr.jamahTimeInMinutes && CurrentTotalTimeMins < (dhuhr.jamahTimeInMinutes + SalahInProgressOffset) && !Day.equals(DAY_FRIDAY_NAME)) {
      showPrayerInProgressFor(dhuhr.name);       
    } else if (CurrentTotalTimeMins >= dhuhr.jamahTimeInMinutes && CurrentTotalTimeMins <(dhuhr.jamahTimeInMinutes + JummahLenghthMin) && Day.equals(DAY_FRIDAY_NAME)) {  
      showPrayerInProgressFor("Jum'uah");   
    } else if (CurrentTotalTimeMins >= asr.jamahTimeInMinutes && CurrentTotalTimeMins < (asr.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(asr.name);
    } else if (CurrentTotalTimeMins >= maghrib.jamahTimeInMinutes && CurrentTotalTimeMins < (maghrib.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(maghrib.name);
    } else if (CurrentTotalTimeMins >= isha.jamahTimeInMinutes && CurrentTotalTimeMins < (isha.jamahTimeInMinutes + TenMinSalahInProgressOffset)) {
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

Times getTimesFor(String name, String colJamah, String colStart1, String colStart2, TableRow row, TableRow nextRow, int CurrentTotalTimeMins, int hoursOffset, boolean isDhuhrORJumuah, int dayOfWeek) {
  // Safety check for null rows
  if (row == null) {
    println("Error: row is null in getTimesFor for " + name);
    return new Times(name, "00:00", "00:00", "", 0, 0);
  }

  String jamah = safeGetString(row, colJamah);
  String start1 = safeGetString(row, colStart1);
  String start2 = colStart2!=null?safeGetString(row, colStart2):"";

  // Safety check for null values
  if (jamah == null || jamah.isEmpty()) jamah = "00:00";
  if (start1 == null || start1.isEmpty()) start1 = "00:00";

  int jamahTimeInMinutes = salahTimeInMinutes(jamah, hoursOffset, isDhuhrORJumuah);

  //Set jummah's split time to show in progress
  if (safeGetString(row, "normal_day").equals(DAY_FRIDAY_NAME)){ 
    if (jamah.contains("/")) {
      String[] jamahs =  split(jamah,"/");
      if ((salahTimeInMinutes(jamahs[0], hoursOffset, true)+JummahLenghthMin)>=CurrentTotalTimeMins) {
        jamahTimeInMinutes = salahTimeInMinutes(jamahs[0], hoursOffset, isDhuhrORJumuah);
      } else if ((salahTimeInMinutes(jamahs[1], hoursOffset, true)+JummahLenghthMin)>=CurrentTotalTimeMins) {
        jamahTimeInMinutes = salahTimeInMinutes(jamahs[1], hoursOffset, true);
      }
    }
  }

  //Set next jummah's salah time and show dhur for saturday
  if (dayOfWeek == DAY_SATURDAY && (jamahTimeInMinutes+JummahLenghthMin <= CurrentTotalTimeMins)){
    if (nextRow != null) {
      start1 = safeGetString(nextRow, colStart1);
      start2 = colStart2!=null?safeGetString(nextRow, colStart2):"";
      jamah = safeGetString(nextRow, colJamah);
    }
  }

  //Show tomorrow's salah time
  if ((CurrentTotalTimeMins>=jamahTimeInMinutes+NextDayTriggerInMinutes) && !safeGetString(row, "normal_day").equals(DAY_FRIDAY_NAME)) {
    if (nextRow != null) {
      jamah = safeGetString(nextRow, colJamah);
      start1 = safeGetString(nextRow, colStart1);
      start2 = colStart2!=null?safeGetString(nextRow, colStart2):"";
    }
  }

  return new Times(name, jamah, start1, start2, jamahTimeInMinutes, salahTimeInMinutes(start1, hoursOffset, isDhuhrORJumuah));
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

  Times(String name, String jamahTime, String startTime1, String startTime2, int jamahTimeInMinutes, int startTimeInMInutes) {    
    this.name = name;
    this.jamahTime = jamahTime;
    this.startTime1 = startTime1;
    this.startTime2 = startTime2;
    this.jamahTimeInMinutes = jamahTimeInMinutes;
    this.startTimeInMinutes = startTimeInMInutes;
  }
}
