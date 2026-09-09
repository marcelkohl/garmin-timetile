import Toybox.Lang;

// Numeric identifiers and factory for stripe content elements.
module StripeElementRegistry {

    const NONE = 0;
    const BATTERY = 1;
    const CALENDAR = 2;
    const STEPS = 3;

    function availableIds() as Array<Number> {
        return [NONE, BATTERY, CALENDAR, STEPS] as Array<Number>;
    }

    function create(id as Number) as StripeElement {
        if (id == BATTERY) {
            return new BatteryStripeElement();
        }
        if (id == CALENDAR) {
            return new CalendarStripeElement();
        }
        if (id == STEPS) {
            return new StepsStripeElement();
        }

        return new EmptyStripeElement();
    }
}
