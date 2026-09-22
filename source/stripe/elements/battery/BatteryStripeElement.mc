import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Battery stripe element: SVG frame + dynamic fill in top row, % text in bottom.
class BatteryStripeElement extends StripeElement {

    private var _percentage as Number;
    private var _percentageText as String;
    private var _frameOnLight as BitmapResource;
    private var _frameOnDark as BitmapResource;
    private var _frameWidth as Number;
    private var _frameHeight as Number;

    function initialize() {
        StripeElement.initialize();
        _percentage = 0;
        _percentageText = "0%";
        _frameOnLight = WatchUi.loadResource($.Rez.Drawables.BatteryFrameOnLight) as BitmapResource;
        _frameOnDark = WatchUi.loadResource($.Rez.Drawables.BatteryFrameOnDark) as BitmapResource;
        _frameWidth = _frameOnLight.getWidth();
        _frameHeight = _frameOnLight.getHeight();
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
        backgroundColor as Number,
        iconVariant as Number
    ) as Void {
        if (rowIndex != StripeElementLayout.ROW_TOP) {
            return;
        }

        var frame = _frameOnLight;
        if (iconVariant == StripeIconVariant.ON_DARK) {
            frame = _frameOnDark;
        }

        var frameX = StripeElementLayout.centeredContentX(
            rowBounds[0],
            rowBounds[2],
            _frameWidth
        );
        var frameY = StripeElementLayout.anchoredContentY(
            rowIndex,
            rowBounds[1],
            rowBounds[3],
            _frameHeight
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
