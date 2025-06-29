from time import sleep
from fabric import Application
from fabric.utils import (
    GLib,
    exec_shell_command,
    get_relative_path,
    idle_add,
    invoke_repeater,
    time,
)
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.label import Label
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.widgets.revealer import Revealer
from fabric.widgets.image import Image
from utils import add_cursor_hover


class PowerMenu(Window):
    def __init__(self, **kwargs):
        super().__init__(
            name="powermenu-window",
            title="powermenu",
            layer="overlay",
            style="margin:10px;margin-right:10px;background-color:transparent",
            anchor="top right",
            visible=False,
        )
        self.power_menu_box = Box(
            name="powermenu-container",
            style="""
                min-width: 150px;
                background-color: var(--window-bg);
                margin:10px;
                border-radius:10px;
                border: 3px solid var(--border-color)
            """,
            children=[
                self.get_button(
                    "system-shutdown-symbolic",
                    "bash -c 'systemctl poweroff'",
                    color="var(--color1)",
                    color_hovered="var(--color9)",
                ),
                self.get_button(
                    "system-suspend-symbolic",
                    "bash -c 'systemctl suspend'",
                    color="var(--color5)",
                    color_hovered="var(--color13)",
                ),
                self.get_button(
                    "system-reboot-symbolic",
                    "bash -c 'systemctl reboot'",
                    color="var(--color2)",
                    color_hovered="var(--color10)",
                ),
                self.get_button(
                    "xfce-system-lock-symbolic",
                    "bash -c 'hyprlock'",
                    color="var(--color3)",
                    color_hovered="var(--color11)",
                ),
                self.get_button(
                    "system-log-out-symbolic",
                    "bash -c 'pkill -u $USER'",
                    color="var(--color4)",
                    color_hovered="var(--color12)",
                ),
            ],
            orientation="vertical",
        )
        self.revealer = Revealer(
            style="padding:1px",
            transition_type="slide-down",
            transition_duration=400,
            child_revealed=False,
        )
        self.revealer.children = self.power_menu_box
        self.add(
            ## This took me 9 hours to implement without any bugs
            Box(
                orientation="vertical",
                style="min-width:1px;min-height:1px",  # very important otherwise box will not render properly
                children=self.revealer,
            )
        )
        add_cursor_hover(self)
        self.is_powermenu_visible = False

    def toggle_powermenu(self, *_):
        self.is_powermenu_visible = not self.is_powermenu_visible

        if self.is_powermenu_visible:
            self.show()
            self.show_all()
            idle_add(lambda: self.revealer.set_reveal_child(True))
        else:
            self.revealer.set_reveal_child(False)
            GLib.timeout_add(450, lambda: self.hide())

    def get_button(self, name, cmd, color="white", color_hovered="white", *_):
        default_style = f"""
            padding: 10px;
            min-height: 90px;
            border-radius: 10px;
            color:{color};
            background-color: var(--window-bg);
            transition: all 0.2s ease-in-out;
            """
        hovered_style = f"""
            padding: 10px;
            min-height: 90px;
            border-radius: 10px;
            color:{color_hovered};
            background-color: var(--module-bg);
            transition: all 0.2s ease-in-out;
            """
        icon = Image(
            name="powermenu-icons",
            icon_name=str(name),
            icon_size=64,
        )

        button = Button(
            style=default_style,
            style_classes="huha",
            child=icon,
            on_clicked=lambda *_: exec_shell_command(cmd),
        )
        add_cursor_hover(button)
        button.connect(
            "enter-notify-event",
            lambda w, e: w.set_style(hovered_style),
        )
        button.connect(
            "leave-notify-event",
            lambda w, e: w.set_style(default_style),
        )
        return button


if __name__ == "__main__":
    powermenu = PowerMenu()
    app = Application("powermenu", powermenu)
    app.set_stylesheet_from_file(get_relative_path("./style.css"))
    app.run()
