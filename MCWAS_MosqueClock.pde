
// Copyright Pilgrim Media Productions
// Author Shiraz Chanawala

import java.util.Calendar;

int y;
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
int reloadInterval = 60 * 60 * 1000; // 1 hour in milliseconds

void setup() {

  //size(3840, 2160);
  //viewWidth = 1280;
  //viewHeight = 720;
  //size(1280, 720);

  fullScreen(P2D);
  viewWidth = displayWidth;
  viewHeight = displayHeight;

  xRatio = float(viewWidth) / float(MAX_WIDTH);
  yRatio = float(viewHeight) / float(MAX_HEIGHT);
  rtpanex = int(x(3122));
  rtpaney = int(y(1500));
  frameRate(2);

  rightpane = loadImage("images/mosque_clock_right_pane_whatsapp.png");
  rightpane.resize(x(rightpane.width), y(rightpane.height));
  logo = loadImage("images/mosque_logo.png");
  logo.resize(x(logo.width), y(logo.height));
  leftBottomPane = loadImage("images/mosque_clock_left_bottom_pane_switch_off_old.png");
  leftBottomPane.resize(x(leftBottomPane.width), y(leftBottomPane.height));


  TimeFont = createFont("font/AvenirNextLTPro-Regular.otf", x(300));
  SalahTimeFont = createFont("font/AvenirNextLTPro-Regular.otf", x(160));
  SalahTimeFontBold = createFont("font/AvenirNextLTPro-Bold.otf", x(160));
  SalahTimeFontHeading = createFont("font/AvenirNextLTPro-Regular.otf", x(104));
  TodaysDateFont = createFont("font/AvenirNextLTPro-Regular.otf", x(90));
  CountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", x(700));
  LargeCountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", x(900));
  SalahNameFont = createFont("font/AvenirNextLTPro-Regular.otf", x(600));
  
  reloadTable(); // Load the table initially

}

// Load the timetable file
void reloadTable(){
  try {
    if (fileUrl.length()>1) {
      println("Loading table from "+fileUrl + " at " +getCurrentTime() );
      table = loadTable(fileUrl, "header,csv");
    } else {
      println("fileUrl is empty. Loading local file.");
      table = loadTable("data/mcwas_prayer_timetable_2025.csv", "header");
    }
  } catch (Exception e ) {
    println(e);
    table = null;
  }
  
  if (table==null) {
    println("Loading from fileUrl failed.  Loading local file.");
    table = loadTable("data/mcwas_prayer_timetable_2025.csv", "header");
  }
}

String getCurrentTime() {
  return hour() + ":" + minute() + ":" + second();
}

