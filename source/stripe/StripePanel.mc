import Toybox.Graphics;
import Toybox.Lang;

// Draws the stripe background and its three interchangeable content slots.
class StripePanel {

    private var _elements as Array<StripeElement>;
    private var _centerX as Number;
    private var _slotCenterYs as Array<Number>;
    private var _stripeColor as Number;
    private var _foregroundColor as Number;

    function initialize(elementIds as Array<Number>) {
        _centerX = TimeTileStyle.STRIPE_CONTENT_CENTER_X;
        _stripeColor = StripeAppearanceConfiguration.stripeColor();
        _foregroundColor = StripeAppearanceConfiguration.stripeForegroundColor();
        _slotCenterYs = [
            TimeTileStyle.TOP_SLOT_CENTER_Y,
            TimeTileStyle.MIDDLE_SLOT_CENTER_Y,
            TimeTileStyle.BOTTOM_SLOT_CENTER_Y
        ] as Array<Number>;

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
                _slotCenterYs[i],
                _foregroundColor,
                _stripeColor
            );
        }
    }
}
