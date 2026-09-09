import Toybox.Graphics;

// Calendar-only visual and refresh-policy constants.
module CalendarStripeStyle {

    const OUTLINE_THICKNESS = 2;
    const WEEKDAY_FONT = Graphics.FONT_XTINY;
    const DAY_FONT = Graphics.FONT_XTINY;

    // Code-level refresh policy (not a user setting).
    const REFRESH_INTERVAL_SECONDS = 3600;
}
