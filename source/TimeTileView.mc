import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TimeTileView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(TimeTileStyle.BACKGROUND_COLOR, TimeTileStyle.BACKGROUND_COLOR);
        dc.clear();

        drawStripe(dc);
        drawBattery(dc, batteryPercentage());

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

    private function drawStripe(dc as Dc) as Void {
        dc.setColor(TimeTileStyle.STRIPE_COLOR, TimeTileStyle.STRIPE_COLOR);
        dc.fillRectangle(
            TimeTileStyle.STRIPE_LEFT_X,
            TimeTileStyle.STRIPE_TOP_Y,
            TimeTileStyle.STRIPE_WIDTH,
            TimeTileStyle.STRIPE_HEIGHT
        );
    }

    private function batteryPercentage() as Number {
        var percentage = System.getSystemStats().battery.toNumber();
        if (percentage < 0) {
            return 0;
        }
        if (percentage > 100) {
            return 100;
        }
        return percentage;
    }

    private function drawBattery(dc as Dc, percentage as Number) as Void {
        var totalWidth = TimeTileStyle.BATTERY_BODY_WIDTH + TimeTileStyle.BATTERY_TERMINAL_WIDTH;
        var bodyX = TimeTileStyle.STRIPE_CONTENT_CENTER_X - (totalWidth / 2);
        var bodyY = TimeTileStyle.TOP_SLOT_CENTER_Y - (TimeTileStyle.BATTERY_BODY_HEIGHT / 2);
        var outline = TimeTileStyle.BATTERY_OUTLINE_THICKNESS;
        var innerX = bodyX + outline;
        var innerY = bodyY + outline;
        var innerWidth = TimeTileStyle.BATTERY_BODY_WIDTH - (outline * 2);
        var innerHeight = TimeTileStyle.BATTERY_BODY_HEIGHT - (outline * 2);
        var fillWidth = (innerWidth * percentage) / 100;

        // White body, then restore stripe color inside to form the outline frame.
        dc.setColor(TimeTileStyle.BATTERY_COLOR, TimeTileStyle.BATTERY_COLOR);
        dc.fillRectangle(
            bodyX,
            bodyY,
            TimeTileStyle.BATTERY_BODY_WIDTH,
            TimeTileStyle.BATTERY_BODY_HEIGHT
        );

        dc.setColor(TimeTileStyle.STRIPE_COLOR, TimeTileStyle.STRIPE_COLOR);
        dc.fillRectangle(innerX, innerY, innerWidth, innerHeight);

        if (fillWidth > 0) {
            dc.setColor(TimeTileStyle.BATTERY_COLOR, TimeTileStyle.BATTERY_COLOR);
            dc.fillRectangle(innerX, innerY, fillWidth, innerHeight);
        }

        var terminalX = bodyX + TimeTileStyle.BATTERY_BODY_WIDTH;
        var terminalY = bodyY
            + ((TimeTileStyle.BATTERY_BODY_HEIGHT - TimeTileStyle.BATTERY_TERMINAL_HEIGHT) / 2);
        dc.setColor(TimeTileStyle.BATTERY_COLOR, TimeTileStyle.BATTERY_COLOR);
        dc.fillRectangle(
            terminalX,
            terminalY,
            TimeTileStyle.BATTERY_TERMINAL_WIDTH,
            TimeTileStyle.BATTERY_TERMINAL_HEIGHT
        );

        var labelY = bodyY
            + TimeTileStyle.BATTERY_BODY_HEIGHT
            + TimeTileStyle.BATTERY_TEXT_GAP;
        dc.setColor(TimeTileStyle.BATTERY_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            TimeTileStyle.STRIPE_CONTENT_CENTER_X,
            labelY,
            TimeTileStyle.BATTERY_TEXT_FONT,
            percentage.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_CENTER
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
}
