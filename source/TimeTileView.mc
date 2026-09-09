import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TimeTileView extends WatchUi.WatchFace {

    private var _stripePanel as StripePanel;

    function initialize() {
        WatchFace.initialize();
        _stripePanel = new StripePanel(StripeConfiguration.elementIds());
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(TimeTileStyle.BACKGROUND_COLOR, TimeTileStyle.BACKGROUND_COLOR);
        dc.clear();

        _stripePanel.draw(dc);

        var timeCenterX = TimeTileStyle.TIME_AREA_LEFT
            + ((TimeTileStyle.TIME_AREA_RIGHT - TimeTileStyle.TIME_AREA_LEFT) / 2);
        var clockTime = System.getClockTime();
        var is24Hour = System.getDeviceSettings().is24Hour;

        var hourText = formatTwoDigits(hourForDisplay(clockTime.hour, is24Hour));
        var minuteText = formatTwoDigits(clockTime.min);

        dc.setColor(TimeTileStyle.TIME_COLOR, Graphics.COLOR_TRANSPARENT);

        dc.setClip(
            TimeTileStyle.HOUR_CLIP_X,
            TimeTileStyle.HOUR_CLIP_Y,
            TimeTileStyle.HOUR_CLIP_WIDTH,
            TimeTileStyle.HOUR_CLIP_HEIGHT
        );
        dc.drawText(
            timeCenterX,
            TimeTileStyle.HOUR_CENTER_Y,
            TimeTileStyle.TIME_FONT,
            hourText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.clearClip();

        dc.setClip(
            TimeTileStyle.MINUTE_CLIP_X,
            TimeTileStyle.MINUTE_CLIP_Y,
            TimeTileStyle.MINUTE_CLIP_WIDTH,
            TimeTileStyle.MINUTE_CLIP_HEIGHT
        );
        dc.drawText(
            timeCenterX,
            TimeTileStyle.MINUTE_CENTER_Y,
            TimeTileStyle.TIME_FONT,
            minuteText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.clearClip();
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
}
