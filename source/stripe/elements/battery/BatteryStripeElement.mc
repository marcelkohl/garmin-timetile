import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Battery stripe element: SVG frame + dynamic fill in top row, % text in bottom.
class BatteryStripeElement extends StripeElement {

    private var _percentage as Number;
    private var _percentageText as String;
    private var _frameWhite as BitmapResource;
    private var _frameBlack as BitmapResource;

    function initialize() {
        StripeElement.initialize();
        _percentage = 0;
        _percentageText = "0%";
        _frameWhite = WatchUi.loadResource($.Rez.Drawables.BatteryFrameWhite) as BitmapResource;
        _frameBlack = WatchUi.loadResource($.Rez.Drawables.BatteryFrameBlack) as BitmapResource;
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

        var frame = _frameWhite;
        if (foregroundColor == Graphics.COLOR_BLACK) {
            frame = _frameBlack;
        }

        var assetWidth = BatteryStripeStyle.ASSET_WIDTH;
        var assetHeight = BatteryStripeStyle.ASSET_HEIGHT;
        var frameX = StripeElementLayout.centeredContentX(
            rowBounds[0],
            rowBounds[2],
            assetWidth
        );
        var frameY = StripeElementLayout.anchoredContentY(
            rowIndex,
            rowBounds[1],
            rowBounds[3],
            assetHeight
        );

        var maxFillWidth = BatteryStripeStyle.INNER_FILL_MAX_WIDTH;
        var fillWidth = (maxFillWidth * _percentage) / 100;
        if (fillWidth < 0) {
            fillWidth = 0;
        }
        if (fillWidth > maxFillWidth) {
            fillWidth = maxFillWidth;
        }

        // Fill under the frame; unfilled area shows stripe through transparent interior.
        if (fillWidth > 0) {
            dc.setColor(foregroundColor, foregroundColor);
            dc.fillRectangle(
                frameX + BatteryStripeStyle.INNER_FILL_X,
                frameY + BatteryStripeStyle.INNER_FILL_Y,
                fillWidth,
                BatteryStripeStyle.INNER_FILL_HEIGHT
            );
        }

        dc.drawBitmap(frameX, frameY, frame);
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != StripeElementLayout.ROW_BOTTOM) {
            return null;
        }
        return _percentageText;
    }
}
