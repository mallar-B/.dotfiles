import { user } from "../../../config.js"

export const WallpaperChange = () => Widget.Button({
    class_name: "quick-tools-menu-button",
    vexpand: true,
    on_clicked: () => {
        Utils.execAsync(`bash -c /home/${user}/.local/bin/wallpaper.sh`)
            .catch(err => console.log(err))
    },
    child: Widget.Icon({
        class_name: "quick-tools-menu-icon",
        icon: "folder-pictures-symbolic",
    }),
    tooltip_text: "Change Wallpaper | Select Wallpaper",
})
