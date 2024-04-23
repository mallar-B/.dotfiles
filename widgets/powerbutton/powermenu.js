const getIcon = (iconName) =>{

    const user = "mallarb"

    const action = {
        "system-shutdown-symbolic": "poweroff",
        "system-reboot-symbolic": "reboot",
        "system-log-out-symbolic": "pkill -u user",
        // "system-lock-screen-symbolic": "hyprlock",
        "weather-clear-night-symbolic": "systemctl suspend",
    }


    return Widget.Button({
        class_name: "power-menu-button",
        onPrimaryClick: () =>{
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
    // anchor: ["left", "right",],
    visible: false,
    layer: "top",
    widthRequest: 50,
    keymode: "on-demand",
    child: Widget.Box({
        class_name: "powermenu",
        css: "  padding: 10px",
        expand: true,
        children: [ 
                    getIcon('system-shutdown-symbolic'),
                    Widget.Box({expand: true}),
                    getIcon('system-reboot-symbolic'),
                    Widget.Box({expand: true}),
                    getIcon('system-log-out-symbolic'),
                    Widget.Box({expand: true}),
                    getIcon('system-lock-screen-symbolic'),
                    Widget.Box({expand: true}),
                    getIcon('weather-clear-night-symbolic'),
                ],
        }),
    }).keybind("Escape", () => App.closeWindow("powermenu"))

