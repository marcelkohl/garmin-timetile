import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Weather;

// Weather stripe element: condition icon (top) + formatted temperature (bottom).
class WeatherStripeElement extends StripeElement {

    private var _condition as Number or Null;
    private var _iconFamily as Number;
    private var _temperatureText as String;
    private var _currentIconWhite as BitmapResource or Null;
    private var _currentIconBlack as BitmapResource or Null;

    function initialize() {
        StripeElement.initialize();
        _condition = null;
        _iconFamily = WeatherIconCatalog.FAMILY_UNSET;
        _temperatureText = "--";
        _currentIconWhite = null;
        _currentIconBlack = null;
    }

    function getRefreshIntervalSeconds() as Number {
        return WeatherStripeStyle.REFRESH_INTERVAL_SECONDS;
    }

    function refreshData() as Boolean {
        var condition = null as Number or Null;
        var family = WeatherIconCatalog.FAMILY_UNKNOWN;
        var temperatureText = "--";

        var conditions = Weather.getCurrentConditions();
        if (conditions != null) {
            var current = conditions as Weather.CurrentConditions;
            if (current.condition != null) {
                condition = current.condition as Number;
                family = familyForCondition(condition);
            }

            if (current.temperature != null) {
                temperatureText = formatTemperature(current.temperature as Numeric);
            }
        }

        var iconsChanged = replaceIconsIfFamilyChanged(family);
        var changed = (_condition != condition)
            || iconsChanged
            || (!_temperatureText.equals(temperatureText));
        _condition = condition;
        _temperatureText = temperatureText;
        return changed;
    }

    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Void {
        if (rowIndex != StripeElementLayout.ROW_TOP) {
            return;
        }
        if ((_currentIconWhite == null) || (_currentIconBlack == null)) {
            return;
        }

        var icon = _currentIconWhite as BitmapResource;
        if (foregroundColor == Graphics.COLOR_BLACK) {
            icon = _currentIconBlack as BitmapResource;
        }

        var iconWidth = icon.getWidth();
        var iconHeight = icon.getHeight();
        var x = StripeElementLayout.centeredContentX(rowBounds[0], rowBounds[2], iconWidth);
        var y = StripeElementLayout.anchoredContentY(
            rowIndex,
            rowBounds[1],
            rowBounds[3],
            iconHeight
        );
        dc.drawBitmap(x, y, icon);
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != StripeElementLayout.ROW_BOTTOM) {
            return null;
        }
        return _temperatureText;
    }

    function getRowFont(rowIndex as Number) as FontDefinition {
        if (rowIndex == StripeElementLayout.ROW_BOTTOM) {
            return WeatherStripeStyle.TEMPERATURE_FONT;
        }
        return StripeElementLayout.DEFAULT_ROW_FONT;
    }

    // Returns true when the cached resource pair was replaced.
    private function replaceIconsIfFamilyChanged(family as Number) as Boolean {
        if ((_iconFamily == family)
            && (_currentIconWhite != null)
            && (_currentIconBlack != null)) {
            return false;
        }

        _iconFamily = family;
        _currentIconWhite = WeatherIconCatalog.loadWhite(family);
        _currentIconBlack = WeatherIconCatalog.loadBlack(family);
        return true;
    }

    private function familyForCondition(condition as Number) as Number {
        if ((condition == Weather.CONDITION_CLEAR)
            || (condition == Weather.CONDITION_MOSTLY_CLEAR)
            || (condition == Weather.CONDITION_FAIR)) {
            return WeatherIconCatalog.FAMILY_CLEAR;
        }
        if ((condition == Weather.CONDITION_PARTLY_CLOUDY)
            || (condition == Weather.CONDITION_PARTLY_CLEAR)) {
            return WeatherIconCatalog.FAMILY_PARTLY_CLOUDY;
        }
        if ((condition == Weather.CONDITION_CLOUDY)
            || (condition == Weather.CONDITION_MOSTLY_CLOUDY)) {
            return WeatherIconCatalog.FAMILY_CLOUDY;
        }
        if ((condition == Weather.CONDITION_RAIN)
            || (condition == Weather.CONDITION_LIGHT_RAIN)
            || (condition == Weather.CONDITION_HEAVY_RAIN)
            || (condition == Weather.CONDITION_SHOWERS)) {
            return WeatherIconCatalog.FAMILY_RAIN;
        }
        if ((condition == Weather.CONDITION_THUNDERSTORMS)
            || (condition == Weather.CONDITION_SCATTERED_THUNDERSTORMS)) {
            return WeatherIconCatalog.FAMILY_THUNDERSTORM;
        }
        if ((condition == Weather.CONDITION_SNOW)
            || (condition == Weather.CONDITION_LIGHT_SNOW)
            || (condition == Weather.CONDITION_HEAVY_SNOW)) {
            return WeatherIconCatalog.FAMILY_SNOW;
        }
        return WeatherIconCatalog.FAMILY_UNKNOWN;
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
