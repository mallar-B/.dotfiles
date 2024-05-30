const user = Utils.exec("whoami")

const getIcon = (iconName) => {
  const action = {
    "system-shutdown-symbolic": "poweroff",
    "system-reboot-symbolic": "reboot",
    "system-log-out-symbolic": "pkill -u user",
    "system-lock-screen-symbolic": "hyprlock",
    "weather-clear-night-symbolic": "systemctl suspend",
  };

  return Widget.Button({
    class_name: "power-menu-button",
    onPrimaryClick: () => {
      if (action[iconName] === "systemctl suspend") {
        App.closeWindow("powermenu");
        Utils.exec(`grim /home/${user}/.config/hypr/hyprlock/curr_wall.png`); 
        Utils.execAsync("hyprlock").catch((err) => console.log(err));
      }
      Utils.execAsync(`${action[iconName]}`).catch((err) => console.log(err));
    },
    child: Widget.Icon({
      class_name: "power-menu-icon",
      icon: `${iconName}`,
    }),
  });
};

export const PowerMenu = () =>
  Widget.Window({
    name: "powermenu",
    class_name: "power-menu-window",
    anchor: ["", "right", "top", ""],
    visible: false,
    layer: "top",
    keymode: "exclusive",
    child: Widget.Box({
      vertical: true,
      hpack: "end",
      children: [
        getIcon("system-shutdown-symbolic"),
        getIcon("system-reboot-symbolic"),
        getIcon("system-log-out-symbolic"),
        getIcon("system-lock-screen-symbolic"),
        getIcon("weather-clear-night-symbolic"),
      ],
    }),
  }).keybind("Escape", () => App.closeWindow("powermenu"));
