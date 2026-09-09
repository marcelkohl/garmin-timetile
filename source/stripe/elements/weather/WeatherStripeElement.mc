import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Weather;

// Weather stripe element: temporary condition code + formatted temperature.
class WeatherStripeElement extends StripeElement {

    private var _condition as Number or Null;
    private var _conditionText as String;
    private var _temperatureText as String;

    function initialize() {
        StripeElement.initialize();
        _condition = null;
        _conditionText = "--";
        _temperatureText = "--";
    }

    function getRefreshIntervalSeconds() as Number {
        return WeatherStripeStyle.REFRESH_INTERVAL_SECONDS;
    }

    function refreshData() as Boolean {
        var condition = null as Number or Null;
        var conditionText = "--";
        var temperatureText = "--";

        var conditions = Weather.getCurrentConditions();
        if (conditions != null) {
            var current = conditions as Weather.CurrentConditions;
            if (current.condition != null) {
                condition = current.condition as Number;
                conditionText = conditionCodeFor(condition);
            }

            if (current.temperature != null) {
                temperatureText = formatTemperature(current.temperature as Numeric);
            }
        }

        var changed = (_condition != condition)
            || (!_conditionText.equals(conditionText))
            || (!_temperatureText.equals(temperatureText));
        _condition = condition;
        _conditionText = conditionText;
        _temperatureText = temperatureText;
        return changed;
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex == StripeElementLayout.ROW_TOP) {
            return _conditionText;
        }
        if (rowIndex == StripeElementLayout.ROW_BOTTOM) {
            return _temperatureText;
        }
        return null;
    }

    function getRowFont(rowIndex as Number) as FontDefinition {
        if (rowIndex == StripeElementLayout.ROW_TOP) {
            return WeatherStripeStyle.CONDITION_FONT;
        }
        if (rowIndex == StripeElementLayout.ROW_BOTTOM) {
            return WeatherStripeStyle.TEMPERATURE_FONT;
        }
        return StripeElementLayout.DEFAULT_ROW_FONT;
    }

    private function conditionCodeFor(condition as Number) as String {
        if ((condition == Weather.CONDITION_CLEAR)
            || (condition == Weather.CONDITION_MOSTLY_CLEAR)
            || (condition == Weather.CONDITION_FAIR)) {
            return "CLR";
        }
        if ((condition == Weather.CONDITION_PARTLY_CLOUDY)
            || (condition == Weather.CONDITION_PARTLY_CLEAR)) {
            return "PART";
        }
        if ((condition == Weather.CONDITION_CLOUDY)
            || (condition == Weather.CONDITION_MOSTLY_CLOUDY)) {
            return "CLD";
        }
        if ((condition == Weather.CONDITION_RAIN)
            || (condition == Weather.CONDITION_LIGHT_RAIN)
            || (condition == Weather.CONDITION_HEAVY_RAIN)
            || (condition == Weather.CONDITION_SHOWERS)) {
            return "RAIN";
        }
        if ((condition == Weather.CONDITION_THUNDERSTORMS)
            || (condition == Weather.CONDITION_SCATTERED_THUNDERSTORMS)) {
            return "STORM";
        }
        if ((condition == Weather.CONDITION_SNOW)
            || (condition == Weather.CONDITION_LIGHT_SNOW)
            || (condition == Weather.CONDITION_HEAVY_SNOW)) {
            return "SNOW";
        }
        // CONDITION_UNKNOWN and any unmapped value.
        return "--";
    }

    private function formatTemperature(celsius as Numeric) as String {
        var units = System.getDeviceSettings().temperatureUnits;
        var displayValue = celsius.toFloat();
        var suffix = "C";

        if (units == System.UNIT_STATUTE) {
            displayValue = (displayValue * 9.0 / 5.0) + 32.0;
            suffix = "F";
        }

        var rounded = Math.round(displayValue).toNumber();
        return rounded.format("%d") + suffix;
    }
}
