const wallpaperChange = () => Widget.Button({
    on_clicked: () => {
        Utils.execAsync("/home/mallarb/.config/hypr/hyprpaper/scripts/rand_wallpaper.sh")
        .catch(err => console.log(err))
        App.closeWindow("quicktools-menu")},
    child: Widget.Icon("folder-pictures-symbolic")
})

const idleInhibitor = () => {
    
    if(Utils.exec("pacman -Q hypridle").slice(0, 8) !== "hypridle") //check if hypridle is installed
        return null;
    return Widget.Button({
        attribute: {
            enabled: false,
        },
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
        },
        child: Widget.Icon({
            icon: "media-optical-bd-symbolic",
        })
    })
}

export const QuickToolsMenuButtons = () => Widget.Box({
    children: [
        wallpaperChange(),
        idleInhibitor(),
    ]
})