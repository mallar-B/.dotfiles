import json
from fabric.hyprland.widgets import ActiveWindow
from fabric.hyprland.widgets import get_hyprland_connection
from fabric.utils import bulk_connect
from fabric.utils import FormattedString, truncate


class AppTitle(ActiveWindow):
    def __init__(self, **kwargs):
        super().__init__(
            name="app-title",
            formatter=FormattedString(
                "{'' if not win_title or win_title == 'unknown' else truncate(win_title, 42)}",
                truncate=truncate,
            ),
            **kwargs
        )
        self.curr_full_screens = set()

        bulk_connect(
            # self.connection comes from ActiveWindow
            self.connection,
            {
                "event::fullscreen": self.set_full_screen,
                "event::closewindow": self.unset_full_screen,
                "event::activewindow": self.check_full_screen,
            },
        )

    def set_full_screen(self, *_):
        # This will return the result of  hyprctl activewindow as a string
        activeWindowStr = self.connection.send_command("j/activewindow").reply.decode()
        # Read as json
        # Possible value 0,1,2
        fullScreenValue = json.loads(activeWindowStr).get("fullscreen")
        windowId = json.loads(activeWindowStr).get("address").lstrip("0x")
        if fullScreenValue != 0:
            self.curr_full_screens.add(windowId)
            print("current ids are", self.curr_full_screens)
            self.check_full_screen()
            return
        self.curr_full_screens.remove(windowId)
        self.check_full_screen()
        print("current ids are", self.curr_full_screens)

    def unset_full_screen(self, _, event):
        print("called by event")
        print(type(self.curr_full_screens))
        print("removing", event.data)
        self.curr_full_screens.remove(str(event.data[0]))
        self.check_full_screen()

    def check_full_screen(self, *_):
        activeWindowStr = self.connection.send_command("j/activewindow").reply.decode()
        windowId = json.loads(activeWindowStr).get("address").lstrip("0x")
        if windowId in self.curr_full_screens:
            self.set_name("app-title-fullscreen")
        else:
            self.set_name("app-title")
