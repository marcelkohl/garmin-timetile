import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeTileApp extends Application.AppBase {

    private var _view as TimeTileView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new $.TimeTileView();
        if (WatchUi has :WatchFaceDelegate) {
            return [_view, new $.TimeTileDelegate()];
        }
        return [_view];
    }

    // Garmin Connect Mobile / Express can change settings while the watchface runs.
    function onSettingsChanged() as Void {
        if (_view != null) {
            (_view as TimeTileView).reloadStripeConfiguration();
        }
        WatchUi.requestUpdate();
    }
}
