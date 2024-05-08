const getIcon = (iconName) =>{

    const action = {
        "system-shutdown-symbolic": "poweroff",
        "system-reboot-symbolic": "reboot",
        "system-log-out-symbolic": "pkill -u user",
        "system-lock-screen-symbolic": "hyprlock",
        "weather-clear-night-symbolic": "systemctl suspend",
    }


    return Widget.Button({
        class_name: "power-menu-button",
        onPrimaryClick: () =>{
        if(action[iconName] === "systemctl suspend") {
            Utils.execAsync("hyprlock")
        }
            App.closeWindow("powermenu");
            Utils.execAsync(`${action[iconName]}`).catch(err => console.log(err));},
        child: Widget.Icon({
            class_name: "power-menu-icon",
            icon: `${iconName}`,
            
        })
    })
}



export const PowerMenu = () => Widget.Window({
    name: "powermenu",
    class_name: "power-menu-window",
    anchor: ["left", "right","top","bottom"],
    visible: false,
    layer: "top",
    keymode: "exclusive",
    child: Widget.Box({
        vertical:true,
        children: [
            Widget.Box({expand: true}), // vertical expander
            Widget.Box({
                children: [ 
                    Widget.Box({expand: true}), // horizontal expander
                    getIcon('system-shutdown-symbolic'),
                    getIcon('system-reboot-symbolic'),
                    getIcon('system-log-out-symbolic'),
                    getIcon('system-lock-screen-symbolic'),
                    getIcon('weather-clear-night-symbolic'),
                    Widget.Box({expand: true}), // horizontal expander
                ],
            }),
            Widget.Box({expand: true})], // vertical expander
        })

    }).keybind("Escape", () => App.closeWindow("powermenu"))

