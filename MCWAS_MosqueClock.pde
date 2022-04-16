// Copyright Pilgrim Media Productions
// Author Shiraz Chanawala

import java.util.Calendar;
//import processing.sound.*;
PImage rightpane;
PImage logo;
PFont TimeFont;
PFont SalahTimeFont;
PFont SalahTimeFontBold;
PFont SalahTimeFontHeading;
PFont TodaysDateFont;
PFont CountDownFont;
PFont LargeCountDownFont;
PFont SalahName;
int y;
String JummahTime;
int dayOfWeek;
int rtpanex = 1561;
int rtpaney = 800;
int rtpanecolR = 151;
int rtpanecolG = 118;
int rtpanecolB = 41;


void setup() {
    //fullScreen(P2D);
    size(1920, 1080);
    frameRate(2);
  
    // Images
    rightpane = loadImage("images/mosque_clock_right_pane.png");
    logo = loadImage("images/mosque_logo.png");

    // Fonts
    TimeFont = createFont("font/AvenirNextLTPro-Regular.otf", 150);
    SalahTimeFont = createFont("font/AvenirNextLTPro-Regular.otf", 80);
    SalahTimeFontBold = createFont("font/AvenirNextLTPro-Bold.otf", 80);
    SalahTimeFontHeading = createFont("font/AvenirNextLTPro-Regular.otf", 52);
    TodaysDateFont = createFont("font/AvenirNextLTPro-Regular.otf", 45); 
    CountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", 350); 
    LargeCountDownFont = createFont("font/AvenirNextLTPro-Regular.otf", 450); 
    SalahName = createFont("font/AvenirNextLTPro-Regular.otf", 300); 

    
    // Get the day of the week to determine if its Jumuah
    Calendar c = Calendar.getInstance();
    dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
}

