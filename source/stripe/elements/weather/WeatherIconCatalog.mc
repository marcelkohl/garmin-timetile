import Toybox.Lang;
import Toybox.WatchUi;

// Weather-local icon family IDs and resource-pair loading.
// Not a global stripe-element registry.
module WeatherIconCatalog {

    const FAMILY_CLEAR = 0;
    const FAMILY_PARTLY_CLOUDY = 1;
    const FAMILY_CLOUDY = 2;
    const FAMILY_RAIN = 3;
    const FAMILY_THUNDERSTORM = 4;
    const FAMILY_SNOW = 5;
    const FAMILY_UNKNOWN = 6;

    // Unset sentinel so the first refresh always loads a pair.
    const FAMILY_UNSET = -1;

    function loadWhite(family as Number) as BitmapResource {
        return WatchUi.loadResource(whiteResourceId(family)) as BitmapResource;
    }

    function loadBlack(family as Number) as BitmapResource {
        return WatchUi.loadResource(blackResourceId(family)) as BitmapResource;
    }

    function whiteResourceId(family as Number) as ResourceId {
        if (family == FAMILY_CLEAR) {
            return $.Rez.Drawables.WeatherClearWhite;
        }
        if (family == FAMILY_PARTLY_CLOUDY) {
            return $.Rez.Drawables.WeatherPartlyCloudyWhite;
        }
        if (family == FAMILY_CLOUDY) {
            return $.Rez.Drawables.WeatherCloudyWhite;
        }
        if (family == FAMILY_RAIN) {
            return $.Rez.Drawables.WeatherRainWhite;
        }
        if (family == FAMILY_THUNDERSTORM) {
            return $.Rez.Drawables.WeatherThunderstormWhite;
        }
        if (family == FAMILY_SNOW) {
            return $.Rez.Drawables.WeatherSnowWhite;
        }
        return $.Rez.Drawables.WeatherUnknownWhite;
    }

    function blackResourceId(family as Number) as ResourceId {
        if (family == FAMILY_CLEAR) {
            return $.Rez.Drawables.WeatherClearBlack;
        }
        if (family == FAMILY_PARTLY_CLOUDY) {
            return $.Rez.Drawables.WeatherPartlyCloudyBlack;
        }
        if (family == FAMILY_CLOUDY) {
            return $.Rez.Drawables.WeatherCloudyBlack;
        }
        if (family == FAMILY_RAIN) {
            return $.Rez.Drawables.WeatherRainBlack;
        }
        if (family == FAMILY_THUNDERSTORM) {
            return $.Rez.Drawables.WeatherThunderstormBlack;
        }
        if (family == FAMILY_SNOW) {
            return $.Rez.Drawables.WeatherSnowBlack;
        }
        return $.Rez.Drawables.WeatherUnknownBlack;
    }
}