void draw() {
  
  if (millis() - lastReloadTime > reloadInterval){
    reloadTable();
    lastReloadTime = millis();
  }

  // Set Background
  // Construct the canvas
  // Canvas Background
  stroke(0);
  fill(backgroundcolor);
  rect(0, 0, viewWidth, viewHeight);

  // Time Background
  stroke(0);
  fill(0);
  rect(0, 0, x(2400), y(400));

  // Logo
  image(logo, x(2400), 0);

  // Right Pane background and default image
  fill(rightpanecolour);
  stroke(0);
  rect(x(2400), y(400), x(1440), y(1760));
  image(rightpane, x(2400), y(400));
  //image(leftBottomPane, x(400), y(2000));

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

  //Build the clock
  String s0 = str((s));
  if (s0.length() == 1) {
    s0 = "0" + s0;
  };
  String m0 = str((mi));
  if (m0.length() == 1) {
    m0 = "0" + m0;
  };
  String h0 = str((h));
  if (h0.length() == 1) {
    h0 = "0" + h0;
  };

  // Time String stored in Time variable
  if (hdisplay>12) {
    hdisplay = hdisplay-12;
  };
  String Time = (hdisplay) + ":" + (m0) + ":" + s0;

  //Convert Month to 3 character Month
  if (m==1) {
    mmm = "Jan";
  }
  if (m==2) {
    mmm = "Feb";
  }
  if (m==3) {
    mmm = "Mar";
  }
  if (m==4) {
    mmm = "Apr";
  }
  if (m==5) {
    mmm = "May";
  }
  if (m==6) {
    mmm = "Jun";
  }
  if (m==7) {
    mmm = "Jul";
  }
  if (m==8) {
    mmm = "Aug";
  }
  if (m==9) {
    mmm = "Sep";
  }
  if (m==10) {
    mmm = "Oct";
  }
  if (m==11) {
    mmm = "Nov";
  }
  if (m==12) {
    mmm = "Dec";
  }

  // Construct Todays Date for compare
  String dsi = str(d);
  //String msi = str(mmm);
  TodaysDate = (dsi + " " + mmm);
  TableRow row = table.findRow(TodaysDate, "normal_date");
  if (row==null) {
    // Error Message
    fill(255);
    textAlign(LEFT);
    textFont(createFont("font/AvenirNextLTPro-Regular.otf", x(50)));
    text("No row found for date '"+TodaysDate +"' in the spreadsheet", x(10), y(320));
    return;
  }

  FullTodaysDate = (TodaysDate + " " + str(yr));
  CurrentTotalTimeMins = h*60 + mi;

  int rowNum = row.getInt("month_num");
  int nextRowIndex = rowNum % table.getRowCount(); //because rowIndex is always rowNum-1;

  TableRow nextRow = table.getRow(nextRowIndex);  

  String Date = row.getString("normal_date");
  String Day = row.getString("normal_day");
    
    //   Calculate Jumuah time from the spreadsheet.
  int ZeroBasedDayOfWeek = dayOfWeek-1;
  int daysToAddToReachFriday = ZeroBasedDayOfWeek==6?6:(5-ZeroBasedDayOfWeek);
  int jumuahRowIndex = (rowNum-1+daysToAddToReachFriday) % table.getRowCount(); // -1 because rowIndex is always rowNum-1;
  int nextJumuahRowIndex = (jumuahRowIndex+7) % table.getRowCount();
  TableRow jumuahRow = table.getRow(jumuahRowIndex);
  TableRow nextJumuahRow = table.getRow(nextJumuahRowIndex);

  Times fajr = getTimesFor("Fajr", "fajr_jamah", "fajr_start", null, row, nextRow, CurrentTotalTimeMins, 0, false);
  Times sunrise = getTimesFor("Sunrise", "sunrise", "sunrise", null, row, nextRow, CurrentTotalTimeMins, 0, false);
  Times dhuhr = getTimesFor("Dhuhr", "dhuhr_jamah", "dhuhr_start", null, row, nextRow, CurrentTotalTimeMins, 0, true);
  Times asr = getTimesFor("Asr", "asr_jamah", "asr_mitl_1", "asr_mitl_2", row, nextRow, CurrentTotalTimeMins, 12, false);
  Times maghrib = getTimesFor("Maghrib", "maghrib_jamah","maghrib_start", null, row, nextRow, CurrentTotalTimeMins, 12, false);
  Times isha = getTimesFor("Isha", "isha_jamah", "isha_start", null, row, nextRow, CurrentTotalTimeMins, 12, false);
  Times jummah = getTimesFor("Dhuhr", "dhuhr_jamah", "dhuhr_start", null, jumuahRow, nextJumuahRow, CurrentTotalTimeMins, 0, false);

  int KarahatTime = dhuhr.startTimeInMinutes - KarahatTimeOffset;
    
  // Hijri Date
  TableRow hiriDateRow = CurrentTotalTimeMins < maghrib.startTimeInMinutes ? row : nextRow;
  String HijriDate = hiriDateRow.getString("hijri_date");
  String HijriMonth = hiriDateRow.getString("hijri_month");
  String HijriYear = hiriDateRow.getString("hijri_year");
  //String FullTodaysDateWithHijri = "";

  // Create Date to display which is Gregoran and Hijri Date
  FullHijriDate = (HijriDate + " " + HijriMonth + " " + HijriYear);

  // Print Time and Todays Date First
  if (Date.equals(TodaysDate) == true) {
    // Large Clock
    fill(255);
    textAlign(LEFT);
    textFont(TimeFont);
    text(Time, x(10), y(320));

    // Gregorian Date display
    fill(255);
    textAlign(RIGHT);
    textFont(TodaysDateFont);
    text(FullTodaysDate, x(2350), y(200));

    // Hijri Date display
    fill(255);
    textAlign(RIGHT);
    textFont(TodaysDateFont);
    text(FullHijriDate, x(2350), y(320));

    // Salah Text Allignment
    int snax = x(50); //Salah name row
    int snay = y(848);
    int snay_gap = y(280);
    int stabx = x(800); //Begins row
    int stasx = x(2300); //Jamat row


    //*** Debug - uncomment if required
    //println("Todays Date: " + Date);
    //println("Time Now   : " + h + ":"+ mi);
    //println("Current Total Time in Mins: " +  CurrentTotalTimeMins);
    //println("TimeNow:" + Time + "  FajrTime    : "     + FajrHrs      + ":"   + FajrMin      + " Array: "   + FajrJamah    +  " Array Length: "  + FajrArray.length  + " Fajr Total Min: " + FajrTotalTimeMins);
    //println("TimeNow:" + Time + "  DhurTime    : "     + DhuhrHrs     + ":"   + DhuhrMin     + " Array: "   + DhuhrJamah   +  " Array Length: "  + DhuhrArray.length  + " Dhur Total Min: " + dhuhr.timeInMinutes);
    //println("TimeNow:" + Time + "  AsrTime     : "     + AsrHrs       + ":"   + AsrMin       + " Array: "   + AsrJamah   +  " Array Length: "  + AsrArray.length  + " Asr Total Min: " + AsrTotalTimeMins);
    //println("TimeNow:" + Time + "  MaghribTime : "     + MaghribHrs   + ":"   + MaghribMin   + " Array: "   + MaghribJamah   +  " Array Length: "  + MaghribArray.length  + " Maghrib Total Min: " + MaghribTotalTimeMins);
    //println("TimeNow:" + Time + "  IshaTime    : "     + IshaHrs      + ":"   + IshaMin      + " Array: "   + IshaJamah   +  " Array Length: "  + IshaArray.length  + " Isha Total Min: " + IshaTotalTimeMins);

    // *** DISPLAY HEADINGS ****
    fill(255);
    textFont(SalahTimeFontHeading);
    textAlign(LEFT);
    textFont(TodaysDateFont);
    text("BEGINS", stabx, y(600));
    textFont(TodaysDateFont);
    textAlign(RIGHT);
    text("JAMAAT", stasx, y(600));

    // *** DISPLAY SALAH NAMES
    textFont(SalahTimeFont);
    textAlign(LEFT);
    text("Fajr", snax, snay);
    
    // Substitute Jummah for Dhuhr on Fridays
  
   if ((dayOfWeek == 5 && h >= 14) || (dayOfWeek == 6 && h < 15)) { 
      text("Jum'uah", snax, snay+snay_gap);
    } else {
      text("Dhuhr", snax, snay+snay_gap);
    }

    text("Asr", snax, (snay+2*snay_gap));
    text("Maghrib", snax, snay+3*snay_gap);
    text("Isha", snax, snay+4*snay_gap);

    // *** DISPLAY SALAH JAMAH TIMES
    textFont(SalahTimeFontBold);
    textAlign(RIGHT);

    // Set Prayer Times
    text(fajr.jamahTime, stasx, snay);
    text(dhuhr.jamahTime, stasx, snay+snay_gap);
    text(asr.jamahTime, stasx, snay+2*snay_gap);
    text(maghrib.jamahTime, stasx, snay+3*snay_gap);
    text(isha.jamahTime, stasx, snay+4*snay_gap);

    // *** DISPLAY SALAH JAMAH BEGIN TIMES
    textFont(SalahTimeFont);
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
    } else if (CurrentTotalTimeMins == dhuhr.jamahTimeInMinutes-1 && !Day.equals("Fri")) {
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
    } else if (CurrentTotalTimeMins >= KarahatTime && CurrentTotalTimeMins < dhuhr.startTimeInMinutes) {
      showTimerFor("Zawal Time", dhuhr.startTimeInMinutes-CurrentTotalTimeMins, "minutes");
    } else if (CurrentTotalTimeMins >= (dhuhr.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (dhuhr.jamahTimeInMinutes-1) && !Day.equals("Fri")) {
      showMinutesTimerFor(dhuhr, CurrentTotalTimeMins);
    } else if (CurrentTotalTimeMins >= (asr.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (asr.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(asr, CurrentTotalTimeMins);
    } else if (CurrentTotalTimeMins >= (maghrib.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (maghrib.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(maghrib, CurrentTotalTimeMins);
    } else if (CurrentTotalTimeMins >= (isha.jamahTimeInMinutes-LargeCountDown) && CurrentTotalTimeMins < (isha.jamahTimeInMinutes-1)) {
      showMinutesTimerFor(isha, CurrentTotalTimeMins);
    }

    // In Progress
    else if (CurrentTotalTimeMins >= fajr.jamahTimeInMinutes && CurrentTotalTimeMins < (fajr.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(fajr.name);
    } else if (CurrentTotalTimeMins >= sunrise.jamahTimeInMinutes && CurrentTotalTimeMins < (sunrise.jamahTimeInMinutes+SunriseOffset)) {
      showPrayerInProgressFor("sunrise");
    } else if (CurrentTotalTimeMins >= dhuhr.jamahTimeInMinutes && CurrentTotalTimeMins < (dhuhr.jamahTimeInMinutes + SalahInProgressOffset) && !Day.equals("Fri")) {
      showPrayerInProgressFor(dhuhr.name);       
    } else if (CurrentTotalTimeMins >= dhuhr.jamahTimeInMinutes && CurrentTotalTimeMins <(dhuhr.jamahTimeInMinutes + JummahLenghthMin) && Day.equals("Fri")) {  
      showPrayerInProgressFor("Jum'uah");   
    } else if (CurrentTotalTimeMins >= asr.jamahTimeInMinutes && CurrentTotalTimeMins < (asr.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(asr.name);
    } else if (CurrentTotalTimeMins >= maghrib.jamahTimeInMinutes && CurrentTotalTimeMins < (maghrib.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(maghrib.name);
    } else if (CurrentTotalTimeMins >= isha.jamahTimeInMinutes && CurrentTotalTimeMins < (isha.jamahTimeInMinutes + SalahInProgressOffset)) {
      showPrayerInProgressFor(isha.name);
    }

    // Display Sunrise and Jum'uah times in right pane
    fill(0);
    stroke(0);
    rect(x(2400), y(1996), x(1440), y(164));
    textAlign(CENTER);
    textFont(TodaysDateFont);
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

Times getTimesFor(String name, String colJamah, String colStart1, String colStart2, TableRow row, TableRow nextRow, int CurrentTotalTimeMins, int hoursOffset, boolean isDhuhrORJumuah) {
  String jamah = row.getString(colJamah);
  String start1 = row.getString(colStart1);
  String start2 = colStart2!=null?row.getString(colStart2):"";
  int jamahTimeInMinutes = salahTimeInMinutes(jamah, hoursOffset, isDhuhrORJumuah);

  //Set jummah's split time to show in progress    
  if (row.getString("normal_day").equals("Fri") == true){ 
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
  if (Calendar.getInstance().get(Calendar.DAY_OF_WEEK) == 6 && (jamahTimeInMinutes+JummahLenghthMin <= CurrentTotalTimeMins)){
    start1 = nextRow.getString(colStart1);
    start2 = colStart2!=null?nextRow.getString(colStart2):"";
    jamah = nextRow.getString(colJamah);
  }

  //Show tomorrow's salah time   
  if ((CurrentTotalTimeMins>=jamahTimeInMinutes+NextDayTriggerInMinutes) && !row.getString("normal_day").equals("Fri")) {
    jamah = nextRow.getString(colJamah);
    start1 = nextRow.getString(colStart1);
    start2 = colStart2!=null?nextRow.getString(colStart2):"";
  }

  return new Times(name, jamah, start1, start2, jamahTimeInMinutes, salahTimeInMinutes(start1, hoursOffset, isDhuhrORJumuah));
}

void show60SecondsTimerFor(Times prayer) {
  showTimerFor("Time to "+prayer.name, SalahCountDownStart - second(), "seconds");
}

void showMinutesTimerFor(Times prayer, int currentTotalTimeMins) {
  fill(currentTotalTimeMins);
  if (prayer.name == "Maghrib") {
    showTimerFor("Time to "+prayer.name, prayer.startTimeInMinutes-currentTotalTimeMins, "minutes");         
  } else {
    showTimerFor("Time to "+prayer.name, prayer.jamahTimeInMinutes-currentTotalTimeMins, "minutes");
  }

}

void showTimerFor(String text, int amount, String unit) {
  fill(rightpanecolour);
  stroke(0);
  rect(x(2400), y(400), x(1440), y(1760));
  fill(255);
  textFont(SalahTimeFont);
  textAlign(CENTER);
  text(text, rtpanex, rtpaney-y(800));
  textFont(LargeCountDownFont);
  textAlign(CENTER);
  text(amount, rtpanex, rtpaney+y(200));
  textFont(SalahTimeFont);
  textAlign(CENTER);
  text(unit, rtpanex, rtpaney+y(450));
}

void showPrayerInProgressFor(String salahName) {
  fill(rightpanecolour);
  stroke(0);
  rect(x(2400), y(400), x(1440), y(1760));
  fill(255);
  textFont(SalahNameFont);
  textAlign(CENTER);
  textSize(x(300));
  text(salahName, rtpanex, rtpaney-y(300));
  textFont(SalahTimeFont);
  textAlign(CENTER);
  text("in progress", rtpanex, rtpaney-y(50));
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
