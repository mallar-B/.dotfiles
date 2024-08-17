const user = Utils.exec("whoami");

const getIcon = (iconName) => {
  const action = {
    "system-shutdown-symbolic": "poweroff",
    "system-reboot-symbolic": "reboot",
    "system-log-out-symbolic": `pkill -u ${user}`,
    "system-lock-screen-symbolic": `/home/${user}/.local/bin/hyprlock.sh`,
    "weather-clear-night-symbolic": "systemctl suspend",
  };

  return Widget.Button({
    class_name: "power-menu-button",
    onPrimaryClick: () => {
      Utils.execAsync(`${action[iconName]}`)
        .then((out) => console.log(out))
        .catch((err) => console.log(err));
    },
    child: Widget.Icon({
      class_name: "power-menu-icon",
      icon: `${iconName}`,
    }),
  });
};

export const powerMenuOptions = Widget.Revealer({
  reveal_child: false,
  transition: "slide_right",
  transition_duration: 400,
  child: Widget.Box({
    //vertical: true,
    children: [
      getIcon("system-shutdown-symbolic"),
      getIcon("system-reboot-symbolic"),
      getIcon("system-log-out-symbolic"),
      getIcon("system-lock-screen-symbolic"),
      getIcon("weather-clear-night-symbolic"),
    ],
  }),
});

export const PowerMenu = () =>
  Widget.Window({
    name: "powermenu",
    class_name: "power-menu-window",
    css: "background-color: transparent",
    anchor: ["top", "right"],
    visible: false,
    layer: "top",
    keymode: "exclusive",
    child: Widget.Box({
      class_name: "power-menu-box",
      css: "padding: 1px 0px; margin: 4px 5px 0 0;",
      vertical: true,
      children: [powerMenuOptions],
    }),
  }).keybind("Escape", () => {
    powerMenuOptions.reveal_child = false;
    Utils.timeout(400, () => {
      App.toggleWindow("powermenu");
    });
  });
