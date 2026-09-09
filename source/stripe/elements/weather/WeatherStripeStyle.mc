import Toybox.Graphics;

// Weather-only visual and refresh-policy constants.
module WeatherStripeStyle {

    const ASSET_WIDTH = 18;
    const ASSET_HEIGHT = 18;
    const TEMPERATURE_FONT = Graphics.FONT_XTINY;

    // Code-level refresh policy (not a user setting).
    // Weather cache updates about every ~15 minutes system-side.
    const REFRESH_INTERVAL_SECONDS = 1200;
}
