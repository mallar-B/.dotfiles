import { BluetoothIndicator } from "./menu_options/bluetoothIndicator.js"
import { IdleInhibitor } from "./menu_options/idleInhibitor.js"
import { NetworkIndicator } from "./menu_options/networkIndicator.js"
import { ResourceIndicator } from "./menu_options/resourceIndicator.js"
import { WallpaperChange } from "./menu_options/wallpaperChange.js" 

export const QuickToolsMenuOptions = Widget.Revealer({
    reveal_child: true,
    transition: "slide_down",
    transition_duration: 400,
    child:Widget.Box({
        // vertical: true,
        css: "min-height: 100px",
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
    class_name: "quick-tools-menu",
    anchor: ["top","right"],
    child: Widget.Box({
        css: "padding: 1px 1px 0px 1px;",
        children: [
            QuickToolsMenuOptions,
        ]
    }),
})