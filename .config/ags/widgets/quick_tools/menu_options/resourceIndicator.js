import { QuickToolsMenuOptions } from "../quickToolsMenu.js"

const hyprland = await Service.import("hyprland")

export const ResourceIndicator = () => Widget.Button({
        vexpand: true,
        class_name: "quick-tools-menu-button",
        on_clicked: () => {
            
            let app = "btop"
            let terminal = "foot"

            if(Utils.exec("pacman -Q btop").slice(0, 4) !== "btop") { app = "htop" } //check if btop is installed 
            if(Utils.exec("pacman -Q foot").slice(0, 4) !== "foot") { terminal = "kitty" } //check if foot is installed
            hyprland.messageAsync(`dispatch exec [ float; size 50% ] ${terminal} ${app}`)
            QuickToolsMenuOptions.reveal_child = false},
        child: Widget.Icon({
            class_name: "quick-tools-menu-icon",
            icon: "system-run-symbolic",
        }), 
        tooltip_text: "Resource Usage",
    })