from fabric.hyprland.widgets import ActiveWindow
from fabric.utils import FormattedString, truncate


class AppTitle(ActiveWindow):
    def __init__(self, **kwargs):
        super().__init__(
            name="app-title",
            formatter=FormattedString(
                "{'' if not win_title else truncate(win_title, 42)}", truncate=truncate
            ),
            **kwargs
        )
