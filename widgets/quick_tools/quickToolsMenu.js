import { QuickToolsMenuButtons } from "./quickToolsMenuButtons.js"
export const QuickToolsMenu = () => Widget.Window({
    name: "quicktools-menu",
    class_name: "quick-tools-menu",
    visible: true,
    anchor: ["top","right"],
    widthRequest: 50,
    child: QuickToolsMenuButtons(),
})