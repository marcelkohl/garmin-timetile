import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Top-slot battery: icon in top row, percentage text in bottom row.
class BatteryStripeElement extends StripeElement {

    function initialize() {
        StripeElement.initialize();
    }

    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number
    ) as Void {
        if (rowIndex != 0) {
            return;
        }

        var percentage = batteryPercentage();
        var rowX = rowBounds[0];
        var rowY = rowBounds[1];
        var rowWidth = rowBounds[2];
        var rowHeight = rowBounds[3];

        var totalWidth = TimeTileStyle.BATTERY_BODY_WIDTH + TimeTileStyle.BATTERY_TERMINAL_WIDTH;
        var bodyX = rowX + ((rowWidth - totalWidth) / 2);
        var bodyY = rowY + ((rowHeight - TimeTileStyle.BATTERY_BODY_HEIGHT) / 2);
        var outline = TimeTileStyle.BATTERY_OUTLINE_THICKNESS;
        var innerX = bodyX + outline;
        var innerY = bodyY + outline;
        var innerWidth = TimeTileStyle.BATTERY_BODY_WIDTH - (outline * 2);
        var innerHeight = TimeTileStyle.BATTERY_BODY_HEIGHT - (outline * 2);
        var fillWidth = (innerWidth * percentage) / 100;

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
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != 1) {
            return null;
        }
        return batteryPercentage().format("%d") + "%";
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
