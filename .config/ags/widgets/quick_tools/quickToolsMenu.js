import { BluetoothIndicator } from "./menu_options/bluetooth.js"
import { IdleInhibitor } from "./menu_options/idleInhibitor.js"
import { NetworkIndicator } from "./menu_options/network.js"
import { ResourceIndicator } from "./menu_options/resource.js"
import { WallpaperChange } from "./menu_options/wallpaperChange.js" 

export const QuickToolsMenuOptions = Widget.Revealer({
    reveal_child: false,
    transition: "slide_down",
    transition_duration: 400,
    child:Widget.Box({
        // vertical: true,
        class_name: "quick-tools-menu",
        children: [
            WallpaperChange(),
            IdleInhibitor(),
            ResourceIndicator(),
            NetworkIndicator(),
            BluetoothIndicator(),
        ]
    })
})
export const QuickToolsMenu = () => Widget.Window({
    name: "quicktools-menu",
    css: "border-radius:5px;",
    keymode: "exclusive",
    visible: false,
    anchor: ["top","right"],
    child: Widget.Box({
        css: "padding: 1px 0px;",
        children: [
            QuickToolsMenuOptions,
        ]
    }),
}).keybind("Escape", () => {
    QuickToolsMenuOptions.reveal_child = false
    Utils.timeout(400, () => {
        App.toggleWindow("quicktools-menu")
    })
})