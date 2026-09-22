import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;

// Reads stripe appearance selection IDs from application properties and maps
// them to Graphics.COLOR_* values and icon contrast variants.
// Call on init/reload — not every redraw.
module StripeAppearanceConfiguration {

    const PROP_STRIPE_COLOR = "stripeColor";
    const PROP_FOREGROUND_COLOR = "stripeForegroundColor";

    // Stripe background selection IDs (stored in properties).
    const STRIPE_BLUE = 0;
    const STRIPE_RED = 1;
    const STRIPE_GREEN = 2;
    const STRIPE_YELLOW = 3;
    const STRIPE_ORANGE = 4;
    const STRIPE_PURPLE = 5;

    // Element foreground selection IDs (stored in properties).
    // Controls text and dynamic fills only — not SVG bitmap selection.
    const FOREGROUND_WHITE = 0;
    const FOREGROUND_BLACK = 1;

    function stripeColor() as Number {
        return colorForStripeSelection(readStripeSelectionId());
    }

    function stripeForegroundColor() as Number {
        return colorForForegroundSelection(readForegroundSelectionId());
    }

    // Resolved once per panel init/reload from the current stripe color.
    function iconVariant() as Number {
        return iconVariantForStripeSelection(readStripeSelectionId());
    }

    function readStripeSelectionId() as Number {
        var value = Properties.getValue(PROP_STRIPE_COLOR);
        if (value instanceof Number) {
            var id = value as Number;
            if (isValidStripeSelection(id)) {
                return id;
            }
        }
        return STRIPE_BLUE;
    }

    function readForegroundSelectionId() as Number {
        var value = Properties.getValue(PROP_FOREGROUND_COLOR);
        if (value instanceof Number) {
            var id = value as Number;
            if (isValidForegroundSelection(id)) {
                return id;
            }
        }
        return FOREGROUND_WHITE;
    }

    function isValidStripeSelection(id as Number) as Boolean {
        return (id >= STRIPE_BLUE) && (id <= STRIPE_PURPLE);
    }

    function isValidForegroundSelection(id as Number) as Boolean {
        return (id == FOREGROUND_WHITE) || (id == FOREGROUND_BLACK);
    }

    function colorForStripeSelection(id as Number) as Number {
        if (id == STRIPE_RED) {
            return Graphics.COLOR_RED;
        }
        if (id == STRIPE_GREEN) {
            return Graphics.COLOR_GREEN;
        }
        if (id == STRIPE_YELLOW) {
            return Graphics.COLOR_YELLOW;
        }
        if (id == STRIPE_ORANGE) {
            return Graphics.COLOR_ORANGE;
        }
        if (id == STRIPE_PURPLE) {
            return Graphics.COLOR_PURPLE;
        }
        // STRIPE_BLUE and any unexpected value.
        return Graphics.COLOR_BLUE;
    }

    // Initial FR55 stripe contrast policy (tunable later).
    // Blue/Green/Yellow/Orange -> OnLight; Red/Purple -> OnDark.
    function iconVariantForStripeSelection(id as Number) as Number {
        if ((id == STRIPE_RED) || (id == STRIPE_PURPLE)) {
            return StripeIconVariant.ON_DARK;
        }
        return StripeIconVariant.ON_LIGHT;
    }

    function colorForForegroundSelection(id as Number) as Number {
        if (id == FOREGROUND_BLACK) {
            return Graphics.COLOR_BLACK;
        }
        return Graphics.COLOR_WHITE;
    }
}
