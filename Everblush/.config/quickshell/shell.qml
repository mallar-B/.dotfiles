import Quickshell
import qs.Modules.bar
import "Modules/bar/components"
import qs.Modules.calendar
import qs.Modules.applauncher
import qs.Modules.notifications

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
	// Notification{}
}
