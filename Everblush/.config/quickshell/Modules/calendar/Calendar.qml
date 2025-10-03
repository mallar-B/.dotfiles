// TODO:NOTIFICATION HUB WILL BE ADDED IN THIS WINDOW
//
import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
// import QtQuick.Effects
// import Qt5Compat.GraphicalEffects
import qs.Common
import Quickshell.Wayland

PanelWindow {
  id: calendarWindow
  // make room for drop shadow
  implicitHeight: 360
  implicitWidth: 400
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


  Rectangle{
    id: calendarContainer
    color: Theme.background_primary
    height: 350
    width: 300
    x: 10
    y: -400
    radius: 15
    // layer.enabled: true
    // layer.effect: DropShadow {
    //     horizontalOffset: -1
    //     verticalOffset: 1
    //     radius: 8
    //     samples: 12
    //     color: "#000000"
    //     opacity: 1
    //     spread: 0
    // }

    // open and closing animations
    PropertyAnimation{
      id:calendarOpen
      target: calendarContainer
      property: "y"
      to: 0
      duration: Anim.duration.expressiveEffects
      easing.type: Easing.Bezier
			easing.bezierCurve: Anim.curves.expressiveEffects
    }

    PropertyAnimation{
      id:calendarClose
      target: calendarContainer
      property: "y"
      to: -400
      duration: Anim.duration.extraLarge
      easing.type: Easing.Bezier
			easing.bezierCurve: Anim.curves.expressiveFastSpatial
      onStopped: calendarWindow.visible = false
    }

    // main layout
    ColumnLayout {
      anchors.fill: parent
      spacing: 8
      // opacity: calendarWindow.visible ? 1 : 0
      // visible: opacity > 0
      // onVisibleChanged: print("changed")

      // --- Month header with navigation ---
      RowLayout {
        Layout.fillWidth: true

        ToolButton {
          id: arrowIconLeft
          text: ""
          highlighted: false
          onClicked: currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1, 1)
          contentItem: Text{
            text: arrowIconLeft.text
            color: Theme.foreground_secondary
            font.pixelSize: 20
          }
          background: Rectangle{
            color: arrowIconLeft.hovered ? Theme.background_secondary : "transparent"
            border.width: 3
            border.color: Theme.background_primary
            radius: 7
          }
        }
        Label {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          text: Qt.formatDate(currentMonth, "MMMM yyyy")
          color: Theme.foreground_primary
          font.bold: true
        }
        ToolButton {
          id: arrowIconRight
          text: ""
          onClicked: currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 1)
          contentItem: Text{
            text: arrowIconRight.text
            color: Theme.foreground_secondary
            font.pixelSize: 20
          }
          background: Rectangle{
            color: arrowIconRight.hovered ? Theme.background_secondary : "transparent"
            border.width: 3
            border.color: Theme.background_primary
            radius: 7
          }
        }
      }

      // --- Weekday row ---
      Row {
      width: parent.width
        Repeater {
          model: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
          delegate: Label {
            text: modelData
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "#aaaaaa"
            width: parent.width / 7
            height: 30
          }
        }
      }

      // --- Days grid ---
      GridLayout {
        id: dayGrid
        // Layout.fillWidth: true
        // Layout.fillHeight: true
        columns: 7
        rowSpacing: 4
        columnSpacing: 4

        property int year: currentMonth.getFullYear()
        property int month: currentMonth.getMonth()
        property int days: daysInMonth(year, month)
        property int firstDay: firstDayOfMonth(year, month)

        Repeater {
          model: 42   // 6 weeks × 7 days
          delegate: Rectangle {
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: 100

            color: {
              if (index < dayGrid.firstDay || index >= dayGrid.firstDay + dayGrid.days)
                  return "transparent";
              let d = new Date(dayGrid.year, dayGrid.month, index - dayGrid.firstDay + 1);
              if (isSameDay(d, selectedDate)) return Theme.blue;
              if (isSameDay(d,today)) return Theme.magenta;
              return "transparent";
            }

            //Padding around each cell
            Rectangle{
              anchors.fill: parent
              border.width: 5
              border.color: Theme.background_primary
              radius: 10
              color: "transparent"
            }

            // Date numbers
            Label {
              anchors.centerIn: parent
              text: (index < dayGrid.firstDay || index >= dayGrid.firstDay + dayGrid.days)
                    ? ""
                    : index - dayGrid.firstDay + 1
              color: "white"
            }

            // Making interactable
            MouseArea {
              anchors.fill: parent
              enabled: !(index < dayGrid.firstDay || index >= dayGrid.firstDay + dayGrid.days)
              onClicked: {
                  let d = new Date(dayGrid.year, dayGrid.month, index - dayGrid.firstDay + 1);
                  selectedDate = d;
              }
            }
          }
        }
      }
    }
  }
}
