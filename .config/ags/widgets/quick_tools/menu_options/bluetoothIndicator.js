const hyprland = await Service.import("hyprland");
export const BluetoothIndicator = () => {
  if (Utils.exec("pacman -Q bluez").slice(0, 5) !== "bluez") return; //check if bluez is installed

  return Widget.Button({
    vexpand: true,
    class_name: "quick-tools-menu-button",
    on_clicked: () => {
      // hyprland.messageAsync(`dispatch exec [ float; size 50% ] kitty btui`)
      Utils.execAsync(`dmesg | grep bluetooth`)
        .then((dmesg) => {
          console.log(dmesg);
        })
        .catch((err) => console.log(err));
      QuickToolsMenuOptions.reveal_child = false;
    },
    child: Widget.Icon({
      class_name: "quick-tools-menu-icon",
      icon: "bluetooth-active-symbolic",
    }),
    tooltip_text: "Bluetooth",
  });
};
