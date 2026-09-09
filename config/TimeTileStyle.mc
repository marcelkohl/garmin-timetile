import Toybox.Graphics;

// Developer-controlled visual constants for Time Tile (fr55, 208 x 208).
module TimeTileStyle {

    const BACKGROUND_COLOR = Graphics.COLOR_BLACK;
    const TIME_COLOR = Graphics.COLOR_WHITE;

    // TIME_FONT selects a fixed-size built-in Garmin font.
    // Custom font sizes will later be provided as separate compiled font resources.
    const TIME_FONT = Graphics.FONT_NUMBER_THAI_HOT;

    const SCREEN_CENTER_Y = 104;

    // Horizontal time area (right side beyond TIME_AREA_RIGHT is reserved for the stripe).
    const TIME_AREA_LEFT = 10;
    const TIME_AREA_RIGHT = 145;

    // Vertical layout: hour and minutes mirrored around the screen center.
    const HOUR_CENTER_Y = 76;
    const MINUTE_CENTER_Y = 132;

    // Strict hour clip: left content area, entirely above SCREEN_CENTER_Y.
    const HOUR_CLIP_X = TIME_AREA_LEFT;
    const HOUR_CLIP_Y = 0;
    const HOUR_CLIP_WIDTH = TIME_AREA_RIGHT - TIME_AREA_LEFT;
    const HOUR_CLIP_HEIGHT = SCREEN_CENTER_Y;

    // Strict minute clip: left content area, entirely below SCREEN_CENTER_Y.
    const MINUTE_CLIP_X = TIME_AREA_LEFT;
    const MINUTE_CLIP_Y = SCREEN_CENTER_Y;
    const MINUTE_CLIP_WIDTH = TIME_AREA_RIGHT - TIME_AREA_LEFT;
    const MINUTE_CLIP_HEIGHT = SCREEN_CENTER_Y;

    // Plain vertical stripe rectangle (user-tuned).
    const STRIPE_COLOR = Graphics.COLOR_BLUE;
    const STRIPE_LEFT_X = 145;
    const STRIPE_TOP_Y = 0;
    const STRIPE_WIDTH = 55;
    const STRIPE_HEIGHT = 250;

    // Stripe content slots — horizontal center derived from stripe geometry.
    const STRIPE_CONTENT_CENTER_X = STRIPE_LEFT_X + ((STRIPE_WIDTH * 2) / 5);
    const TOP_SLOT_CENTER_Y = 48;
    const MIDDLE_SLOT_CENTER_Y = 104;
    const BOTTOM_SLOT_CENTER_Y = 160;

    // Default stripe element foreground (later: user setting white/black only).
    const STRIPE_FOREGROUND_COLOR = Graphics.COLOR_WHITE;

    // Battery icon geometry (geometric primitives).
    const BATTERY_BODY_WIDTH = 24;
    const BATTERY_BODY_HEIGHT = 12;
    const BATTERY_OUTLINE_THICKNESS = 2;
    const BATTERY_TERMINAL_WIDTH = 3;
    const BATTERY_TERMINAL_HEIGHT = 6;
    const BATTERY_TEXT_FONT = Graphics.FONT_XTINY;
    const BATTERY_TEXT_GAP = 4;

    // Calendar icon geometry (geometric primitives).
    const CALENDAR_WIDTH = 30;
    const CALENDAR_HEIGHT = 30;
    const CALENDAR_HEADER_HEIGHT = 11;
    const CALENDAR_OUTLINE_THICKNESS = 2;
    const CALENDAR_WEEKDAY_FONT = Graphics.FONT_XTINY;
    const CALENDAR_DATE_FONT = Graphics.FONT_XTINY;

    // Steps icon geometry (provisional).
    const STEPS_TEXT_FONT = Graphics.FONT_XTINY;
    const STEPS_TEXT_OFFSET_Y = 14;

    // Two footprints as simple filled slanted parallelograms.
    const STEPS_FOOTPRINT_WIDTH = 12;
    const STEPS_FOOTPRINT_HEIGHT = 8;
    const STEPS_FOOTPRINT_SLANT = 2;
    const STEPS_FOOTPRINT_CENTER_OFFSET_X = 4;
    const STEPS_FOOTPRINT_VERTICAL_OFFSET = 4;
}
