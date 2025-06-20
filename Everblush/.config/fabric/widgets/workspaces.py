from fabric.hyprland.widgets import (
    Workspaces as HyprlandWorkSpaces,
    WorkspaceButton as HyprlandWorkspaceButton,
)
from utils import add_cursor_hover

class WorkspaceButton(HyprlandWorkspaceButton):
    def __init__(self, **kwargs):
        super().__init__(name="workspace-button", **kwargs)
        add_cursor_hover(self, "pointer")

class Workspaces(HyprlandWorkSpaces):
    def __init__(self, **kwargs):
        super().__init__(
            name="workspaces-container",
            buttons=None,
            buttons_factory=lambda workspace_id: WorkspaceButton(
                id=workspace_id, label=str(workspace_id)
            ),
            **kwargs
        )
