import Toybox.Graphics;
import Toybox.Lang;

// Common contract for interchangeable stripe content elements.
// Owns the shared two-row safe-region layout and generic refresh scheduling.
// Element-specific intervals and data fetches live in subclasses.
class StripeElement {

    // null means this instance has never been refreshed.
    private var _lastRefreshSeconds as Number or Null;

    function initialize() {
        _lastRefreshSeconds = null;
    }

    // Refresh cached data when due. Returns true if cached data changed.
    function refreshIfDue(nowSeconds as Number) as Boolean {
        if (!isRefreshDue(nowSeconds)) {
            return false;
        }

        var changed = refreshData();
        _lastRefreshSeconds = nowSeconds;
        return changed;
    }

    // Fetch and cache element data. Override in subclasses that acquire data.
    // Returns true when cached values changed.
    function refreshData() as Boolean {
        return false;
    }

    // Seconds between data refreshes. Override per element; base is unused.
    function getRefreshIntervalSeconds() as Number {
        return 0;
    }

    // Whether this element may refresh/redraw during WatchFace.onPartialUpdate.
    // Default false — only high-frequency elements (e.g. Steps) opt in.
    function supportsPartialUpdates() as Boolean {
        return false;
    }

    private function isRefreshDue(nowSeconds as Number) as Boolean {
        if (_lastRefreshSeconds == null) {
            return true;
        }

        var elapsed = nowSeconds - (_lastRefreshSeconds as Number);
        // Clock rollback / rollover: treat as due.
        if (elapsed < 0) {
            return true;
        }

        return elapsed >= getRefreshIntervalSeconds();
    }

    // Draw using center-anchored top/bottom safe regions for slotIndex (0..2).
    // iconVariant: StripeIconVariant.ON_LIGHT or ON_DARK (resolved by panel).
    // Drawing must use cached data only — never call Garmin data APIs here.
    function draw(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number,
        backgroundColor as Number,
        slotIndex as Number,
        iconVariant as Number
    ) as Void {
        var stripeLeft = TimeTileStyle.STRIPE_LEFT_X;
        var stripeWidth = TimeTileStyle.STRIPE_WIDTH;
        var contentCenterY = TimeTileStyle.SCREEN_CENTER_Y;

        var topBounds = StripeElementLayout.topRegionBounds(
            stripeLeft,
            stripeWidth,
            contentCenterY,
            slotIndex
        );
        drawBoundedRow(
            dc,
            StripeElementLayout.ROW_TOP,
            topBounds,
            foregroundColor,
            backgroundColor,
            iconVariant
        );

        var bottomBounds = StripeElementLayout.bottomRegionBounds(
            stripeLeft,
            stripeWidth,
            contentCenterY,
            slotIndex
        );
        drawBoundedRow(
            dc,
            StripeElementLayout.ROW_BOTTOM,
            bottomBounds,
            foregroundColor,
            backgroundColor,
            iconVariant
        );
    }

    // rowBounds = [x, y, width, height]
    private function drawBoundedRow(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number,
        backgroundColor as Number,
        iconVariant as Number
    ) as Void {
        var x = rowBounds[0];
        var y = rowBounds[1];
        var width = rowBounds[2];
        var height = rowBounds[3];

        dc.setClip(x, y, width, height);
        drawRowIcon(dc, rowIndex, rowBounds, foregroundColor, backgroundColor, iconVariant);

        var text = getRowText(rowIndex);
        if ((text != null) && (text.length() > 0)) {
            var font = getRowFont(rowIndex);
            var textColor = getRowTextColor(rowIndex, foregroundColor, backgroundColor);
            var dims = dc.getTextDimensions(text, font);
            var textHeight = dims[1];
            var textX = x + (width / 2);
            var textY = StripeElementLayout.anchoredContentY(rowIndex, y, height, textHeight);
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                textX,
                textY,
                font,
                text,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        dc.clearClip();
    }

    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number,
        backgroundColor as Number,
        iconVariant as Number
    ) as Void {
    }

    function getRowText(rowIndex as Number) as String or Null {
        return null;
    }

    function getRowTextColor(
        rowIndex as Number,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Number {
        return foregroundColor;
    }

    function getRowFont(rowIndex as Number) as FontDefinition {
        return StripeElementLayout.DEFAULT_ROW_FONT;
    }
}
