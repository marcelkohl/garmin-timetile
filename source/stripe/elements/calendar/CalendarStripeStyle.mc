import Toybox.Graphics;

// Calendar-only visual and refresh-policy constants.
// Asset size is intrinsic to Calendar — not shared row/element sizing.
module CalendarStripeStyle {

    const ASSET_WIDTH = 30;
    const ASSET_HEIGHT = 18;

    const WEEKDAY_FONT = Graphics.FONT_XTINY;
    const DAY_FONT = Graphics.FONT_XTINY;

    // Code-level refresh policy (not a user setting).
    const REFRESH_INTERVAL_SECONDS = 3600;
}
