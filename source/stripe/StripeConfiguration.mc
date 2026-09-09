import Toybox.Application.Properties;
import Toybox.Lang;

// Reads stripe slot element identifiers from application properties.
// Call only when initializing or reloading the stripe panel — not every redraw.
module StripeConfiguration {

    const PROP_TOP = "topStripeElement";
    const PROP_MIDDLE = "middleStripeElement";
    const PROP_BOTTOM = "bottomStripeElement";

    // Returns [top, middle, bottom] with invalid/missing values replaced by NONE.
    function elementIds() as Array<Number> {
        return [
            readValidatedId(PROP_TOP),
            readValidatedId(PROP_MIDDLE),
            readValidatedId(PROP_BOTTOM)
        ] as Array<Number>;
    }

    function readValidatedId(propertyKey as String) as Number {
        var value = Properties.getValue(propertyKey);
        if (value instanceof Number) {
            var id = value as Number;
            if (StripeElementRegistry.isValid(id)) {
                return id;
            }
        }
        return StripeElementRegistry.NONE;
    }
}
