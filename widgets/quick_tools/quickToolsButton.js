import { QuickToolsMenuOptions } from "./quickToolsMenu.js"
export const QuickTools = () => Widget.Button({
    class_name: "quick-tools-button",
    on_clicked: () => {QuickToolsMenuOptions.reveal_child = !QuickToolsMenuOptions.reveal_child},
    child: Widget.Icon({
        class_name: "quick-tools-icon",
        icon: "emblem-system-symbolic",
    }),
    tooltip_text:"Quick Tools",
})