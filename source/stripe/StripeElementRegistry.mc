import Toybox.Lang;

// Numeric identifiers and factory for stripe content elements.
// Geometry, fonts, and slot selection do not belong here.
module StripeElementRegistry {

    const NONE = 0;
    const BATTERY = 1;
    const CALENDAR = 2;
    const STEPS = 3;
    const WEATHER = 4;

    function availableIds() as Array<Number> {
        return [NONE, BATTERY, CALENDAR, STEPS, WEATHER] as Array<Number>;
    }

    function isValid(id as Number) as Boolean {
        var ids = availableIds();
        for (var i = 0; i < ids.size(); i += 1) {
            if (ids[i] == id) {
                return true;
            }
        }
        return false;
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
        if (id == WEATHER) {
            return new WeatherStripeElement();
        }

        return new EmptyStripeElement();
    }
}
