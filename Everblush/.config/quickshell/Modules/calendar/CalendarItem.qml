import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Common

Item{
  anchors.right: parent.right
  height: 350
  width: 300

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
