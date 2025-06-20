from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.entry import Entry
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.utils import get_desktop_applications


class AppLauncher(Window):
    def __init__(self, **kwargs):
        super().__init__(
            layer="top",
            anchor="center",
            exclusivity="auto",
            keyboard_mode="on-demand",
            **kwargs,
        )
        self.add_keybinding("Escape", lambda *_: self.close_window())
        self.add_keybinding(
            "Return", lambda *_: (self.app_list[0].launch(), self.application.quit())
        )

        # all_apps is a list of DesktopApp()
        self.all_apps = get_desktop_applications()
        # Container for app buttons
        self.current_app_list = Box(
            style="min-height: 300px; min-width: 600px; padding: 10px",
            h_expand=True,
            orientation="vertical",
        )
        # Container for app list for scrollability
        self.scrollable = ScrolledWindow(
            name="scrollable",
            style="min-height: 300px; min-width: 600px; padding: 10px",
            child=self.current_app_list,
        )
        # Search bar
        self.search_box = Entry(
            placeholder="Search Desktop Apps...",
            notify_text=lambda entry, *_: self.get_app_list(entry.get_text()),
        )
        # Main container
        self.app_launcher_widget = Box(
            orientation="vertical", children=[self.search_box, self.scrollable]
        )
        self.add(self.app_launcher_widget)
        self.search_box.grab_focus()  # Don't have to click search every time

    # Takes search_box's input and return a list of DesktopApp()s
    def get_app_list(self, query=""):
        query_lower = query.lower()
        self.app_list = [
            app
            for app in self.all_apps
            if query_lower in app.name.lower()
            or app.generic_name
            and query_lower in app.generic_name.lower()
            or app.display_name
            and query_lower in app.display_name.lower()
            or app.icon_name
            and query_lower in app.icon_name.lower()
        ]
        self.current_app_list.children = []
        for app in self.app_list:
            self.current_app_list.add(self.get_app_button(app))

    # Make each app clickable to open it
    def get_app_button(self, app):
        return Button(
            child=Box(
                orientation="horizontal",
                spacing=12,
                children=[
                    Image(pixbuf=app.get_icon_pixbuf(), h_align="start", size=32),
                    Label(
                        label=app.display_name or "Unknown App",
                        v_align="center",
                        h_align="center",
                    ),
                ],
            ),
            tooltip_text=app.description,
            on_clicked=lambda *_: (app.launch(), self.application.quit()),
        )

    def close_window(self, *_):
        self.application.quit()


if __name__ == "__main__":
    app_launcher = AppLauncher()
    app = Application("app-launcher", app_launcher)
    app.run()
