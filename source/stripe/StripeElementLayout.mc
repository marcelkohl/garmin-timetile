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

    function halfGap() as Number {
        return ELEMENT_GAP / 2;
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

    function safeTopY(stripeWidth as Number, contentCenterY as Number, index as Number) as Number {
        var blockY = blockTopY(stripeWidth, contentCenterY, index);
        var top = blockY - halfGap();
        var stripeTop = TimeTileStyle.STRIPE_TOP_Y;
        if (top < stripeTop) {
            return stripeTop;
        }
        if (top < 0) {
            return 0;
        }
        return top;
    }

    // Exclusive bottom edge so neighboring safe regions meet without overlapping.
    function safeBottomY(stripeWidth as Number, contentCenterY as Number, index as Number) as Number {
        var blockY = blockTopY(stripeWidth, contentCenterY, index);
        var size = elementSize(stripeWidth);
        var bottom = blockY + size + halfGap();
        var stripeBottom = TimeTileStyle.STRIPE_TOP_Y + TimeTileStyle.STRIPE_HEIGHT;
        if (bottom > stripeBottom) {
            return stripeBottom;
        }
        return bottom;
    }

    function anchorY(stripeWidth as Number, contentCenterY as Number, index as Number) as Number {
        return blockCenterY(stripeWidth, contentCenterY, index);
    }

    function topRegionBounds(
        stripeLeftX as Number,
        stripeWidth as Number,
        contentCenterY as Number,
        index as Number
    ) as Array<Number> {
        var left = elementLeftX(stripeLeftX, stripeWidth);
        var size = elementSize(stripeWidth);
        var top = safeTopY(stripeWidth, contentCenterY, index);
        var mid = anchorY(stripeWidth, contentCenterY, index);
        return [left, top, size, mid - top] as Array<Number>;
    }

    function bottomRegionBounds(
        stripeLeftX as Number,
        stripeWidth as Number,
        contentCenterY as Number,
        index as Number
    ) as Array<Number> {
        var left = elementLeftX(stripeLeftX, stripeWidth);
        var size = elementSize(stripeWidth);
        var mid = anchorY(stripeWidth, contentCenterY, index);
        var bottom = safeBottomY(stripeWidth, contentCenterY, index);
        return [left, mid, size, bottom - mid] as Array<Number>;
    }

    function slotSafeBounds(
        stripeLeftX as Number,
        stripeWidth as Number,
        contentCenterY as Number,
        index as Number
    ) as Array<Number> {
        var left = elementLeftX(stripeLeftX, stripeWidth);
        var size = elementSize(stripeWidth);
        var top = safeTopY(stripeWidth, contentCenterY, index);
        var bottom = safeBottomY(stripeWidth, contentCenterY, index);
        return [left, top, size, bottom - top] as Array<Number>;
    }

    function centeredContentX(rowX as Number, rowWidth as Number, contentWidth as Number) as Number {
        return rowX + ((rowWidth - contentWidth) / 2);
    }

    // Top: bottom-anchored at region bottom (center anchor).
    // Bottom: top-anchored at region top (center anchor).
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
