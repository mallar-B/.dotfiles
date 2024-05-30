const hyprland = await Service.import("hyprland");

export const PowerButton = () =>
  Widget.Button({
    class_name: "power-button",
    on_clicked: () => {
      App.toggleWindow("powermenu");
    },
    child: Widget.Icon({
      class_name: "power-button-icon",
      icon: "system-shutdown-symbolic",
    }),
    tooltip_text: "Power Menu",
  });
