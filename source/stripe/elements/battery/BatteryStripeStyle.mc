import Toybox.Graphics;

// Battery-only visual and refresh-policy constants.
// Fill geometry is local to the SVG frame — not shared stripe layout.
module BatteryStripeStyle {

    const ASSET_WIDTH = 30;
    const ASSET_HEIGHT = 16;

    // Inner fill region relative to the 30×16 frame origin (matches SVG cutout).
    const INNER_FILL_X = 4;
    const INNER_FILL_Y = 4;
    const INNER_FILL_MAX_WIDTH = 20;
    const INNER_FILL_HEIGHT = 8;

    // Code-level refresh policy (not a user setting).
    const REFRESH_INTERVAL_SECONDS = 300;
}
