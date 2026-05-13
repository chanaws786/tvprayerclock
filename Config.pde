// Configuration variables with defaults
color backgroundcolor = #165D42;
color rightpanecolour = #5D1631;

// Time in mins or Salah in progress to be displayed 
int TenMinSalahInProgressOffset = 10;
int SalahInProgressOffset = 5;

// Number of seconds for Salah to start 
int SalahCountDownStart = 60;

// Time in mins for Jum'uah in progress to be displayed 
int JummahLenghthMin = 20;

// Number of mins for the large countdown to start before Jamaat time 
int LargeCountDown = 20;

// Number of mins before Zuhr time = Kara Hat Time 
int KarahatTimeOffset = 20;

// Number of mins for Sunrise Notification
int SunriseOffset = 10;

// Show next day's salah time after current time is today's Jamah Time + NextDayTriggerInMinutes.
int NextDayTriggerInMinutes = 5;

// Ramadan grey screen settings
boolean enableRamadanGreyScreen = true;
boolean testMode = false;
String testTime = "";
boolean forceRamadanMode = false;

// Data source URL
String fileUrl = "";

// Display configuration
int MAX_WIDTH = 3840;
int MAX_HEIGHT = 2160;
int frameRateValue = 30;
int reloadIntervalMinutes = 5;

// Logging configuration
String logLevel = "INFO";

// Network configuration
int urlConnectionTimeout = 30000;
int urlReadTimeout = 30000;

// Font sizes (base values before scaling)
int timeFontSize = 300;
int salahTimeFontSize = 160;
int salahTimeHeadingFontSize = 104;
int todaysDateFontSize = 90;
int countDownFontSize = 700;
int largeCountDownFontSize = 900;
int salahNameFontSize = 600;

// Right pane text position (base values before scaling)
int rightPaneTextX = 3122;
int rightPaneTextY = 1500;

// Layout coordinates
int LAYOUT_RIGHT_PANE_X = 2400;
int LAYOUT_RIGHT_PANE_Y = 400;
int LAYOUT_RIGHT_PANE_WIDTH = 1440;
int LAYOUT_RIGHT_PANE_HEIGHT = 1760;
int LAYOUT_TIME_BACKGROUND_HEIGHT = 400;
int LAYOUT_LEFT_MARGIN = 10;
int LAYOUT_SALAH_NAME_X = 50;
int LAYOUT_SALAH_NAME_Y = 848;
int LAYOUT_SALAH_GAP = 280;
int LAYOUT_BEGINS_ROW_X = 800;
int LAYOUT_JAMAAT_ROW_X = 2300;
int LAYOUT_HEADINGS_Y = 600;
int LAYOUT_TIME_Y = 320;
int LAYOUT_DATE_Y = 200;
int LAYOUT_LOGO_Y = 20;
int LAYOUT_ERROR_BOX_Y = 280;
int LAYOUT_BOTTOM_PANE_Y = 1996;
int LAYOUT_BOTTOM_PANE_HEIGHT = 164;

