import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Calendar stripe element: SVG-backed row images with overlaid cached text.
class CalendarStripeElement extends StripeElement {

    private var _weekdayText as String;
    private var _dayText as String;
    private var _topOnLight as BitmapResource;
    private var _topOnDark as BitmapResource;
    private var _bottomOnLight as BitmapResource;
    private var _bottomOnDark as BitmapResource;
    private var _topWidth as Number;
    private var _topHeight as Number;
    private var _bottomWidth as Number;
    private var _bottomHeight as Number;

    function initialize() {
        StripeElement.initialize();
        _weekdayText = "";
        _dayText = "";
        _topOnLight = WatchUi.loadResource($.Rez.Drawables.CalendarTopOnLight) as BitmapResource;
        _topOnDark = WatchUi.loadResource($.Rez.Drawables.CalendarTopOnDark) as BitmapResource;
        _bottomOnLight = WatchUi.loadResource($.Rez.Drawables.CalendarBottomOnLight) as BitmapResource;
        _bottomOnDark = WatchUi.loadResource($.Rez.Drawables.CalendarBottomOnDark) as BitmapResource;
        _topWidth = _topOnLight.getWidth();
        _topHeight = _topOnLight.getHeight();
        _bottomWidth = _bottomOnLight.getWidth();
        _bottomHeight = _bottomOnLight.getHeight();
    }

    function getRefreshIntervalSeconds() as Number {
        return CalendarStripeStyle.REFRESH_INTERVAL_SECONDS;
    }

    function refreshData() as Boolean {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekdayText = weekdayAbbrev(info.day_of_week);
        var dayText = info.day.format("%d");

        var changed = (!_weekdayText.equals(weekdayText)) || (!_dayText.equals(dayText));
        _weekdayText = weekdayText;
        _dayText = dayText;
        return changed;
    }

    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number,
        backgroundColor as Number,
        iconVariant as Number
    ) as Void {
        var icon = selectRowIcon(rowIndex, iconVariant);
        var iconWidth = _topWidth;
        var iconHeight = _topHeight;
        if (rowIndex == StripeElementLayout.ROW_BOTTOM) {
            iconWidth = _bottomWidth;
            iconHeight = _bottomHeight;
        }
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
        if (rowIndex == StripeElementLayout.ROW_TOP) {
            return _weekdayText;
        }
        if (rowIndex == StripeElementLayout.ROW_BOTTOM) {
            return _dayText;
        }
        return null;
    }

    function getRowTextColor(
        rowIndex as Number,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Number {
        if (rowIndex == StripeElementLayout.ROW_TOP) {
            // Contrast against the filled header bitmap.
            return backgroundColor;
        }
        return foregroundColor;
    }

    function getRowFont(rowIndex as Number) as FontDefinition {
        if (rowIndex == StripeElementLayout.ROW_TOP) {
            return CalendarStripeStyle.WEEKDAY_FONT;
        }
        if (rowIndex == StripeElementLayout.ROW_BOTTOM) {
            return CalendarStripeStyle.DAY_FONT;
        }
        return StripeElementLayout.DEFAULT_ROW_FONT;
    }

    private function selectRowIcon(rowIndex as Number, iconVariant as Number) as BitmapResource {
        var onDark = (iconVariant == StripeIconVariant.ON_DARK);
        if (rowIndex == StripeElementLayout.ROW_TOP) {
            if (onDark) {
                return _topOnDark;
            }
            return _topOnLight;
        }
        if (onDark) {
            return _bottomOnDark;
        }
        return _bottomOnLight;
    }

    private function weekdayAbbrev(dayOfWeek as Number or String) as String {
        if (dayOfWeek instanceof Number) {
            var day = dayOfWeek as Number;
            if (day == Gregorian.DAY_SUNDAY) { return "SUN"; }
            if (day == Gregorian.DAY_MONDAY) { return "MON"; }
            if (day == Gregorian.DAY_TUESDAY) { return "TUE"; }
            if (day == Gregorian.DAY_WEDNESDAY) { return "WED"; }
            if (day == Gregorian.DAY_THURSDAY) { return "THU"; }
            if (day == Gregorian.DAY_FRIDAY) { return "FRI"; }
            if (day == Gregorian.DAY_SATURDAY) { return "SAT"; }
        }

        var text = dayOfWeek.toString().toUpper();
        if (text.length() >= 3) {
            return text.substring(0, 3);
        }
        return text;
    }
}
