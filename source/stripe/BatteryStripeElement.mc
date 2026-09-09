import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Top-slot battery icon and percentage for the vertical stripe.
class BatteryStripeElement extends StripeElement {

    function initialize() {
        StripeElement.initialize();
    }

    function draw(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number
    ) as Void {
        var percentage = batteryPercentage();
        var totalWidth = TimeTileStyle.BATTERY_BODY_WIDTH + TimeTileStyle.BATTERY_TERMINAL_WIDTH;
        var bodyX = centerX - (totalWidth / 2);
        var bodyY = centerY - (TimeTileStyle.BATTERY_BODY_HEIGHT / 2);
        var outline = TimeTileStyle.BATTERY_OUTLINE_THICKNESS;
        var innerX = bodyX + outline;
        var innerY = bodyY + outline;
        var innerWidth = TimeTileStyle.BATTERY_BODY_WIDTH - (outline * 2);
        var innerHeight = TimeTileStyle.BATTERY_BODY_HEIGHT - (outline * 2);
        var fillWidth = (innerWidth * percentage) / 100;

        // Foreground body, then restore stripe color inside to form the outline frame.
        dc.setColor(foregroundColor, foregroundColor);
        dc.fillRectangle(
            bodyX,
            bodyY,
            TimeTileStyle.BATTERY_BODY_WIDTH,
            TimeTileStyle.BATTERY_BODY_HEIGHT
        );

        dc.setColor(TimeTileStyle.STRIPE_COLOR, TimeTileStyle.STRIPE_COLOR);
        dc.fillRectangle(innerX, innerY, innerWidth, innerHeight);

        if (fillWidth > 0) {
            dc.setColor(foregroundColor, foregroundColor);
            dc.fillRectangle(innerX, innerY, fillWidth, innerHeight);
        }

        var terminalX = bodyX + TimeTileStyle.BATTERY_BODY_WIDTH;
        var terminalY = bodyY
            + ((TimeTileStyle.BATTERY_BODY_HEIGHT - TimeTileStyle.BATTERY_TERMINAL_HEIGHT) / 2);
        dc.setColor(foregroundColor, foregroundColor);
        dc.fillRectangle(
            terminalX,
            terminalY,
            TimeTileStyle.BATTERY_TERMINAL_WIDTH,
            TimeTileStyle.BATTERY_TERMINAL_HEIGHT
        );

        var labelY = bodyY
            + TimeTileStyle.BATTERY_BODY_HEIGHT
            + TimeTileStyle.BATTERY_TEXT_GAP;
        dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            labelY,
            TimeTileStyle.BATTERY_TEXT_FONT,
            percentage.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_CENTER
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
}
