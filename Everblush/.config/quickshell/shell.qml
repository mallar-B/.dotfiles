import Quickshell
import qs.Modules.bar
import qs.Modules.calendar
import "Modules/bar/components"

ShellRoot{
	Bar {
		DateTime{
			calendarRef: calendarWindow
		}
	}
	Calendar {
		id: calendarWindow
		visible: false
	}
}
