import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class RodFaceView extends WatchUi.WatchFace {
    var width_screen, height_screen;
    var showSeconds = true;
    var batteryIcon as BitmapResource;
    var bellIcon as BitmapResource;

    function initialize() {
        WatchFace.initialize();
        batteryIcon = WatchUi.loadResource($.Rez.Drawables.BatteryIcon);
        bellIcon = WatchUi.loadResource($.Rez.Drawables.BellIcon);
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
        var hour, min, sec;
        var hours_hand = [[5, -30], [-5, -30], [-5, 115], [5, 115]];
        var min_hand = [[5, -30], [-5, -30], [-5, 195], [5, 195]];
        var sec_hand = [[2, -30], [-2, -30], [-2, 195], [2, 195]];

		// Draw the hour hand - convert to minutes then compute angle
        hour = ( ( ( clock_hour % 12 ) * 60 ) + clock_min ); // hour = 2*60.0;
        hour = hour / (12 * 60.0) * Math.PI * 2 - Math.PI;
        drawHand(dc, hour, hours_hand, Graphics.COLOR_LT_GRAY);

        min = ( clock_min / 60.0); // min = 40/60.0;
        min = min * Math.PI * 2 - Math.PI;
        
        drawHand(dc, min, min_hand, Graphics.COLOR_WHITE);
        dc.fillCircle(width_screen/2, height_screen/2, 17);
        
        if(showSeconds) {
            sec = ( clock_sec / 60.0) *  Math.PI * 2 - Math.PI;
            drawHand(dc, sec, sec_hand, Graphics.COLOR_YELLOW);
            dc.fillCircle(width_screen/2, height_screen/2, 9);
        }
    }

    function drawHand(dc, angle, coords, handColour){
        var centerX = width_screen/2;
        var centerY = height_screen/2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        var res = [[0, 0], [0, 0], [0, 0], [0, 0]];

        dc.setColor(handColour, Graphics.COLOR_TRANSPARENT);
        for (var i=0; i < 4; i++) {
            res[i][0] = coords[i][0]*cos - coords[i][1]*sin + centerX;
            res[i][1] = coords[i][1]*cos + coords[i][0]*sin + centerY;
        }
        dc.fillPolygon(res);
    }

    function drawIcons(dc as Dc) {
        var centerX = width_screen/2;
        var centerY = 95;
        var spacing = 10;
        var totalSize = 0;
        var icons = [];

        var notifications = System.getDeviceSettings().notificationCount;
        var battery = System.getSystemStats().battery;

        if (battery <= 5) {icons.add(batteryIcon);}
        if (notifications > 0) {icons.add(bellIcon);}

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
