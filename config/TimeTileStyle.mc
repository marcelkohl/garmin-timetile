import Toybox.Graphics;

// Developer-controlled visual constants for Time Tile (fr55, 208 x 208).
module TimeTileStyle {

    const BACKGROUND_COLOR = Graphics.COLOR_BLACK;
    const TIME_COLOR = Graphics.COLOR_WHITE;

    // TIME_FONT selects a fixed-size built-in Garmin font.
    // Custom font sizes will later be provided as separate compiled font resources.
    const TIME_FONT = Graphics.FONT_NUMBER_THAI_HOT;

    // Horizontal time area (right side beyond TIME_AREA_RIGHT is reserved for the stripe).
    const TIME_AREA_LEFT = 10;
    const TIME_AREA_RIGHT = 152;

    // Vertical layout: hour and minutes mirrored around the screen center.
    const SCREEN_CENTER_Y = 104;
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
}
