import Toybox.Graphics;
import Toybox.Lang;

// Common contract for interchangeable stripe content elements.
// Owns the shared two-row layout: each row is one bounded area where an
// optional icon/background and optional text are layered together.
class StripeElement {

    function initialize() {
    }

    // Draw this element centered at (centerX, centerY) using foregroundColor.
    function draw(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number
    ) as Void {
        var width = TimeTileStyle.STRIPE_ELEMENT_WIDTH;
        var rowHeight = TimeTileStyle.STRIPE_ROW_HEIGHT;
        var elementX = centerX - (width / 2);
        var elementY = centerY - (TimeTileStyle.STRIPE_ELEMENT_HEIGHT / 2);

        var topBounds = [elementX, elementY, width, rowHeight] as Array<Number>;
        drawBoundedRow(dc, 0, topBounds, foregroundColor);

        var bottomBounds = [
            elementX,
            elementY + rowHeight,
            width,
            rowHeight
        ] as Array<Number>;
        drawBoundedRow(dc, 1, bottomBounds, foregroundColor);
    }

    // rowBounds = [x, y, width, height]
    private function drawBoundedRow(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number
    ) as Void {
        var x = rowBounds[0];
        var y = rowBounds[1];
        var width = rowBounds[2];
        var height = rowBounds[3];

        dc.setClip(x, y, width, height);
        drawRowIcon(dc, rowIndex, rowBounds, foregroundColor);

        var text = getRowText(rowIndex);
        if ((text != null) && (text.length() > 0)) {
            var font = getRowFont(rowIndex);
            var textX = x + (width / 2);
            var textY = y + (height / 2);
            dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
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
    // rowIndex: 0 = top, 1 = bottom.
    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number
    ) as Void {
    }

    // Override to supply optional text layered over the same row.
    function getRowText(rowIndex as Number) as String or Null {
        return null;
    }

    // Override to choose a row-specific font; default is the shared row font.
    function getRowFont(rowIndex as Number) as FontDefinition {
        return TimeTileStyle.STRIPE_ROW_FONT;
    }
}
