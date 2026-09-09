import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Watch-face delegate: reports partial-update power-budget violations.
class TimeTileDelegate extends WatchUi.WatchFaceDelegate {

    function initialize() {
        WatchFaceDelegate.initialize();
    }

    function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
        System.println(
            "onPowerBudgetExceeded average="
                + powerInfo.executionTimeAverage
                + "ms limit="
                + powerInfo.executionTimeLimit
                + "ms"
        );
    }
}
