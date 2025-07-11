# import fabric
from fabric import Application
from fabric.utils import get_relative_path
from fabric.widgets.centerbox import CenterBox
from fabric.system_tray.widgets import SystemTray
from fabric.widgets.wayland import WaylandWindow as Window
from widgets.workspaces import Workspaces
from widgets.date import Date
from widgets.app_title import AppTitle
from widgets.bar_volume import BarVolume
from widgets.system_info import SystemInfo
from widgets.powerbutton import PowerButton


def SysTray():
    sysTray = SystemTray(name="systray-container", icon_size=18)

    return sysTray


class StatusBar(Window):
    def __init__(self, **kwargs):
        super().__init__(
            layer="top", anchor="left top right", exclusivity="auto", **kwargs
        )
        self.BarWidget = CenterBox(
            name="bar",
            start_children=[Workspaces(), AppTitle()],
            center_children=[Date()],
            end_children=[SystemInfo(), BarVolume(), SysTray(), PowerButton()],
        )
        self.children = self.BarWidget


if __name__ == "__main__":
    bar = StatusBar()
    app = Application("bar-example", bar)
    app.set_stylesheet_from_file(get_relative_path("./style.css"))
    app.run()
