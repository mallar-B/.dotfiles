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

    LockService {
        id: lockService
        theme: everforestTheme
        notifications: notificationService
    }

    AudioService {
        id: audioService
    }

    NiriWorkspaceService {
        id: niriWorkspaceService
    }

    IdleService {
        id: globalIdleService
        notifications: notificationService
        lockController: lockService
    }

    WirelessService {
        id: wirelessService
        notifications: notificationService
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
            lockController: lockService
            idleService: globalIdleService
            wireless: wirelessService
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
