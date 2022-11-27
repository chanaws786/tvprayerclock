// Copyright Pilgrim Media Productions
// Author Shiraz Chanawala

import java.util.Calendar;
int y;
int dayOfWeek;
int rtpanex = 3122;
int rtpaney = 1500;
PImage rightpane;
PImage logo;

// Fonts
PFont TimeFont;
PFont SalahTimeFont;
PFont SalahTimeFontBold;
PFont SalahTimeFontHeading;
PFont TodaysDateFont; 
PFont CountDownFont; 
PFont LargeCountDownFont; 
PFont SalahName; 



void setup() {
    fullScreen(P2D);
    //size(3840, 2160);
    frameRate(2);
    
    rightpane = loadImage("images/mosque_clock_right_pane.png");
    logo = loadImage("images/mosque_logo.png");


    TimeFont = createFont("font/AvenirNextLTPro-Regular.otf", 300);
    SalahTimeFont = createFont("font/AvenirNextLTPro-Regular.otf", 160);
    SalahTimeFontBold = createFont("font/AvenirNextLTPro-Bold.otf", 160);
    SalahTimeFontHeading = createFont("font/AvenirNextLTPro-Regular.otf", 104);
    TodaysDateFont = createFont("font/AvenirNextLTPro-Regular.otf", 90); 
    CountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", 700); 
    LargeCountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", 900); 
    SalahName = createFont("font/AvenirNextLTPro-Regular.otf", 600); 
    
    // Get the day of the week to determine if its Jumuah
    Calendar c = Calendar.getInstance();
    dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
}

