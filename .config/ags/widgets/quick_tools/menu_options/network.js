import { QuickToolsMenuOptions } from "../quickToolsMenu.js"

const hyprland = await Service.import("hyprland")

export const NetworkIndicator = () => Widget.Button({
        vexpand: true,
        class_name: "quick-tools-menu-button",
        on_clicked: () => {
            hyprland.messageAsync(`dispatch exec [ float; size 50% ] kitty nmtui`)
            QuickToolsMenuOptions.reveal_child = false
            Utils.timeout(400, () => {
                App.toggleWindow("quicktools-menu")
            })},
        child: Widget.Icon({
            class_name: "quick-tools-menu-icon",
            icon: "network-wired-symbolic",
        }), 
        tooltip_text: "Network",
    })