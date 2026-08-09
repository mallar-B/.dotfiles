//@ pragma IconTheme Everforest-Dark
import QtQuick
import Quickshell
import "components"
import "services"

ShellRoot {
    id: shellRoot

    Theme {
        id: everforestTheme
    }

    LauncherController {
        id: appLauncherController
    }

    NotificationService {
        id: notificationService
    }

    AudioService {
        id: audioService
    }

    NiriWorkspaceService {
        id: niriWorkspaceService
    }

    Variants {
        model: Quickshell.screens

        Bar {
            property var modelData

            screen: modelData
            theme: everforestTheme
            launcherController: appLauncherController
            notifications: notificationService
            niriWorkspaces: niriWorkspaceService
        }
    }

    AppLauncher {
        theme: everforestTheme
        controller: appLauncherController
    }

    NotificationToast {
        theme: everforestTheme
        notifications: notificationService
    }

    AudioOsd {
        theme: everforestTheme
        audio: audioService
    }
    OverviewWorkspaceBlur {}
}