void draw(){
    // Load the timetable file 
    Table table = loadTable("data/Prayer Timetable.csv", "header");
      
    // Set Background      
    // Construct the canvas
    // Canvas Background
    stroke(0);
    fill(backgroundcolor);  
    rect(0, 0, 3840, 2160);  
    
    // Time Background   
    stroke(0);
    fill(0);
    rect(0, 0, 2400, 400);  
     
     // Logo 
     image(logo, 2400, 0);
      
     // Right Pane background and default image 
     fill(rightpanecolour);
     stroke(0);
     rect(2400, 400, 1440, 1760);     
     image(rightpane, 2400, 400);

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
         if (s0.length() == 1){
             s0 = "0" + s0;
         };
     String m0 = str((mi));
         if (m0.length() == 1){
             m0 = "0" + m0;
         };
    String h0 = str((h));
        if (h0.length() == 1){
            h0 = "0" + h0;
        };
  
    // Time String stored in Time variable
    if (hdisplay>12) {
        hdisplay = hdisplay-12;
    };  
    String Time = (hdisplay) + ":" + (m0) + ":" + s0;
 
    //Convert Month to 3 character Month
    if (m==1) { 
        mmm = "Jan"; }
    if (m==2) { 
        mmm = "Feb"; }
    if (m==3) { 
        mmm = "Mar";  }
    if (m==4) { 
        mmm = "Apr"; }
    if (m==5) { 
        mmm = "May";  }
    if (m==6) { 
        mmm = "Jun";  }
    if (m==7) { 
        mmm = "Jul";  }
    if (m==8) { 
        mmm = "Aug";  }
    if (m==9) { 
        mmm = "Sep"; }
    if (m==10) { 
        mmm = "Oct";  }
    if (m==11) { 
        mmm = "Nov";  }
    if (m==12) { 
        mmm = "Dec";  }    
     
    // Construct Todays Date for compare
    String dsi = str(d);
    //String msi = str(mmm);
    TodaysDate = (dsi + " " + mmm);
    FullTodaysDate = (TodaysDate + " " + str(yr));
 
    //Iterate through the file 
    for (TableRow row : table.rows()) {

    // Set the CurrentTotalTimeMins which is ues to control the elements in the right pane  
    // We need to subtract 12 because the salah time in spreadsheet are in 12 hour clock format without the AM/PM indicator
    if (h > 12) {
           CurrentTotalTimeMins = (((h-12)*60) + mi);
    } 
     else {
           CurrentTotalTimeMins = (((h)*60) + mi); 
     }     
     
     // int Number = row.getInt("RowNum");
     String Date = row.getString("Date");
     String Day = row.getString("Day");
     String FajrJamah = row.getString("Fajr Jamah");
     String Sunrise = row.getString("Sunrise");
     String DhuhrJamah = row.getString("Dhuhr Jamah");
     String AsrJamah = row.getString("Asr Jamah");
     String MaghribJamah = row.getString("Maghrib Jamah");
     String IshaJamah = row.getString("Isha Jamah");
     String FajrBegins = row.getString("Fajr Begins");
     String DhuhrBegins = row.getString("Dhuhr Begins");
     String AsrBegins1 = row.getString("Mithl 1");
     String AsrBegins2 = row.getString("Mithl 2");
     String AsrBeginsConcat;
     String MaghribBegins = row.getString("Maghrib Begins");
     String IshaBegins = row.getString("Isha Begins");
    
     String[] FajrArray = split(FajrJamah, ':');
     String[] SunriseArray = split(Sunrise, ':');
     String[] DhuhrBeginArray = split(DhuhrBegins, ':');
     String[] DhuhrArray = split(DhuhrJamah, ':');
     String[] AsrArray = split(AsrJamah, ':');
     String[] MaghribArray = split(MaghribJamah, ':');
     String[] IshaArray = split(IshaJamah, ':');
      
     int FajrHrs = parseInt(FajrArray[0]);
     int FajrMin = parseInt(FajrArray[1]);
     int FajrTotalTimeMins = ((FajrHrs*60) +  FajrMin);
     int FajrSalahInProgressOffset = FajrTotalTimeMins + SalahInProgressOffset;
     
     int SunriseHrs = parseInt(SunriseArray[0]);
     int SunriseMin = parseInt(SunriseArray[1]);
     int SunriseTotalTimeMins = ((SunriseHrs*60) +  SunriseMin);
     
     int DhuhrBeginsHrs = parseInt(DhuhrBeginArray[0]);
     int DhuhrBeginsMin = parseInt(DhuhrBeginArray[(DhuhrBeginArray.length)-1]);
     int DhuhrBeginsTotalMins = ((DhuhrBeginsHrs*60) +  DhuhrBeginsMin);     
     int KarahatTime = DhuhrBeginsTotalMins - KarahatTimeOffset;
                  
     int DhuhrHrs = parseInt(DhuhrArray[0]);
     int DhuhrMin = parseInt(DhuhrArray[(DhuhrArray.length)-1]); // I dont know why I cant reference the array directly 
     int DhuhrTotalTimeMins = ((DhuhrHrs * 60) + DhuhrMin);
     int DhuhrSalahInProgressOffset = DhuhrTotalTimeMins + SalahInProgressOffset;
     
     int AsrHrs = parseInt(AsrArray[0]);
     int AsrMin = parseInt(AsrArray[1]);
     int AsrTotalTimeMins = ((AsrHrs * 60) + AsrMin);
     int AsrSalahInProgressOffset = AsrTotalTimeMins + SalahInProgressOffset;

     int MaghribHrs = parseInt(MaghribArray[0]);
     int MaghribMin = parseInt(MaghribArray[1]);
     int MaghribTotalTimeMins = ((MaghribHrs * 60) + MaghribMin);
     int MaghribSalahInProgressOffset = MaghribTotalTimeMins + SalahInProgressOffset;

     int IshaHrs = parseInt(IshaArray[0]);
     int IshaMin = parseInt(IshaArray[1]);
     int IshaTotalTimeMins = ((IshaHrs * 60) + IshaMin);
     int IshaSalahInProgressOffset = IshaTotalTimeMins + SalahInProgressOffset;

     // Hijri Date 
     String HijriDate = row.getString("Hijri Date");
     String HijriMonth = row.getString("Hijri Month");
     String HijriYear = row.getString("Hijri Year");
     //String FullTodaysDateWithHijri = "";
    
     // Create Date to display which is Gregoran and Hijri Date 
     FullHijriDate = (HijriDate + " " + HijriMonth + " " + HijriYear);
    
    
     // Print Time and Todays Date First
     if (Date.equals(TodaysDate) == true) { 
       // Large Clock
       fill(255);
       textAlign(LEFT);
       textFont(TimeFont);
       text(Time, 150, 320);
        
       // Gregorian Date display
       fill(255);
       textAlign(RIGHT);
       textFont(TodaysDateFont);
       text(FullTodaysDate,2300, 200);
        
       // Hijri Date display
       fill(255);
       textAlign(RIGHT);
       textFont(TodaysDateFont);
       text(FullHijriDate,2300, 320);
        
        
       String[] JummahArray = split(JummahTime, ':');
       int JummahHrs = parseInt(JummahArray[0]);
       int JummahMin = parseInt(JummahArray[1]);
       int JummahTotalTimeMins = ((JummahHrs*60) + JummahMin);
       int JummahInProgressOffset = JummahTotalTimeMins + JummahLenghthMin;

       // Salah Text Allignment
       int snax = 156;
       int snay = 848;
       int snay_gap = 280;
       int stabx = 950;
       int stasx = 2300;
       
       
       //*** Debug - uncomment if required
       //println("Todays Date: " + Date);
       //println("Time Now   : " + h + ":"+ mi);
       //println("Current Total Time in Mins: " +  CurrentTotalTimeMins);
       //println("TimeNow:" + Time + "  FajrTime    : "     + FajrHrs      + ":"   + FajrMin      + " Array: "   + FajrJamah    +  " Array Length: "  + FajrArray.length  + " Fajr Total Min: " + FajrTotalTimeMins);
       //println("TimeNow:" + Time + "  DhurTime    : "     + DhuhrHrs     + ":"   + DhuhrMin     + " Array: "   + DhuhrJamah   +  " Array Length: "  + DhuhrArray.length  + " Dhur Total Min: " + DhuhrTotalTimeMins);
       //println("TimeNow:" + Time + "  AsrTime     : "     + AsrHrs       + ":"   + AsrMin       + " Array: "   + AsrJamah   +  " Array Length: "  + AsrArray.length  + " Asr Total Min: " + AsrTotalTimeMins);
       //println("TimeNow:" + Time + "  MaghribTime : "     + MaghribHrs   + ":"   + MaghribMin   + " Array: "   + MaghribJamah   +  " Array Length: "  + MaghribArray.length  + " Maghrib Total Min: " + MaghribTotalTimeMins);
       //println("TimeNow:" + Time + "  IshaTime    : "     + IshaHrs      + ":"   + IshaMin      + " Array: "   + IshaJamah   +  " Array Length: "  + IshaArray.length  + " Isha Total Min: " + IshaTotalTimeMins);
    
        // *** DISPLAY HEADINGS ****
        fill(255);
        textFont(SalahTimeFontHeading);
        textAlign(LEFT);
        textFont(TodaysDateFont);
        text("BEGINS", stabx, 600);
        textFont(TodaysDateFont);
        textAlign(RIGHT);
        text("JAMAAT", stasx, 600);
    
        // *** DISPLAY SALAH NAMES
        textFont(SalahTimeFont);
        textAlign(LEFT);
        text("Fajr", snax, snay);
        
        // Substitute Jummah for Dhuhr on Fridays
        if (Day.equals("Fri") == true) {
           text("Jum'uah", snax, snay+snay_gap);
        } else { text("Dhuhr", snax, snay+snay_gap); }
        
        text("Asr", snax, (snay+2*snay_gap));
        text("Maghrib", snax, snay+3*snay_gap);
        text("Isha", snax, snay+4*snay_gap);
        
        // *** DISPLAY SALAH JAMAH TIMES
        textFont(SalahTimeFontBold);
        textAlign(RIGHT);
        
        // Set Fajr Time
        text(FajrJamah, stasx, snay);
        
        // Set Dhur Time - Adjust for Jumamh
        if (Day.equals("Fri") == true) {
          text(JummahTime, stasx, snay+snay_gap);  
        } else {
          text(DhuhrJamah, stasx, snay+snay_gap); }
        
        // Set Asr Time
        text(AsrJamah, stasx, snay+2*snay_gap);
        
        // Set Maghrib Time
        text(MaghribJamah, stasx, snay+3*snay_gap);
        
        // Set Isha Time
        text(IshaJamah, stasx, snay+4*snay_gap);
  
        // *** DISPLAY SALAH JAMAH BEGIN TIMES
        textFont(SalahTimeFont);
        textAlign(LEFT);
        
        // Set Fajr Time Begins
        text(FajrBegins, stabx, snay);
        
        // Set Dhur Time Begins - Adjust for Jummah
        if (Day.equals("Fri") == true) {
           text(DhuhrBegins, stabx, snay+snay_gap);   
        } else {
          text(DhuhrBegins, stabx, snay+snay_gap); }
        
        // Set Asr Begins Time - we need to show Mitl 1 and Mitl 2
        AsrBeginsConcat = (AsrBegins1 + " / " + AsrBegins2);
        text(AsrBeginsConcat, stabx, snay+2*snay_gap);
        
        // Set Maghrib Begins Time
        text(MaghribBegins, stabx, snay+3*snay_gap);
        
        // Set Isha Time
        text(IshaBegins, stabx, snay+4*snay_gap);
   

         
         // ** Right Pane Text //
        
         // Fajr //
         // The h<12 is to ensure that this triggers in AM only 
         if ((h<12 && CurrentTotalTimeMins > FajrTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < FajrTotalTimeMins-1)){
             fill(CurrentTotalTimeMins);  
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Fajr", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((FajrTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+300); 
         }
         if ((h<12 && CurrentTotalTimeMins == FajrTotalTimeMins-1)){
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Fajr", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+300); }
                          
         
         // KarahatTime - It is the time when performing salat is makrûh tahrimî, that is, harâm, during the Sun is setting (post the point it is above your head.//
         if (h>= 11 && (CurrentTotalTimeMins >= KarahatTime) && (CurrentTotalTimeMins < DhuhrBeginsTotalMins)){
             fill(CurrentTotalTimeMins);  
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Zawal Time", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((DhuhrBeginsTotalMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+300); }
           
         
         // Dhuhr //
         // The h>=12 is to ensure this triggers in PM 
         if (h>= 12 && (CurrentTotalTimeMins >= DhuhrTotalTimeMins-LargeCountDown) && (CurrentTotalTimeMins < DhuhrTotalTimeMins-1) && (Day.equals("Fri") == false)){
             fill(CurrentTotalTimeMins);  
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Dhuhr", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((DhuhrTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+300); 
         }
             if (h>= 12 && (CurrentTotalTimeMins == DhuhrTotalTimeMins-1) && (Day.equals("Fri") == false)){
             //println("In Dhuhr Countdwn");  
             //background(countdown); 
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Dhuhr", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+300); 
           }
             
   
         // Asr //
         if (h>= 12 && (CurrentTotalTimeMins >= AsrTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < AsrTotalTimeMins-1)){
             fill(CurrentTotalTimeMins);  
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Asr", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((AsrTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+300); 
         }
           if (h>= 12 && (CurrentTotalTimeMins == AsrTotalTimeMins-1)){
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Asr", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+300); }
         
         // Maghrib //
         if (h>= 12 && (CurrentTotalTimeMins >= MaghribTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < MaghribTotalTimeMins-1)){
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Maghrib", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((MaghribTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+300); 
         }
             if (h>= 12 && (CurrentTotalTimeMins == MaghribTotalTimeMins-1)){
             //println("In Maghrib Countdwn");  
             //background(maghribcountdown); 
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Maghrib", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+300); }
         
         // Isha //
         if (h>= 12 && (CurrentTotalTimeMins >= IshaTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < IshaTotalTimeMins-1)){
             //print("Isha Large CountDown ");
             fill(rightpanecolour);
             stroke(0);
             rect(2400, 400, 1440, 1760);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Isha", rtpanex, rtpaney-800);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((IshaTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+300); 

         }
         if (h>= 12 && (CurrentTotalTimeMins == IshaTotalTimeMins-1)){
           //println("In Isha Countdwn");  
           //background(countdown); 
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255);
           int cdd = SalahCountDownStart - second(); 
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("Time to Isha", rtpanex, rtpaney-800);
           textFont(LargeCountDownFont);  
           textAlign(CENTER);
           text(cdd, rtpanex, rtpaney);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("seconds", rtpanex, rtpaney+300); }  
           

  
        // *** SALAH IN PROGRESS CODE 
        if (h<12 && (CurrentTotalTimeMins >= FajrTotalTimeMins) && (CurrentTotalTimeMins < FajrSalahInProgressOffset)){
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(600);
           text("Fajr", rtpanex, rtpaney-250);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        } 
        
        //Sunrise
        if (h<12 && (CurrentTotalTimeMins >= SunriseTotalTimeMins) && (CurrentTotalTimeMins < SunriseOffset)){
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(600);
           text("Sunrise", rtpanex, rtpaney-250);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text(Sunrise, rtpanex, rtpaney); 
        } 
        
        
        if (h>= 12 && (CurrentTotalTimeMins >= DhuhrTotalTimeMins) && (CurrentTotalTimeMins < DhuhrSalahInProgressOffset) && (Day.equals("Fri") == false)){
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(350);
           text("Dhuhr", rtpanex, rtpaney-200);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        } 

         // Jummuah Day show the static background for JummahLenghthMin and no countdown
           if (h>=12 && (CurrentTotalTimeMins >= JummahTotalTimeMins) && (CurrentTotalTimeMins <JummahInProgressOffset) && (Day.equals("Fri") == true)){
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(300);
           text("Jum'uah", rtpanex, rtpaney-300);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney-100); 
         }

          
        if (h>=12 && (CurrentTotalTimeMins >= AsrTotalTimeMins) && (CurrentTotalTimeMins < AsrSalahInProgressOffset)){
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(600);
           text("Asr", rtpanex, rtpaney-200);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        }         
      
        if (h>=12 && (CurrentTotalTimeMins >= MaghribTotalTimeMins) && (CurrentTotalTimeMins < MaghribSalahInProgressOffset)){
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(300);
           text("Maghrib", rtpanex, rtpaney-300);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney-100); 
        }    
        
        if (h>=12 && (CurrentTotalTimeMins >= IshaTotalTimeMins) && (CurrentTotalTimeMins < IshaSalahInProgressOffset)){
           fill(rightpanecolour);
           stroke(0);
           rect(2400, 400, 1440, 1760);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(600);
           text("Isha", rtpanex, rtpaney-200);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        } 
        
       // Display Sunrise and Jum'uah times in right pane 
       fill(0);
       stroke(0);
       rect(2400, 1996, 1440, 164);   
       textAlign(CENTER);
       textFont(TodaysDateFont);
       fill(255);
       text("Sunrise " + Sunrise + "  |  Jum'uah " + JummahTime, rtpanex, rtpaney+615);

        
    } // iterate whilst todays date is the date in the file  
  } // iterate through file
} // void draw()
