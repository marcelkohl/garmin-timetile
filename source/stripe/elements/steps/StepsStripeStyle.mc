import Toybox.Graphics;

// Steps-only visual and refresh-policy constants.
module StepsStripeStyle {

    // Generated bitmap icon size (must match make assets output).
    const ICON_SIZE = 16;

    const COMPACT_THRESHOLD = 1000;

    // Code-level refresh policy (not a user setting).
    // Authoritative Steps interval for both full onUpdate and low-power onPartialUpdate.
    const REFRESH_INTERVAL_SECONDS = 5;
}
