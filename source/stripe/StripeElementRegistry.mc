import Toybox.Lang;

// Numeric identifiers and factory for stripe content elements.
module StripeElementRegistry {

    const NONE = 0;
    const BATTERY = 1;

    function availableIds() as Array<Number> {
        return [NONE, BATTERY] as Array<Number>;
    }

    function create(id as Number) as StripeElement {
        if (id == BATTERY) {
            return new BatteryStripeElement();
        }

        return new EmptyStripeElement();
    }
}
