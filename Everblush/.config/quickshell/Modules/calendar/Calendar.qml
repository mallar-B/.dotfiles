import Quickshell
import QtQuick
// import QtQuick.Effects
// import Qt5Compat.GraphicalEffects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Common

PanelWindow {
  id: calendarWindow
  // make room for drop shadow
  implicitHeight: calendarContainer.height
  implicitWidth: calendarContainer.width
  anchors.top: true
  exclusionMode: "Ignore" // don't make space
  margins.top: (screen.height / 100) * 3.5
  visible: false
  color: "transparent"

  property date currentMonth: new Date()   // month being shown
  property date selectedDate: new Date()   // user selection
  property date today: new Date()

  function daysInMonth(year, month) {
    return new Date(year, month + 1, 0).getDate();
  }
  function firstDayOfMonth(year, month) {
    return new Date(year, month, 1).getDay(); // 0=Sunday..6=Saturday
  }
  function isSameDay(a, b) {
    return a.getFullYear() === b.getFullYear()
        && a.getMonth() === b.getMonth()
        && a.getDate() === b.getDate();
  }
  // handle opening and closing with animations
  function toggleWindow(){
    if(!calendarWindow.visible){
      calendarWindow.visible = true
      calendarOpen.start()
      print(calendarContainer.x)
    }
    else{
      // closing of the window is included in calendarClose
      calendarClose.start()
    }
  }

  Component.onCompleted: {
    if (this.WlrLayershell != null) {
      this.WlrLayershell.layer = WlrLayer.Top;
      this.WlrLayershell.namespace = "calendar";
    }
  }

	GlobalShortcut{
		name: "toggleCalendar"
		description: "toggles calendar"
		onPressed: toggleWindow()
	}

  Rectangle{
    id: calendarContainer
    scale: 0 //collapsed
    y: -200
    color: Theme.background_primary
    implicitHeight: 350
    implicitWidth: notifHub.width + calItem.width

    NotifHub{
      id:notifHub
    }

    // Calendar
    CalendarItem{
      id:calItem
    }

    // open and closing animations
    ParallelAnimation{
      id:calendarOpen
      NumberAnimation {
        target: calendarContainer
        property: "y"
        to: 0
        duration: Anim.durations.expressiveFastSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anim.curves.standard
      }
      NumberAnimation {
        target: calendarContainer
        property: "scale"
        to: 1
        duration: Anim.durations.expressiveFastSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anim.curves.standard
      }
      NumberAnimation {
        target: calendarContainer
        property: "opacity"
        to: 1
        duration: Anim.durations.expressiveFastSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anim.curves.standard
      }
    }

    ParallelAnimation{
      id:calendarClose
      onStopped: calendarWindow.visible = false
      NumberAnimation{
        target: calendarContainer
        property: "y"
        to: -200
        duration: Anim.durations.expressiveFastSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anim.curves.standard
      }
      NumberAnimation {
        target: calendarContainer
        property: "scale"
        to: 0
        duration: Anim.durations.normal
        easing.type: Easing.Bezier
        easing.bezierCurve: Anim.curves.standard
      }
      NumberAnimation {
        target: calendarContainer
        property: "opacity"
        to: 0
        duration: Anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Anim.curves.standard
      }
    }
  }
}
