import Toybox.Graphics;

// Steps-only visual and refresh-policy constants.
module StepsStripeStyle {

    // Generated bitmap icon size (must match make assets output).
    const ICON_SIZE = 16;

    const COMPACT_THRESHOLD = 1000;

    // Code-level refresh policy (not a user setting).
    // Does not guarantee 5-second watchface wakeups — only refreshes when onUpdate runs.
    const REFRESH_INTERVAL_SECONDS = 5;
}
