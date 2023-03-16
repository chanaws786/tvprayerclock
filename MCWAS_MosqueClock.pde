// Copyright Pilgrim Media Productions
// Author Shiraz Chanawala

import java.util.Calendar;
int y;
int dayOfWeek;
int rtpanex = 3122;
int rtpaney = 1500;
PImage rightpane;
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
  print (xRatio+ " " + yRatio);
  rtpanex = int(x(3122));
  rtpaney = int(y(1500));
  frameRate(2);

  rightpane = loadImage("images/mosque_clock_right_pane.png");
  rightpane.resize(x(rightpane.width), y(rightpane.height));
  logo = loadImage("images/mosque_logo.png");
  logo.resize(x(logo.width), y(logo.height));


  TimeFont = createFont("font/AvenirNextLTPro-Regular.otf", x(300));
  SalahTimeFont = createFont("font/AvenirNextLTPro-Regular.otf", x(160));
  SalahTimeFontBold = createFont("font/AvenirNextLTPro-Bold.otf", x(160));
  SalahTimeFontHeading = createFont("font/AvenirNextLTPro-Regular.otf", x(104));
  TodaysDateFont = createFont("font/AvenirNextLTPro-Regular.otf", x(90));
  CountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", x(700));
  LargeCountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", x(900));
  SalahNameFont = createFont("font/AvenirNextLTPro-Regular.otf", x(600));

  // Get the day of the week to determine if its Jumuah
  Calendar c = Calendar.getInstance();
  dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
  // Load the timetable file
  table = loadTable("data/mcwas-tv-timetable.csv", "header");
}

void draw() {

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

  //What is today - needs to be in dd mmm
  int mi=minute(), s=second(), h=hour();
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
  TableRow row = table.findRow(TodaysDate, "Date");
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

  int rowNum = row.getInt("RowNum");
  int nextRowNum = rowNum+1;
  if (nextRowNum > table.getRowCount()) { // If today is last day of the year, next day would be 1st Jan.
    nextRowNum = 0;
  }

  TableRow nextRow = table.getRow(nextRowNum-1);
  String Date = row.getString("Date");
  String Day = row.getString("Day");
  String Sunrise = row.getString("Sunrise");

  Times fajr = getTimesFor("Fajr", "Fajr Jamah", "Fajr Begins", null, row, nextRow, CurrentTotalTimeMins, 0, false);
  Times dhuhr = getTimesFor("Dhuhr", "Dhuhr Jamah", "Dhuhr Begins", null, row, nextRow, CurrentTotalTimeMins, 0, true);
  Times asr = getTimesFor("Asr", "Asr Jamah", "Mithl 1", "Mithl 2", row, nextRow, CurrentTotalTimeMins, 12, false);
  Times maghrib = getTimesFor("Maghrib", "Maghrib Jamah", "Maghrib Begins", null, row, nextRow, CurrentTotalTimeMins, 12, false);
  Times isha = getTimesFor("Isha", "Isha Jamah", "Isha Begins", null, row, nextRow, CurrentTotalTimeMins, 12, false);

  int SunriseTotalTimeMins = salahTimeInMinutes(Sunrise, 0, false);
  int KarahatTime = dhuhr.startTimeInMinutes - KarahatTimeOffset;

  // Hijri Date
  TableRow hiriDateRow = CurrentTotalTimeMins < maghrib.startTimeInMinutes ? row : nextRow;
  String HijriDate = hiriDateRow.getString("Hijri Date");
  String HijriMonth = hiriDateRow.getString("Hijri Month");
  String HijriYear = hiriDateRow.getString("Hijri Year");
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


    String[] JummahArray = split(JummahTime, ':');
    int JummahHrs = parseInt(JummahArray[0]);
    int JummahMin = parseInt(JummahArray[1]);
    int JummahTotalTimeMins = JummahHrs<12?(JummahHrs+12)*60 + JummahMin:JummahHrs*60 + JummahMin;

    // Salah Text Allignment
    int snax = x(156);
    int snay = y(848);
    int snay_gap = y(280);
    int stabx = x(950);
    int stasx = x(2300);


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
    if (Day.equals("Fri") == true) {
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

    // Set Dhur Time - Adjust for Jumamh
    if (Day.equals("Fri") == true) {
      text(JummahTime, stasx, snay+snay_gap);
    } else {
      text(dhuhr.jamahTime, stasx, snay+snay_gap);
    }

    text(asr.jamahTime, stasx, snay+2*snay_gap);
    text(maghrib.jamahTime, stasx, snay+3*snay_gap);
    text(isha.jamahTime, stasx, snay+4*snay_gap);

    // *** DISPLAY SALAH JAMAH BEGIN TIMES
    textFont(SalahTimeFont);
    textAlign(LEFT);

    text(fajr.startTime1, stabx, snay);
    text(dhuhr.startTime1, stabx, snay+snay_gap);
    // Set Asr Begins Time - we need to show Mitl 1 and Mitl 2
    text(asr.startTime1 + " / " + asr.startTime2, stabx, snay+2*snay_gap);
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
    } else if (CurrentTotalTimeMins == maghrib.jamahTimeInMinutes-1) {
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
    } else if (CurrentTotalTimeMins >= SunriseTotalTimeMins && CurrentTotalTimeMins < (SunriseTotalTimeMins+SunriseOffset)) {
      showPrayerInProgressFor("Sunrise");
    } else if (CurrentTotalTimeMins >= dhuhr.jamahTimeInMinutes && CurrentTotalTimeMins < (dhuhr.jamahTimeInMinutes + SalahInProgressOffset) && !Day.equals("Fri")) {
      showPrayerInProgressFor(dhuhr.name);
    } else if (CurrentTotalTimeMins >= JummahTotalTimeMins && CurrentTotalTimeMins <(JummahTotalTimeMins + JummahLenghthMin) && Day.equals("Fri")) {
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
    text("Sunrise " + Sunrise + "  |  Jum'uah " + JummahTime, rtpanex, rtpaney+y(615));
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

  if (CurrentTotalTimeMins>=jamahTimeInMinutes+NextDayTriggerInMinutes) {
    //Show tomorrow's salah time
    jamah = nextRow.getString(colJamah);
    jamahTimeInMinutes = salahTimeInMinutes(jamah, hoursOffset, isDhuhrORJumuah);
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
  showTimerFor("Time to "+prayer.name, prayer.jamahTimeInMinutes-currentTotalTimeMins, "minutes");
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
