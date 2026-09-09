import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;

// Bottom-slot steps: footprints in top row, step count text in bottom row.
class StepsStripeElement extends StripeElement {

    function initialize() {
        StripeElement.initialize();
    }

    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number
    ) as Void {
        if (rowIndex != 0) {
            return;
        }

        var centerX = rowBounds[0] + (rowBounds[2] / 2);
        var centerY = rowBounds[1] + (rowBounds[3] / 2);
        drawFootprints(dc, centerX, centerY, foregroundColor);
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != 1) {
            return null;
        }
        return formatSteps(stepsCount());
    }

    private function drawFootprints(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number
    ) as Void {
        var leftCenterX = centerX - TimeTileStyle.STEPS_FOOTPRINT_CENTER_OFFSET_X;
        var rightCenterX = centerX + TimeTileStyle.STEPS_FOOTPRINT_CENTER_OFFSET_X;

        var halfVertical = TimeTileStyle.STEPS_FOOTPRINT_VERTICAL_OFFSET / 2;
        var leftCenterY = centerY - halfVertical;
        var rightCenterY = centerY + halfVertical;

        var w = TimeTileStyle.STEPS_FOOTPRINT_WIDTH;
        var h = TimeTileStyle.STEPS_FOOTPRINT_HEIGHT;
        var s = TimeTileStyle.STEPS_FOOTPRINT_SLANT;

        var leftTopY = leftCenterY - (h / 2);
        var leftBottomY = leftCenterY + (h / 2);
        var rightTopY = rightCenterY - (h / 2);
        var rightBottomY = rightCenterY + (h / 2);

        // Left footprint: angled slightly left (toe extends left on the top edge).
        var leftToeTopX = leftCenterX - (w / 2) - s;
        var leftToeBottomX = leftCenterX - (w / 2);
        var leftHeelX = leftCenterX + (w / 2);

        var leftPoints = [
            [leftToeTopX, leftTopY],
            [leftHeelX, leftTopY],
            [leftHeelX, leftBottomY],
            [leftToeBottomX, leftBottomY]
        ] as Array<Graphics.Point2D>;

        // Right footprint: angled slightly right (toe extends right on the bottom edge).
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

    private function stepsCount() as Number {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        if (steps == null) {
            return 0;
        }

        var stepsNum = steps as Number;
        if (stepsNum < 0) {
            return 0;
        }
        if (stepsNum > 999999) {
            return 999999;
        }
        return stepsNum;
    }

    // Deterministic formatting: 0..999 => full number, >=1000 => rounded down to whole K.
    private function formatSteps(stepsNum as Number) as String {
        if (stepsNum >= 1000) {
            var k = stepsNum / 1000;
            return k.format("%d") + "K";
        }
        return stepsNum.format("%d");
    }
}