// Load configuration from properties file
void loadConfiguration() {
  try {
    java.util.Properties props = new java.util.Properties();

    // Load base configuration using sketch path
    String configPath = sketchPath("config.properties");
    java.io.File configFile = new java.io.File(configPath);
    if (configFile.exists()) {
      java.io.FileReader reader = new java.io.FileReader(configFile);
      props.load(reader);
      reader.close();
      println("Base configuration loaded from: " + configPath);
    } else {
      println("config.properties not found at: " + configPath + ", using default values");
    }

    // Load local overrides if they exist
    String localConfigPath = sketchPath("config.properties.local");
    java.io.File localConfigFile = new java.io.File(localConfigPath);
    if (localConfigFile.exists()) {
      java.io.FileReader localReader = new java.io.FileReader(localConfigFile);
      props.load(localReader);
      localReader.close();
      println("Local configuration overrides loaded from: " + localConfigPath);
    }
    
    // Load colors
    String bgColor = props.getProperty("backgroundcolor", "165D42");
    String rightColor = props.getProperty("rightpanecolour", "5D1631");
    try {
      backgroundcolor = parseHexColor(bgColor);
      rightpanecolour = parseHexColor(rightColor);
    } catch (Exception e) {
      println("Error loading colors: " + e.getMessage());
      // Use default colors if hex parsing fails
      backgroundcolor = #165D42;
      rightpanecolour = #5D1631;
    }
    
    // Load timing offsets
    TenMinSalahInProgressOffset = parseInt(props.getProperty("TenMinSalahInProgressOffset", "10"));
    SalahInProgressOffset = parseInt(props.getProperty("SalahInProgressOffset", "5"));
    SalahCountDownStart = parseInt(props.getProperty("SalahCountDownStart", "60"));
    JummahLenghthMin = parseInt(props.getProperty("JummahLenghthMin", "20"));
    LargeCountDown = parseInt(props.getProperty("LargeCountDown", "20"));
    KarahatTimeOffset = parseInt(props.getProperty("KarahatTimeOffset", "20"));
    SunriseOffset = parseInt(props.getProperty("SunriseOffset", "10"));
    NextDayTriggerInMinutes = parseInt(props.getProperty("NextDayTriggerInMinutes", "5"));
    
    // Load Ramadan settings
    enableRamadanGreyScreen = Boolean.parseBoolean(props.getProperty("enableRamadanGreyScreen", "true"));
    testMode = Boolean.parseBoolean(props.getProperty("testMode", "false"));
    testTime = props.getProperty("testTime", "");
    forceRamadanMode = Boolean.parseBoolean(props.getProperty("forceRamadanMode", "false"));
    
    // Load data source
    String urlOverride = props.getProperty("fileUrl");
    if (urlOverride != null && !urlOverride.isEmpty()) {
      fileUrl = urlOverride;
    }
    
    // Load display configuration
    MAX_WIDTH = parseInt(props.getProperty("MAX_WIDTH", "3840"));
    MAX_HEIGHT = parseInt(props.getProperty("MAX_HEIGHT", "2160"));
    frameRateValue = parseInt(props.getProperty("frameRate", "30"));
    reloadIntervalMinutes = parseInt(props.getProperty("reloadIntervalMinutes", "5"));
    
    // Load logging configuration
    logLevel = props.getProperty("logLevel", "INFO");
    
    // Load network configuration
    urlConnectionTimeout = parseInt(props.getProperty("urlConnectionTimeout", "30000"));
    urlReadTimeout = parseInt(props.getProperty("urlReadTimeout", "30000"));
    
    // Load font sizes
    timeFontSize = parseInt(props.getProperty("timeFontSize", "300"));
    salahTimeFontSize = parseInt(props.getProperty("salahTimeFontSize", "160"));
    salahTimeHeadingFontSize = parseInt(props.getProperty("salahTimeHeadingFontSize", "104"));
    todaysDateFontSize = parseInt(props.getProperty("todaysDateFontSize", "90"));
    countDownFontSize = parseInt(props.getProperty("countDownFontSize", "700"));
    largeCountDownFontSize = parseInt(props.getProperty("largeCountDownFontSize", "900"));
    salahNameFontSize = parseInt(props.getProperty("salahNameFontSize", "600"));
    
    // Load right pane text position
    rightPaneTextX = parseInt(props.getProperty("rightPaneTextX", "3122"));
    rightPaneTextY = parseInt(props.getProperty("rightPaneTextY", "1500"));
    
    // Load layout coordinates
    LAYOUT_RIGHT_PANE_X = parseInt(props.getProperty("LAYOUT_RIGHT_PANE_X", "2400"));
    LAYOUT_RIGHT_PANE_Y = parseInt(props.getProperty("LAYOUT_RIGHT_PANE_Y", "400"));
    LAYOUT_RIGHT_PANE_WIDTH = parseInt(props.getProperty("LAYOUT_RIGHT_PANE_WIDTH", "1440"));
    LAYOUT_RIGHT_PANE_HEIGHT = parseInt(props.getProperty("LAYOUT_RIGHT_PANE_HEIGHT", "1760"));
    LAYOUT_TIME_BACKGROUND_HEIGHT = parseInt(props.getProperty("LAYOUT_TIME_BACKGROUND_HEIGHT", "400"));
    LAYOUT_LEFT_MARGIN = parseInt(props.getProperty("LAYOUT_LEFT_MARGIN", "10"));
    LAYOUT_SALAH_NAME_X = parseInt(props.getProperty("LAYOUT_SALAH_NAME_X", "50"));
    LAYOUT_SALAH_NAME_Y = parseInt(props.getProperty("LAYOUT_SALAH_NAME_Y", "848"));
    LAYOUT_SALAH_GAP = parseInt(props.getProperty("LAYOUT_SALAH_GAP", "280"));
    LAYOUT_BEGINS_ROW_X = parseInt(props.getProperty("LAYOUT_BEGINS_ROW_X", "800"));
    LAYOUT_JAMAAT_ROW_X = parseInt(props.getProperty("LAYOUT_JAMAAT_ROW_X", "2300"));
    LAYOUT_HEADINGS_Y = parseInt(props.getProperty("LAYOUT_HEADINGS_Y", "600"));
    LAYOUT_TIME_Y = parseInt(props.getProperty("LAYOUT_TIME_Y", "320"));
    LAYOUT_DATE_Y = parseInt(props.getProperty("LAYOUT_DATE_Y", "200"));
    LAYOUT_LOGO_Y = parseInt(props.getProperty("LAYOUT_LOGO_Y", "20"));
    LAYOUT_ERROR_BOX_Y = parseInt(props.getProperty("LAYOUT_ERROR_BOX_Y", "280"));
    LAYOUT_BOTTOM_PANE_Y = parseInt(props.getProperty("LAYOUT_BOTTOM_PANE_Y", "1996"));
    LAYOUT_BOTTOM_PANE_HEIGHT = parseInt(props.getProperty("LAYOUT_BOTTOM_PANE_HEIGHT", "164"));
    
    println("Configuration loaded successfully");
  } catch (Exception e) {
    println("Error loading configuration: " + e.getMessage());
    e.printStackTrace();
    // Continue with default values
  }
}

// Helper function to parse hex color strings
color parseHexColor(String hexString) {
  // Remove # if present
  hexString = hexString.replace("#", "");
  
  // Parse the hex string
  int r = 0, g = 0, b = 0;
  
  if (hexString.length() == 6) {
    r = unhex(hexString.substring(0, 2));
    g = unhex(hexString.substring(2, 4));
    b = unhex(hexString.substring(4, 6));
  }
  
  return color(r, g, b);
}
