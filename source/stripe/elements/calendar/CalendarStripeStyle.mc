import Toybox.Graphics;

// Calendar-only visual and refresh-policy constants.
module CalendarStripeStyle {

    // Generated row bitmap size (must match make assets output).
    const ROW_IMAGE_WIDTH = 30;
    const ROW_IMAGE_HEIGHT = 16;

    const WEEKDAY_FONT = Graphics.FONT_XTINY;
    const DAY_FONT = Graphics.FONT_XTINY;

    // Code-level refresh policy (not a user setting).
    const REFRESH_INTERVAL_SECONDS = 3600;
}
