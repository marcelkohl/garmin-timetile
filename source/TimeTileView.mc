import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class TimeTileView extends WatchUi.WatchFace {

    // Developer layout parameters for fr55 (208 x 208).
    // Time/date are centered in the left content area; the right side is
    // reserved for a future vertical stripe (not drawn yet).
    private const CONTENT_LEFT as Number = 0;
    private const CONTENT_WIDTH as Number = 152;
    private const HOUR_CENTER_Y as Number = 54;
    private const DATE_CENTER_Y as Number = 104;
    private const MINUTE_CENTER_Y as Number = 154;
    private const COLOR_BACKGROUND as Number = Graphics.COLOR_BLACK;
    private const COLOR_TEXT as Number = Graphics.COLOR_WHITE;

    private const TIME_FONT as FontDefinition = Graphics.FONT_NUMBER_THAI_HOT;
    private const DATE_FONT as FontDefinition = Graphics.FONT_TINY;

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(COLOR_BACKGROUND, COLOR_BACKGROUND);
        dc.clear();

        var contentCenterX = CONTENT_LEFT + (CONTENT_WIDTH / 2);
        var clockTime = System.getClockTime();
        var is24Hour = System.getDeviceSettings().is24Hour;

        var hourText = formatTwoDigits(hourForDisplay(clockTime.hour, is24Hour));
        var minuteText = formatTwoDigits(clockTime.min);
        var dateText = formatDate(Gregorian.info(Time.now(), Time.FORMAT_MEDIUM));

        dc.setColor(COLOR_TEXT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            contentCenterX,
            HOUR_CENTER_Y,
            TIME_FONT,
            hourText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            contentCenterX,
            DATE_CENTER_Y,
            DATE_FONT,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            contentCenterX,
            MINUTE_CENTER_Y,
            TIME_FONT,
            minuteText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function hourForDisplay(hour24 as Number, is24Hour as Boolean) as Number {
        if (is24Hour) {
            return hour24;
        }

        var hour12 = hour24 % 12;
        if (hour12 == 0) {
            return 12;
        }
        return hour12;
    }

    private function formatTwoDigits(value as Number) as String {
        return value.format("%02d");
    }

    // Compact English date, e.g. "WED 7 SEP".
    private function formatDate(info as Gregorian.Info) as String {
        return Lang.format("$1$ $2$ $3$", [
            info.day_of_week.toString().toUpper(),
            info.day,
            info.month.toString().toUpper()
        ]);
    }
}
