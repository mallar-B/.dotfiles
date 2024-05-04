import { QuickToolsMenuOptions } from "../quickToolsMenu.js"

export const IdleInhibitor = () => {
    
    if(Utils.exec("pacman -Q hypridle").slice(0, 8) !== "hypridle") //check if hypridle is installed
        return null;
    return Widget.Button({
        attribute: {
            enabled: false,
        },
        vexpand: true,
        class_name: "quick-tools-menu-button",
        setup: self => {
            self.attribute.enabled = !(!!Utils.exec('pidof hypridle'));
            self.toggleClassName('idle-inhibitor-on', self.attribute.enabled);
            self.tooltip_text = self.attribute.enabled ? "Disable Idle Inhibitor" : "Enable Idle Inhibitor";
        },
        on_clicked: (self) => {
            self.attribute.enabled = !self.attribute.enabled
            self.toggleClassName('idle-inhibitor-on', self.attribute.enabled);
            if(self.attribute.enabled) Utils.execAsync(`pkill hypridle`).catch(err => console.log(err))
            else(Utils.execAsync(`hypridle &`).catch(err => console.log(err)))
            QuickToolsMenuOptions.reveal_child = false
        },
        child: Widget.Icon({
            icon: "media-optical-bd-symbolic",
            class_name: "quick-tools-menu-icon",
        })
    })
}
