import Toybox.Graphics;

// Watchface-level visual constants for Time Tile (fr55, 208 x 208).
// Element-specific dimensions live under source/stripe/elements/.
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

    // Plain vertical stripe geometry (user-tuned).
    // Runtime stripe/element colors come from StripeAppearanceConfiguration.
    const STRIPE_LEFT_X = 140;
    const STRIPE_TOP_Y = 0;
    const STRIPE_WIDTH = 60;
    const STRIPE_HEIGHT = 250;

    // Stripe content slots — horizontal center derived from stripe geometry.
    const STRIPE_CONTENT_CENTER_X = STRIPE_LEFT_X + ((STRIPE_WIDTH * 2) / 4);
    const TOP_SLOT_CENTER_Y = 48;
    const MIDDLE_SLOT_CENTER_Y = 104;
    const BOTTOM_SLOT_CENTER_Y = 160;
}
