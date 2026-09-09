import Toybox.Graphics;

// Steps-only visual and refresh-policy constants.
module StepsStripeStyle {

    const FOOTPRINT_WIDTH = 12;
    const FOOTPRINT_HEIGHT = 8;
    const FOOTPRINT_SLANT = 2;
    const FOOTPRINT_CENTER_OFFSET_X = 4;
    const FOOTPRINT_VERTICAL_OFFSET = 4;
    const COMPACT_THRESHOLD = 1000;

    // Code-level refresh policy (not a user setting).
    // Does not guarantee 5-second watchface wakeups — only refreshes when onUpdate runs.
    const REFRESH_INTERVAL_SECONDS = 5;
}
