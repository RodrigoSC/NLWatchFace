import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class RodFaceView extends WatchUi.WatchFace {
    var width_screen, height_screen;
    var showSeconds = true;
    var batteryIcon as BitmapResource;
    var notificationIcon as BitmapResource;

    function initialize() {
        WatchFace.initialize();
        batteryIcon = WatchUi.loadResource($.Rez.Drawables.BatteryIcon);
        notificationIcon = WatchUi.loadResource($.Rez.Drawables.NotificationIcon);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        width_screen = dc.getWidth();
		height_screen = dc.getHeight();
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get and show the current time
        var clockTime = System.getClockTime();

        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_LONG);
        
        var dateStr = Lang.format("$1$ $2$    ", [info.day_of_week, info.day]);
        var dateView = View.findDrawableById("DateLabel") as Text;
        dateView.setText(dateStr);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        drawIcons(dc);
        drawHands(dc, clockTime.hour, clockTime.min, clockTime.sec);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        showSeconds = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        showSeconds = true;
        requestUpdate();
    }

    function drawHands(dc, clock_hour, clock_min, clock_sec) {
		// Draw the hour hand - convert to minutes then compute angle
        var hour = ( ( ( clock_hour % 12 ) * 60 ) + clock_min ); // hour = 2*60.0;
        hour = hour / (12 * 60.0) * Math.PI * 2 - Math.PI;
        drawHand(dc, hour, 5, 115, 17, Graphics.COLOR_LT_GRAY);

        var min = ( clock_min / 60.0); // min = 40/60.0;
        min = min * Math.PI * 2 - Math.PI;
        drawHand(dc, min, 5, 195, 17, Graphics.COLOR_WHITE);
        
        if(showSeconds) {
            var sec = ( clock_sec / 60.0) *  Math.PI * 2 - Math.PI;
            drawHand(dc, sec, 2, 195, 9, Graphics.COLOR_YELLOW);
        }
    }

    function drawHand(dc, angle, half_width, long_length, circle_radius, handColour){
        var shadowOffset = 2;
        var shadowColor = 0x7F000000;
        var centerX = width_screen/2;
        var centerY = height_screen/2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        var coords = [[half_width, -30], [-half_width, -30], [-half_width, long_length], [half_width, long_length]];
        var res = [[0, 0], [0, 0], [0, 0], [0, 0]];

        dc.setFill(0x7F000000);
        dc.fillCircle(width_screen/2 + shadowOffset, height_screen/2 + shadowOffset, circle_radius);
        for (var i=0; i < 4; i++) {
            res[i][0] = coords[i][0]*cos - coords[i][1]*sin + centerX + shadowOffset;
            res[i][1] = coords[i][1]*cos + coords[i][0]*sin + centerY + shadowOffset;
        }
        dc.fillPolygon(res);

        dc.setColor(handColour, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(width_screen/2, height_screen/2, circle_radius);
        for (var i=0; i < 4; i++) {
            res[i][0] -= shadowOffset;
            res[i][1] -= shadowOffset;
        }
        dc.fillPolygon(res);
    }

    function drawIcons(dc as Dc) {
        var centerX = width_screen/2;
        var centerY = 90;
        var spacing = 10;
        var totalSize = 0;
        var icons = [];

        var notifications = System.getDeviceSettings().notificationCount;
        var battery = System.getSystemStats().battery;

        if (battery <= 5) {icons.add(batteryIcon);}
        if (notifications > 0) {icons.add(notificationIcon);}

        for(var i = 0; i < icons.size(); i ++) {
            totalSize += icons[i].getWidth();
        }
        
        totalSize += (icons.size() - 1) * spacing;
        var xPos = centerX - totalSize / 2;

        for(var i = 0; i < icons.size(); i ++) {
            var yPos = centerY - icons[i].getHeight() / 2 ;
            dc.drawBitmap2(xPos, yPos, icons[i], {});
            xPos += icons[i].getWidth() + spacing;
        }
    }
}
