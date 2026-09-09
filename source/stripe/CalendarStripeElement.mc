import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

// Middle-slot calendar: filled weekday row + outlined day row.
class CalendarStripeElement extends StripeElement {

    function initialize() {
        StripeElement.initialize();
    }

    function drawRowIcon(
        dc as Dc,
        rowIndex as Number,
        rowBounds as Array<Number>,
        foregroundColor as Number
    ) as Void {
        var inset = TimeTileStyle.STRIPE_ROW_ICON_INSET;
        var outline = TimeTileStyle.CALENDAR_OUTLINE_THICKNESS;
        var x = rowBounds[0] + inset;
        var y = rowBounds[1] + TimeTileStyle.STRIPE_ROW_PADDING;
        var width = rowBounds[2] - (inset * 2);
        var height = rowBounds[3] - (TimeTileStyle.STRIPE_ROW_PADDING * 2);

        if (width <= 0 || height <= 0) {
            return;
        }

        if (rowIndex == 0) {
            // Filled rectangular shape for the weekday header.
            // Weekday text is drawn here in the stripe color so it stays
            // readable on the filled foreground shape (base text uses foreground).
            dc.setColor(foregroundColor, foregroundColor);
            dc.fillRectangle(x, y, width, height);

            var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            dc.setColor(TimeTileStyle.STRIPE_COLOR, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                rowBounds[0] + (rowBounds[2] / 2),
                rowBounds[1] + (rowBounds[3] / 2),
                TimeTileStyle.STRIPE_ROW_FONT,
                weekdayAbbrev(info.day_of_week),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
        }

        if (rowIndex == 1) {
            // Outlined rectangular shape for the day value.
            dc.setColor(foregroundColor, foregroundColor);
            dc.fillRectangle(x, y, width, height);
            dc.setColor(TimeTileStyle.STRIPE_COLOR, TimeTileStyle.STRIPE_COLOR);
            if ((width > outline * 2) && (height > outline * 2)) {
                dc.fillRectangle(
                    x + outline,
                    y + outline,
                    width - (outline * 2),
                    height - (outline * 2)
                );
            }
        }
    }

    function getRowText(rowIndex as Number) as String or Null {
        if (rowIndex != 1) {
            return null;
        }
        // Day number overlaid on the outlined bottom shape via base-class text.
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return info.day.format("%d");
    }

    private function weekdayAbbrev(dayOfWeek as Number or String) as String {
        if (dayOfWeek instanceof Number) {
            var day = dayOfWeek as Number;
            if (day == Gregorian.DAY_SUNDAY) { return "SUN"; }
            if (day == Gregorian.DAY_MONDAY) { return "MON"; }
            if (day == Gregorian.DAY_TUESDAY) { return "TUE"; }
            if (day == Gregorian.DAY_WEDNESDAY) { return "WED"; }
            if (day == Gregorian.DAY_THURSDAY) { return "THU"; }
            if (day == Gregorian.DAY_FRIDAY) { return "FRI"; }
            if (day == Gregorian.DAY_SATURDAY) { return "SAT"; }
        }

        var text = dayOfWeek.toString().toUpper();
        if (text.length() >= 3) {
            return text.substring(0, 3);
        }
        return text;
    }
}
