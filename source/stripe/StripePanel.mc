import Toybox.Graphics;
import Toybox.Lang;

// Draws the stripe background and its three interchangeable square content blocks.
class StripePanel {

    private var _elements as Array<StripeElement>;
    private var _centerX as Number;
    private var _blockCenterYs as Array<Number>;
    private var _stripeColor as Number;
    private var _foregroundColor as Number;
    private var _iconVariant as Number;

    function initialize(elementIds as Array<Number>) {
        _centerX = StripeElementLayout.stripeCenterX(
            TimeTileStyle.STRIPE_LEFT_X,
            TimeTileStyle.STRIPE_WIDTH
        );
        _stripeColor = StripeAppearanceConfiguration.stripeColor();
        _foregroundColor = StripeAppearanceConfiguration.stripeForegroundColor();
        _iconVariant = StripeAppearanceConfiguration.iconVariant();
        _blockCenterYs = buildBlockCenterYs();

        var topId = StripeElementRegistry.NONE;
        var middleId = StripeElementRegistry.NONE;
        var bottomId = StripeElementRegistry.NONE;

        if ((elementIds != null) && (elementIds.size() > 0)) {
            topId = elementIds[0];
        }
        if ((elementIds != null) && (elementIds.size() > 1)) {
            middleId = elementIds[1];
        }
        if ((elementIds != null) && (elementIds.size() > 2)) {
            bottomId = elementIds[2];
        }

        // Create element instances once; never reallocate during onUpdate.
        _elements = [
            StripeElementRegistry.create(topId),
            StripeElementRegistry.create(middleId),
            StripeElementRegistry.create(bottomId)
        ] as Array<StripeElement>;
    }

    private function buildBlockCenterYs() as Array<Number> {
        var stripeWidth = TimeTileStyle.STRIPE_WIDTH;
        var contentCenterY = TimeTileStyle.SCREEN_CENTER_Y;
        return [
            StripeElementLayout.blockCenterY(stripeWidth, contentCenterY, 0),
            StripeElementLayout.blockCenterY(stripeWidth, contentCenterY, 1),
            StripeElementLayout.blockCenterY(stripeWidth, contentCenterY, 2)
        ] as Array<Number>;
    }

    // Ask each existing element to refresh if due. Does not recreate elements.
    // Returns true if at least one element's cached data changed.
    function refreshElementsIfDue(nowSeconds as Number) as Boolean {
        var anyChanged = false;
        for (var i = 0; i < _elements.size(); i += 1) {
            if ((_elements[i] as StripeElement).refreshIfDue(nowSeconds)) {
                anyChanged = true;
            }
        }
        return anyChanged;
    }

    // Low-power path: clip/clear/redraw each due partial-capable slot's safe region.
    function onPartialUpdate(dc as Dc, nowSeconds as Number) as Void {
        var stripeLeft = TimeTileStyle.STRIPE_LEFT_X;
        var stripeWidth = TimeTileStyle.STRIPE_WIDTH;
        var contentCenterY = TimeTileStyle.SCREEN_CENTER_Y;

        for (var i = 0; i < _elements.size(); i += 1) {
            var element = _elements[i] as StripeElement;
            if (!element.supportsPartialUpdates()) {
                continue;
            }
            if (!element.refreshIfDue(nowSeconds)) {
                continue;
            }

            var safe = StripeElementLayout.slotSafeBounds(
                stripeLeft,
                stripeWidth,
                contentCenterY,
                i
            );
            var safeX = safe[0];
            var safeY = safe[1];
            var safeW = safe[2];
            var safeH = safe[3];

            dc.setClip(safeX, safeY, safeW, safeH);
            dc.setColor(_stripeColor, _stripeColor);
            dc.fillRectangle(safeX, safeY, safeW, safeH);
            element.draw(
                dc,
                _centerX,
                _blockCenterYs[i],
                _foregroundColor,
                _stripeColor,
                i,
                _iconVariant
            );
        }

        dc.clearClip();
    }

    function draw(dc as Dc) as Void {
        dc.setColor(_stripeColor, _stripeColor);
        dc.fillRectangle(
            TimeTileStyle.STRIPE_LEFT_X,
            TimeTileStyle.STRIPE_TOP_Y,
            TimeTileStyle.STRIPE_WIDTH,
            TimeTileStyle.STRIPE_HEIGHT
        );

        for (var i = 0; i < _elements.size(); i += 1) {
            (_elements[i] as StripeElement).draw(
                dc,
                _centerX,
                _blockCenterYs[i],
                _foregroundColor,
                _stripeColor,
                i,
                _iconVariant
            );
        }
    }
}
