from fabric.widgets.button import Button
from utils import add_cursor_hover
from window_layers.powermenu.powermenu import PowerMenu


def PowerButton():
    powermenu = PowerMenu()
    button = Button(
        name="power-button",
        label="",
        on_clicked=lambda *_: powermenu.toggle_powermenu(),
    )
    add_cursor_hover(button)
    return button