void draw(){
    // Set Background
    //background(bg);
      
      // Construct the canvas
      stroke(0);
      fill(22,93,66); //parameterise 
      rect(0, 0, 1920, 1080);  
      
      stroke(0);
      fill(0);
      rect(0, 0, 1200, 200);  
      
      image(logo, 1200, 0);
      
      fill(rtpanecolR,rtpanecolG,rtpanecolB);
      stroke(0);
      rect(1200, 200, 720, 880);     
      image(rightpane, 1200, 200);

  
     // Load the timetable file 
     Table table = loadTable("data/Prayer Timetable.csv", "header");
      
     // Load config file 
     String[] lines = loadStrings("data/config.txt");
     JummahTime = lines[0];
         
     // Salah in progress timer
     int SalahInProgressOffset = Integer.valueOf(lines[1]);
     int SalahCountDownStart = Integer.valueOf(lines[2]);
     int JummahLenghthMin = Integer.valueOf(lines[3]);
     int LargeCountDown = Integer.valueOf(lines[4]);     

     //Beep sound
     //SoundFile beep;
     //beep = new SoundFile(this, "beep-01a.wav");

     //What is today - needs to be in dd mmm
     int mi=minute(), s=second(), h=hour();
     int d = day();
     int m = month();
     int yr = year();
     int CurrentTotalTimeMins;
     String mmm = "";
     String TodaysDate = "";
     String FullTodaysDate = "";
     String FullHijriDate ="";
 
     // Set clock to 12hrs format 
     if (h>12){
         h = h - 12;
     };
 
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
    String Time = (h) + ":" + (m0) + ":" + s0;
 
 
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

      // int Number = row.getInt("RowNum");
      String Date = row.getString("Date");
      String Day = row.getString("Day");
      String FajrJamah = row.getString("Fajr Jamah");
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
      String[] DhuhrArray = split(DhuhrJamah, ':');
      String[] AsrArray = split(AsrJamah, ':');
      String[] MaghribArray = split(MaghribJamah, ':');
      String[] IshaArray = split(IshaJamah, ':');
      
      if (h > 12) {
         CurrentTotalTimeMins = (((h-12)*60) + mi);
      } else {
         CurrentTotalTimeMins = (((h)*60) + mi); }
      
      int FajrHrs = parseInt(FajrArray[0]);
      int FajrMin = parseInt(FajrArray[1]);
      int FajrTotalTimeMins = ((FajrHrs*60) +  FajrMin);
      int FajrSalahInProgressOffset = FajrTotalTimeMins + SalahInProgressOffset;
            
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


      // Initialise JummahTime
      // String JummahTime = "0:00";
    
      // Create Date to display which is Gregoran and Hijri Date 
      //FullTodaysDateWithHijri = (FullTodaysDate + " // " + HijriDate + " " + HijriMonth + " " + HijriYear);
      FullHijriDate = (HijriDate + " " + HijriMonth + " " + HijriYear);
    
    
      // Print Time and Todays Date First
      if (Date.equals(TodaysDate) == true) { 
        // Large Clock
        fill(255);
        textAlign(LEFT);
        textFont(TimeFont);
        text(Time, 75, 160);
        
        // Gregorian Date display
        fill(255);
        textAlign(RIGHT);
        textFont(TodaysDateFont);
        text(FullTodaysDate,1150, 110);
        
        // Hijri Date display
        fill(255);
        textAlign(RIGHT);
        textFont(TodaysDateFont);
        text(FullHijriDate,1150, 160);
        
        
        String[] JummahArray = split(JummahTime, ':');
        int JummahHrs = parseInt(JummahArray[0]);
        int JummahMin = parseInt(JummahArray[1]);
        int JummahTotalTimeMins = ((JummahHrs*60) + JummahMin);
        int JummahInProgressOffset = JummahTotalTimeMins + JummahLenghthMin;


        // Salah Text Allignment
        int snax = 78;
        int snay = 425;
        int snay_gap = 140;
        int stabx = 475;
        int stasx = 1150;

        
        // Countdown ticket allignment
        int stctx = 580;
        int stcty = 800;
       
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
        text("BEGINS", stabx, 300);
        textFont(TodaysDateFont);
        textAlign(RIGHT);
        text("JAMAAT", stasx, 300);
    
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
         if ((CurrentTotalTimeMins > FajrTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < FajrTotalTimeMins-1)){
             fill(CurrentTotalTimeMins);  
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Fajr", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((FajrTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+150); 
         }
         if ((CurrentTotalTimeMins == FajrTotalTimeMins-1)){

             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Fajr", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+150); }
         
         // Dhuhr //
         if ((CurrentTotalTimeMins >= DhuhrTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < DhuhrTotalTimeMins-1) && (Day.equals("Fri") == false)){
             fill(CurrentTotalTimeMins);  
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Dhuhr", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((DhuhrTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+150); 
         }
             if ((CurrentTotalTimeMins == DhuhrTotalTimeMins-1) && (Day.equals("Fri") == false)){
             //println("In Dhuhr Countdwn");  
             //background(countdown); 
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Dhuhr", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+150); 
           }
             
   
         // Asr //
         if ((CurrentTotalTimeMins >= AsrTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < AsrTotalTimeMins-1)){
             fill(CurrentTotalTimeMins);  
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Asr", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((AsrTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+150); 
         }
           if ((CurrentTotalTimeMins == AsrTotalTimeMins-1)){
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Asr", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+150); }
         
         // Maghrib //
         if ((CurrentTotalTimeMins >= MaghribTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < MaghribTotalTimeMins-1)){
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Maghrib", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((MaghribTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+150); 
         }
             if ((CurrentTotalTimeMins == MaghribTotalTimeMins-1)){
             //println("In Maghrib Countdwn");  
             //background(maghribcountdown); 
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             int cdd = SalahCountDownStart - second(); 
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Maghrib", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);  
             textAlign(CENTER);
             text(cdd, rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("seconds", rtpanex, rtpaney+150); }
         
         // Isha //
         if ((CurrentTotalTimeMins >= IshaTotalTimeMins-LargeCountDown && CurrentTotalTimeMins < IshaTotalTimeMins-1)){
             //print("Isha Large CountDown ");
             fill(rtpanecolR,rtpanecolG,rtpanecolB);
             stroke(0);
             rect(1200, 200, 720, 880);     
             fill(255);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("Time to Isha", rtpanex, rtpaney-400);
             textFont(LargeCountDownFont);
             textAlign(CENTER); 
             text((IshaTotalTimeMins-CurrentTotalTimeMins), rtpanex, rtpaney);
             textFont(SalahTimeFont);
             textAlign(CENTER); 
             text("minutes", rtpanex, rtpaney+150); 

         }
         if ((CurrentTotalTimeMins == IshaTotalTimeMins-1)){
           //println("In Isha Countdwn");  
           //background(countdown); 
           fill(rtpanecolR,rtpanecolG,rtpanecolB);
           stroke(0);
           rect(1200, 200, 720, 880);     
           fill(255);
           int cdd = SalahCountDownStart - second(); 
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("Time to Isha", rtpanex, rtpaney-400);
           textFont(LargeCountDownFont);  
           textAlign(CENTER);
           text(cdd, rtpanex, rtpaney);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("seconds", rtpanex, rtpaney+150); }  
           

  
        // *** SALAH IN PROGRESS CODE 
        if ((CurrentTotalTimeMins >= FajrTotalTimeMins) && (CurrentTotalTimeMins < FajrSalahInProgressOffset)){
           fill(rtpanecolR,rtpanecolG,rtpanecolB);
           stroke(0);
           rect(1200, 200, 720, 880);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(300);
           text("Fajr", rtpanex, rtpaney-125);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        } 
        
        
        if ((CurrentTotalTimeMins >= DhuhrTotalTimeMins) && (CurrentTotalTimeMins < DhuhrSalahInProgressOffset) && (Day.equals("Fri") == false)){
           fill(rtpanecolR,rtpanecolG,rtpanecolB);
           stroke(0);
           rect(1200, 200, 720, 880);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(275);
           text("Dhuhr", rtpanex, rtpaney-100);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        } 

         // Jummuah Day show the static background for JummahLenghthMin and no countdown
           if ((CurrentTotalTimeMins >= JummahTotalTimeMins) && (CurrentTotalTimeMins <JummahInProgressOffset) && (Day.equals("Fri") == true)){
           fill(rtpanecolR,rtpanecolG,rtpanecolB);
           stroke(0);
           rect(1200, 200, 720, 880);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(150);
           text("Jum'uah", rtpanex, rtpaney-150);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney-50); 
         }

          
        if ((CurrentTotalTimeMins >= AsrTotalTimeMins) && (CurrentTotalTimeMins < AsrSalahInProgressOffset)){
           fill(rtpanecolR,rtpanecolG,rtpanecolB);
           stroke(0);
           rect(1200, 200, 720, 880);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(300);
           text("Asr", rtpanex, rtpaney-100);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        }         
      
        if ((CurrentTotalTimeMins >= MaghribTotalTimeMins) && (CurrentTotalTimeMins < MaghribSalahInProgressOffset)){
           fill(rtpanecolR,rtpanecolG,rtpanecolB);
           stroke(0);
           rect(1200, 200, 720, 880);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(150);
           text("Maghrib", rtpanex, rtpaney-150);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney-50); 
        }    
        
        if ((CurrentTotalTimeMins >= IshaTotalTimeMins) && (CurrentTotalTimeMins < IshaSalahInProgressOffset)){
           fill(rtpanecolR,rtpanecolG,rtpanecolB);
           stroke(0);
           rect(1200, 200, 720, 880);     
           fill(255); 
           textFont(SalahName);  
           textAlign(CENTER);
           textSize(300);
           text("Isha", rtpanex, rtpaney-100);
           textFont(SalahTimeFont);
           textAlign(CENTER); 
           text("in progress", rtpanex, rtpaney); 
        } 

        
    } // iterate whilst todays date is the date in the file  
  } // iterate through file
} // void draw()
