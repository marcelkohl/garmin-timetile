import Toybox.Graphics;
import Toybox.Lang;

// Common contract for interchangeable stripe content elements.
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
    }
}
