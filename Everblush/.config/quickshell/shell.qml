//@ pragma IconTheme Tela-circle-nord-dark
import Quickshell
import qs.Modules.bar
import qs.Modules.bar.components
import qs.Modules.calendar
import qs.Modules.applauncher
import qs.Modules.notifications
import qs.Modules.volume_osd
import qs.Modules.powermenu

ShellRoot{
	Bar {
		id: bar
		DateTime{
			calendarRef: calendarWindow
		}
	}
	Calendar {
		id: calendarWindow
	}
	Applauncher{}
	Notifications{
		barRef: bar
	}
	VolumeOSD{}
	// PowerMenu{ barRef: bar}
}
