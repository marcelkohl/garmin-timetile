import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;

// Steps stripe element: footprints in top row, step count in bottom row.
class StepsStripeElement extends StripeElement {

    private var _steps as Number;
    private var _stepsText as String;

    function initialize() {
        StripeElement.initialize();
        _steps = 0;
        _stepsText = "0";
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

        var centerX = rowBounds[0] + (rowBounds[2] / 2);
        var centerY = rowBounds[1] + (rowBounds[3] / 2);
        drawFootprints(dc, centerX, centerY, foregroundColor);
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != StripeElementLayout.ROW_BOTTOM) {
            return null;
        }
        return _stepsText;
    }

    private function drawFootprints(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number
    ) as Void {
        var leftCenterX = centerX - StepsStripeStyle.FOOTPRINT_CENTER_OFFSET_X;
        var rightCenterX = centerX + StepsStripeStyle.FOOTPRINT_CENTER_OFFSET_X;

        var halfVertical = StepsStripeStyle.FOOTPRINT_VERTICAL_OFFSET / 2;
        var leftCenterY = centerY - halfVertical;
        var rightCenterY = centerY + halfVertical;

        var w = StepsStripeStyle.FOOTPRINT_WIDTH;
        var h = StepsStripeStyle.FOOTPRINT_HEIGHT;
        var s = StepsStripeStyle.FOOTPRINT_SLANT;

        var leftTopY = leftCenterY - (h / 2);
        var leftBottomY = leftCenterY + (h / 2);
        var rightTopY = rightCenterY - (h / 2);
        var rightBottomY = rightCenterY + (h / 2);

        var leftToeTopX = leftCenterX - (w / 2) - s;
        var leftToeBottomX = leftCenterX - (w / 2);
        var leftHeelX = leftCenterX + (w / 2);

        var leftPoints = [
            [leftToeTopX, leftTopY],
            [leftHeelX, leftTopY],
            [leftHeelX, leftBottomY],
            [leftToeBottomX, leftBottomY]
        ] as Array<Graphics.Point2D>;

        var rightHeelX = rightCenterX - (w / 2);
        var rightToeTopX = rightCenterX + (w / 2);
        var rightToeBottomX = rightCenterX + (w / 2) + s;

        var rightPoints = [
            [rightHeelX, rightTopY],
            [rightToeTopX, rightTopY],
            [rightToeBottomX, rightBottomY],
            [rightHeelX, rightBottomY]
        ] as Array<Graphics.Point2D>;

        dc.setColor(foregroundColor, foregroundColor);
        dc.fillPolygon(leftPoints);
        dc.fillPolygon(rightPoints);
    }

    private function formatSteps(stepsNum as Number) as String {
        if (stepsNum >= StepsStripeStyle.COMPACT_THRESHOLD) {
            var k = stepsNum / StepsStripeStyle.COMPACT_THRESHOLD;
            return k.format("%d") + "K";
        }
        return stepsNum.format("%d");
    }
}
