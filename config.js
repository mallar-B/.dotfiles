import { ClientTitle } from "./widgets/client_title/clientTitle.js"
import { Workspaces } from "./widgets/workspaces/workspaces.js"
import { NotificationPopups } from "./widgets/notifications/notificationPopups.js"
import { Date } from "./widgets/date/date.js"
import { Media } from "./widgets/media/media.js"
import { SysTray } from "./widgets/systray/sysTray.js"
import { AudioOptions } from "./widgets/audio_options/audioOptions.js"
import { PowerButton } from "./widgets/powerbutton/powerbutton.js"
import { PowerMenu } from "./widgets/powerbutton/powermenu.js"

// import { applauncher } from "./applauncher.js"
// import toReveal from "./widgets/audio_options/audioPopUp.js"


// layout of the bar
function Left() {
    return Widget.Box({
        spacing: 8,
        children: [
            Workspaces(),
            ClientTitle(),
        ],
    })
}
function Center() {
    return Widget.Box({
        spacing: 8,
        children: [
            Date(),
        ],
    })
}

function Right() {
    return Widget.Box({
        hpack: "end",
        spacing: 8,
        children: [
            Media(),
            SysTray(),
            AudioOptions(),
            PowerButton(),
        ],
    })
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Left(),
            center_widget: Center(),
            end_widget: Right(),
        }),
    })
}

App.config({
    style: "./style.css",
    windows: [
        Bar(),
        NotificationPopups(),
        PowerMenu(),
    ],
})

export { }
