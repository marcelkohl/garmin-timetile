import Toybox.Graphics;
import Toybox.Lang;

// Common contract for interchangeable stripe content elements.
// Owns the shared two-row layout and generic refresh scheduling state.
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

    // Draw this element centered at (centerX, centerY).
    // foregroundColor: icon/text color; backgroundColor: stripe fill for contrast.
    // Drawing must use cached data only — never call Garmin data APIs here.
    function draw(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Void {
        var width = StripeElementLayout.ELEMENT_WIDTH;
        var rowHeight = StripeElementLayout.ROW_HEIGHT;
        var elementX = centerX - (width / 2);
        var elementY = centerY - (StripeElementLayout.ELEMENT_HEIGHT / 2);

        var topBounds = [elementX, elementY, width, rowHeight] as Array<Number>;
        drawBoundedRow(dc, StripeElementLayout.ROW_TOP, topBounds, foregroundColor, backgroundColor);

        var bottomBounds = [
            elementX,
            elementY + rowHeight,
            width,
            rowHeight
        ] as Array<Number>;
        drawBoundedRow(dc, StripeElementLayout.ROW_BOTTOM, bottomBounds, foregroundColor, backgroundColor);
    }

    // rowBounds = [x, y, width, height]
    private function drawBoundedRow(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Void {
        var x = rowBounds[0];
        var y = rowBounds[1];
        var width = rowBounds[2];
        var height = rowBounds[3];

        dc.setClip(x, y, width, height);
        drawRowIcon(dc, rowIndex, rowBounds, foregroundColor, backgroundColor);

        var text = getRowText(rowIndex);
        if ((text != null) && (text.length() > 0)) {
            var font = getRowFont(rowIndex);
            var textColor = getRowTextColor(rowIndex, foregroundColor, backgroundColor);
            var textX = x + (width / 2);
            var textY = y + (height / 2);
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                textX,
                textY,
                font,
                text,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        dc.clearClip();
    }

    // Override to draw an optional icon/background inside the row bounds.
    // rowIndex: StripeElementLayout.ROW_TOP or ROW_BOTTOM.
    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Void {
    }

    // Override to supply optional text layered over the same row.
    function getRowText(rowIndex as Number) as String or Null {
        return null;
    }

    // Override to choose row text color; default is the stripe foreground.
    function getRowTextColor(
        rowIndex as Number,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Number {
        return foregroundColor;
    }

    // Override to choose a row-specific font; default is the shared row font.
    function getRowFont(rowIndex as Number) as FontDefinition {
        return StripeElementLayout.DEFAULT_ROW_FONT;
    }
}
