import Quickshell
import qs.Modules.bar
import qs.Modules.calendar
import qs.Modules.applauncher
import "Modules/bar/components"

ShellRoot{
	Bar {
		DateTime{
			calendarRef: calendarWindow
		}
	}
	Calendar {
		id: calendarWindow
	}
	Applauncher{}
}
