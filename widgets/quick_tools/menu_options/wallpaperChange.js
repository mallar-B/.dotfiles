export const WallpaperChange = () => Widget.Button({
    class_name: "quick-tools-menu-button",
    vexpand: true,
    on_clicked: () => {
        Utils.execAsync("/home/mallarb/.config/hypr/hyprpaper/scripts/rand_wallpaper.sh")
        .catch(err => console.log(err))},
    child: Widget.Icon({
        class_name: "quick-tools-menu-icon",
        icon: "folder-pictures-symbolic",
    }), 
    tooltip_text: "Change Wallpaper/ Select Wallpaper",
})