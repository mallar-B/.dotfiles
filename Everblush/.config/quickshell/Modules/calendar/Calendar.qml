import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    implicitHeight: 400
    implicitWidth: 300
    color: "#181818"
    anchors.top: true
    exclusionMode: "Ignore"
    margins.top: (screen.height / 100) * 3.5

    property date currentMonth: new Date()   // month being shown
    property date selectedDate: new Date()   // user selection

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

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // --- Month header with navigation ---
        RowLayout {
            Layout.fillWidth: true

            ToolButton {
                text: "‹"
                onClicked: currentMonth = new Date(currentMonth.getFullYear(),
                                                   currentMonth.getMonth() - 1, 1)
            }
            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDate(currentMonth, "MMMM yyyy")
                color: "white"
                font.bold: true
            }
            ToolButton {
                text: "›"
                onClicked: currentMonth = new Date(currentMonth.getFullYear(),
                                                   currentMonth.getMonth() + 1, 1)
            }
        }

        // --- Weekday row ---
        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                delegate: Label {
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    color: "#aaaaaa"
                }
            }
        }

        // --- Days grid ---
        // // --- Days grid ---
GridLayout {
    id: dayGrid
    Layout.fillWidth: true
    Layout.fillHeight: true
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

            // 🔑 make each cell expand to its grid slot
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 6
            color: {
                if (index < dayGrid.firstDay || index >= dayGrid.firstDay + dayGrid.days)
                    return "transparent";
                let d = new Date(dayGrid.year, dayGrid.month, index - dayGrid.firstDay + 1);
                return isSameDay(d, selectedDate) ? "#3D7BFF" : "transparent";
            }

            Label {
                anchors.centerIn: parent
                text: (index < dayGrid.firstDay || index >= dayGrid.firstDay + dayGrid.days)
                      ? ""
                      : index - dayGrid.firstDay + 1
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                enabled: !(index < dayGrid.firstDay || index >= dayGrid.firstDay + dayGrid.days)
                onClicked: {
                    let d = new Date(dayGrid.year, dayGrid.month, index - dayGrid.firstDay + 1);
                    selectedDate = d;
                    console.log("Picked:", d);
                }
            }
        }
    }
}

    }
}

