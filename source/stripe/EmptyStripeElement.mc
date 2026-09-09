import Toybox.Lang;

// Placeholder element that intentionally draws nothing and never acquires data.
class EmptyStripeElement extends StripeElement {

    function initialize() {
        StripeElement.initialize();
    }

    function refreshIfDue(nowSeconds as Number) as Boolean {
        return false;
    }

    function refreshData() as Boolean {
        return false;
    }

    function getRefreshIntervalSeconds() as Number {
        return 0;
    }
}
