import { QuickToolsMenuOptions } from "./quickToolsMenu.js"
export const QuickTools = () => Widget.Button({
    class_name: "quick-tools-button",
    on_clicked: () =>{
        console.log(QuickToolsMenuOptions.reveal_child)
        if(QuickToolsMenuOptions.reveal_child){
            QuickToolsMenuOptions.reveal_child = false
            Utils.timeout(400, () => {
                App.toggleWindow("quicktools-menu")
            })
        } else{
            App.toggleWindow("quicktools-menu")
            QuickToolsMenuOptions.reveal_child = true
        }
            
    },
    child: Widget.Icon({
        class_name: "quick-tools-icon",
        icon: "preferences-system-symbolic",
    }),
    tooltip_text:"Quick Tools",
})