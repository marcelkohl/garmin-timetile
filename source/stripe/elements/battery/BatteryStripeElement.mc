import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Battery stripe element: icon in top row, percentage text in bottom row.
class BatteryStripeElement extends StripeElement {

    private var _percentage as Number;
    private var _percentageText as String;

    function initialize() {
        StripeElement.initialize();
        _percentage = 0;
        _percentageText = "0%";
    }

    function getRefreshIntervalSeconds() as Number {
        return BatteryStripeStyle.REFRESH_INTERVAL_SECONDS;
    }

    function refreshData() as Boolean {
        var percentage = System.getSystemStats().battery.toNumber();
        if (percentage < 0) {
            percentage = 0;
        }
        if (percentage > 100) {
            percentage = 100;
        }

        var percentageText = percentage.format("%d") + "%";
        var changed = (_percentage != percentage) || (!_percentageText.equals(percentageText));
        _percentage = percentage;
        _percentageText = percentageText;
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

        var percentage = _percentage;
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

        dc.setColor(backgroundColor, backgroundColor);
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
        return _percentageText;
    }
}
