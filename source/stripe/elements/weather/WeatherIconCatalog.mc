import Toybox.Lang;
import Toybox.WatchUi;

// Weather-local icon family IDs and OnLight/OnDark resource-pair loading.
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

    function loadOnLight(family as Number) as BitmapResource {
        return WatchUi.loadResource(onLightResourceId(family)) as BitmapResource;
    }

    function loadOnDark(family as Number) as BitmapResource {
        return WatchUi.loadResource(onDarkResourceId(family)) as BitmapResource;
    }

    function onLightResourceId(family as Number) as ResourceId {
        if (family == FAMILY_CLEAR) {
            return $.Rez.Drawables.WeatherClearOnLight;
        }
        if (family == FAMILY_PARTLY_CLOUDY) {
            return $.Rez.Drawables.WeatherPartlyCloudyOnLight;
        }
        if (family == FAMILY_CLOUDY) {
            return $.Rez.Drawables.WeatherCloudyOnLight;
        }
        if (family == FAMILY_RAIN) {
            return $.Rez.Drawables.WeatherRainOnLight;
        }
        if (family == FAMILY_THUNDERSTORM) {
            return $.Rez.Drawables.WeatherThunderstormOnLight;
        }
        if (family == FAMILY_SNOW) {
            return $.Rez.Drawables.WeatherSnowOnLight;
        }
        return $.Rez.Drawables.WeatherUnknownOnLight;
    }

    function onDarkResourceId(family as Number) as ResourceId {
        if (family == FAMILY_CLEAR) {
            return $.Rez.Drawables.WeatherClearOnDark;
        }
        if (family == FAMILY_PARTLY_CLOUDY) {
            return $.Rez.Drawables.WeatherPartlyCloudyOnDark;
        }
        if (family == FAMILY_CLOUDY) {
            return $.Rez.Drawables.WeatherCloudyOnDark;
        }
        if (family == FAMILY_RAIN) {
            return $.Rez.Drawables.WeatherRainOnDark;
        }
        if (family == FAMILY_THUNDERSTORM) {
            return $.Rez.Drawables.WeatherThunderstormOnDark;
        }
        if (family == FAMILY_SNOW) {
            return $.Rez.Drawables.WeatherSnowOnDark;
        }
        return $.Rez.Drawables.WeatherUnknownOnDark;
    }
}
