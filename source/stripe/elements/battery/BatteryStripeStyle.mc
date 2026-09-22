import Toybox.Graphics;

// Battery-only visual and refresh-policy constants.
// Fill geometry is local to the SVG frame — not shared stripe layout.
module BatteryStripeStyle {

    // Charge-bar geometry relative to the loaded battery frame bitmap.
    // (0,0) is the top-left corner of the battery frame bitmap.
    // Intrinsic frame size is currently 25 × 25 (from battery_frame.svg).
    //
    // Initial values from the rendered PNG white body (~x=3..20, y=9..17),
    // inset by 1px so the bar stays inside the body and clear of the outline
    // and right-side terminal. SVG path uses transforms; tune these integers
    // manually if artwork changes.
    const FILL_START_X = 4;
    const FILL_START_Y = 10;
    const FILL_THICKNESS = 7;
    const FILL_MAX_WIDTH = 16;

    // Code-level refresh policy (not a user setting).
    const REFRESH_INTERVAL_SECONDS = 300;
}
