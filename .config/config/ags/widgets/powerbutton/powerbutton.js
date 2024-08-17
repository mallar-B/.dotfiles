import { powerMenuOptions } from "./powermenu.js";
const hyprland = await Service.import("hyprland");


export const PowerButton = () =>
  Widget.Button({
    class_name: "power-button",
    on_clicked: () =>{
        if(powerMenuOptions.reveal_child){
            powerMenuOptions.reveal_child = false
            Utils.timeout(400, () => {
                App.toggleWindow("powermenu")
            })
        } else{
            App.toggleWindow("powermenu")
            powerMenuOptions.reveal_child = true
        }
            
    },
    child: Widget.Icon({
      class_name: "power-button-icon",
      icon: "system-shutdown-symbolic",
    }),
    tooltip_text: "Power Menu",
  });
