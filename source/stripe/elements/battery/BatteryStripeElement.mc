import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Battery stripe element: icon in top row, percentage text in bottom row.
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
        if (rowIndex != StripeElementLayout.ROW_TOP) {
            return;
        }

        var percentage = batteryPercentage();
        var rowX = rowBounds[0];
        var rowY = rowBounds[1];
        var rowWidth = rowBounds[2];
        var rowHeight = rowBounds[3];

        var totalWidth = BatteryStripeStyle.BODY_WIDTH + BatteryStripeStyle.TERMINAL_WIDTH;
        var bodyX = rowX + ((rowWidth - totalWidth) / 2);
        var bodyY = rowY + ((rowHeight - BatteryStripeStyle.BODY_HEIGHT) / 2);
        var outline = BatteryStripeStyle.OUTLINE_THICKNESS;
        var innerX = bodyX + outline;
        var innerY = bodyY + outline;
        var innerWidth = BatteryStripeStyle.BODY_WIDTH - (outline * 2);
        var innerHeight = BatteryStripeStyle.BODY_HEIGHT - (outline * 2);
        var fillWidth = (innerWidth * percentage) / 100;

        dc.setColor(foregroundColor, foregroundColor);
        dc.fillRectangle(
            bodyX,
            bodyY,
            BatteryStripeStyle.BODY_WIDTH,
            BatteryStripeStyle.BODY_HEIGHT
        );

        dc.setColor(TimeTileStyle.STRIPE_COLOR, TimeTileStyle.STRIPE_COLOR);
        dc.fillRectangle(innerX, innerY, innerWidth, innerHeight);

        if (fillWidth > 0) {
            dc.setColor(foregroundColor, foregroundColor);
            dc.fillRectangle(innerX, innerY, fillWidth, innerHeight);
        }

        var terminalX = bodyX + BatteryStripeStyle.BODY_WIDTH;
        var terminalY = bodyY
            + ((BatteryStripeStyle.BODY_HEIGHT - BatteryStripeStyle.TERMINAL_HEIGHT) / 2);
        dc.setColor(foregroundColor, foregroundColor);
        dc.fillRectangle(
            terminalX,
            terminalY,
            BatteryStripeStyle.TERMINAL_WIDTH,
            BatteryStripeStyle.TERMINAL_HEIGHT
        );
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != StripeElementLayout.ROW_BOTTOM) {
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
