import Toybox.Graphics;
import Toybox.Lang;

// Placeholder element that intentionally draws nothing.
class EmptyStripeElement extends StripeElement {

    function initialize() {
        StripeElement.initialize();
    }

    function draw(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number
    ) as Void {
    }
}
