import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

// Middle-slot calendar icon with weekday and day/month text.
class CalendarStripeElement extends StripeElement {

    function initialize() {
        StripeElement.initialize();
    }

    function draw(
        dc as Dc,
        centerX as Number,
        centerY as Number,
        foregroundColor as Number
    ) as Void {
        var calendar = currentCalendarText();
        var weekdayText = calendar[0];
        var dateText = calendar[1];

        var outline = TimeTileStyle.CALENDAR_OUTLINE_THICKNESS;
        var bodyX = centerX - (TimeTileStyle.CALENDAR_WIDTH / 2);
        var bodyY = centerY - (TimeTileStyle.CALENDAR_HEIGHT / 2);

        dc.setColor(foregroundColor, foregroundColor);
        dc.fillRectangle(
            bodyX,
            bodyY,
            TimeTileStyle.CALENDAR_WIDTH,
            TimeTileStyle.CALENDAR_HEIGHT
        );

        dc.setColor(TimeTileStyle.STRIPE_COLOR, TimeTileStyle.STRIPE_COLOR);
        dc.fillRectangle(
            bodyX + outline,
            bodyY + outline,
            TimeTileStyle.CALENDAR_WIDTH - (outline * 2),
            TimeTileStyle.CALENDAR_HEIGHT - (outline * 2)
        );

        var dividerY = bodyY + TimeTileStyle.CALENDAR_HEADER_HEIGHT;
        dc.setColor(foregroundColor, foregroundColor);
        dc.fillRectangle(
            bodyX + outline,
            dividerY - (outline / 2),
            TimeTileStyle.CALENDAR_WIDTH - (outline * 2),
            outline
        );

        var headerCenterY = bodyY + (TimeTileStyle.CALENDAR_HEADER_HEIGHT / 2);
        var bodyCenterY = dividerY
            + ((TimeTileStyle.CALENDAR_HEIGHT - TimeTileStyle.CALENDAR_HEADER_HEIGHT) / 2);

        dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            headerCenterY,
            TimeTileStyle.CALENDAR_WEEKDAY_FONT,
            weekdayText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            centerX,
            bodyCenterY,
            TimeTileStyle.CALENDAR_DATE_FONT,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function currentCalendarText() as Array<String> {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return [
            weekdayAbbrev(info.day_of_week),
            dayMonthText(info.day, info.month)
        ] as Array<String>;
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

    private function monthAbbrev(month as Number or String) as String {
        if (month instanceof Number) {
            var monthNum = month as Number;
            if (monthNum == Gregorian.MONTH_JANUARY) { return "JAN"; }
            if (monthNum == Gregorian.MONTH_FEBRUARY) { return "FEB"; }
            if (monthNum == Gregorian.MONTH_MARCH) { return "MAR"; }
            if (monthNum == Gregorian.MONTH_APRIL) { return "APR"; }
            if (monthNum == Gregorian.MONTH_MAY) { return "MAY"; }
            if (monthNum == Gregorian.MONTH_JUNE) { return "JUN"; }
            if (monthNum == Gregorian.MONTH_JULY) { return "JUL"; }
            if (monthNum == Gregorian.MONTH_AUGUST) { return "AUG"; }
            if (monthNum == Gregorian.MONTH_SEPTEMBER) { return "SEP"; }
            if (monthNum == Gregorian.MONTH_OCTOBER) { return "OCT"; }
            if (monthNum == Gregorian.MONTH_NOVEMBER) { return "NOV"; }
            if (monthNum == Gregorian.MONTH_DECEMBER) { return "DEC"; }
        }

        var text = month.toString().toUpper();
        if (text.length() >= 3) {
            return text.substring(0, 3);
        }
        return text;
    }

    private function dayMonthText(day as Number, month as Number or String) as String {
        return day.format("%d") + "/" + monthAbbrev(month);
    }
}
