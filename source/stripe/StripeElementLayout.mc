import Toybox.Graphics;
import Toybox.Lang;

// Shared stripe element layout formulas.
// Stripe geometry (left/width/height) lives only in TimeTileStyle.
module StripeElementLayout {

    // Inset from each stripe edge to the square element block.
    const STRIPE_CONTENT_HORIZONTAL_PADDING = 10;
    const ELEMENT_GAP = 12;
    const ELEMENT_COUNT = 3;
    const MIN_ELEMENT_SIZE = 2;

    const DEFAULT_ROW_FONT = Graphics.FONT_XTINY;

    const ROW_TOP = 0;
    const ROW_BOTTOM = 1;

    // elementSize = stripeWidth - (2 × horizontalPadding), clamped positive.
    function elementSize(stripeWidth as Number) as Number {
        var size = stripeWidth - (2 * STRIPE_CONTENT_HORIZONTAL_PADDING);
        if (size < MIN_ELEMENT_SIZE) {
            return MIN_ELEMENT_SIZE;
        }
        return size;
    }

    function rowHeight(stripeWidth as Number) as Number {
        return elementSize(stripeWidth) / 2;
    }

    function stackHeight(stripeWidth as Number) as Number {
        var size = elementSize(stripeWidth);
        return (ELEMENT_COUNT * size) + ((ELEMENT_COUNT - 1) * ELEMENT_GAP);
    }

    function stripeCenterX(stripeLeftX as Number, stripeWidth as Number) as Number {
        return stripeLeftX + (stripeWidth / 2);
    }

    function elementLeftX(stripeLeftX as Number, stripeWidth as Number) as Number {
        var size = elementSize(stripeWidth);
        return stripeCenterX(stripeLeftX, stripeWidth) - (size / 2);
    }

    function stackTopY(stripeWidth as Number, contentCenterY as Number) as Number {
        return contentCenterY - (stackHeight(stripeWidth) / 2);
    }

    function blockTopY(stripeWidth as Number, contentCenterY as Number, index as Number) as Number {
        var size = elementSize(stripeWidth);
        return stackTopY(stripeWidth, contentCenterY) + (index * (size + ELEMENT_GAP));
    }

    function blockCenterY(stripeWidth as Number, contentCenterY as Number, index as Number) as Number {
        return blockTopY(stripeWidth, contentCenterY, index) + (elementSize(stripeWidth) / 2);
    }

    function centeredContentX(rowX as Number, rowWidth as Number, contentWidth as Number) as Number {
        return rowX + ((rowWidth - contentWidth) / 2);
    }

    // Top row: content bottom-aligned. Bottom row: content top-aligned.
    function anchoredContentY(
        rowIndex as Number,
        rowY as Number,
        rowHeightValue as Number,
        contentHeight as Number
    ) as Number {
        if (rowIndex == ROW_TOP) {
            return rowY + rowHeightValue - contentHeight;
        }
        return rowY;
    }
}
