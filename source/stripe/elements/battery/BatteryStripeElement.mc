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

        // 1) Frame bitmap first (white interior is opaque).
        dc.drawBitmap(frameX, frameY, frame);

        // 2) Charge bar above the SVG, attached to the same frame origin.
        drawChargeBar(dc, frameX, frameY, foregroundColor);
    }

    // Draw the percentage fill relative to frameX/frameY, clamped to the bitmap.
    private function drawChargeBar(
        dc as Dc,
        frameX as Number,
        frameY as Number,
        foregroundColor as Number
    ) as Void {
        // Clamp configured rectangle against loaded bitmap bounds.
        var startX = BatteryStripeStyle.FILL_START_X;
        var startY = BatteryStripeStyle.FILL_START_Y;
        var maxWidth = BatteryStripeStyle.FILL_MAX_WIDTH;
        var thickness = BatteryStripeStyle.FILL_THICKNESS;

        if (startX < 0) {
            startX = 0;
        }
        if (startY < 0) {
            startY = 0;
        }
        if (startX >= _frameWidth) {
            return;
        }
        if (startY >= _frameHeight) {
            return;
        }

        var maxWInside = _frameWidth - startX;
        var maxHInside = _frameHeight - startY;
        if (maxWidth > maxWInside) {
            maxWidth = maxWInside;
        }
        if (thickness > maxHInside) {
            thickness = maxHInside;
        }
        if ((maxWidth <= 0) || (thickness <= 0)) {
            return;
        }

        var fillWidth = (maxWidth * _percentage) / 100;
        if (fillWidth < 0) {
            fillWidth = 0;
        }
        if (fillWidth > maxWidth) {
            fillWidth = maxWidth;
        }
        if (fillWidth <= 0) {
            return;
        }

        dc.setColor(foregroundColor, foregroundColor);
        dc.fillRectangle(
            frameX + startX,
            frameY + startY,
            fillWidth,
            thickness
        );
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != StripeElementLayout.ROW_BOTTOM) {
            return null;
        }
        return _percentageText;
    }
}
