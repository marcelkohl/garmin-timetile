import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Steps stripe element: bitmap icon in top row, step count in bottom row.
class StepsStripeElement extends StripeElement {

    private var _steps as Number;
    private var _stepsText as String;
    private var _iconWhite as BitmapResource;
    private var _iconBlack as BitmapResource;

    function initialize() {
        StripeElement.initialize();
        _steps = 0;
        _stepsText = "0";
        // Load both variants once; draw selects from the passed foregroundColor.
        _iconWhite = WatchUi.loadResource($.Rez.Drawables.StepsIconWhite) as BitmapResource;
        _iconBlack = WatchUi.loadResource($.Rez.Drawables.StepsIconBlack) as BitmapResource;
    }

    function getRefreshIntervalSeconds() as Number {
        return StepsStripeStyle.REFRESH_INTERVAL_SECONDS;
    }

    function refreshData() as Boolean {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var stepsNum = 0;
        if (steps != null) {
            stepsNum = steps as Number;
        }
        if (stepsNum < 0) {
            stepsNum = 0;
        }
        if (stepsNum > 999999) {
            stepsNum = 999999;
        }

        var stepsText = formatSteps(stepsNum);
        var changed = (_steps != stepsNum) || (!_stepsText.equals(stepsText));
        _steps = stepsNum;
        _stepsText = stepsText;
        return changed;
    }

    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number,
        backgroundColor as Number
    ) as Void {
        if (rowIndex != StripeElementLayout.ROW_TOP) {
            return;
        }

        var icon = _iconWhite;
        if (foregroundColor == Graphics.COLOR_BLACK) {
            icon = _iconBlack;
        }

        var iconWidth = icon.getWidth();
        var iconHeight = icon.getHeight();
        var x = StripeElementLayout.centeredContentX(rowBounds[0], rowBounds[2], iconWidth);
        var y = StripeElementLayout.anchoredContentY(
            rowIndex,
            rowBounds[1],
            rowBounds[3],
            iconHeight
        );
        dc.drawBitmap(x, y, icon);
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != StripeElementLayout.ROW_BOTTOM) {
            return null;
        }
        return _stepsText;
    }

    private function formatSteps(stepsNum as Number) as String {
        if (stepsNum >= StepsStripeStyle.COMPACT_THRESHOLD) {
            var k = stepsNum / StepsStripeStyle.COMPACT_THRESHOLD;
            return k.format("%d") + "K";
        }
        return stepsNum.format("%d");
    }
}
