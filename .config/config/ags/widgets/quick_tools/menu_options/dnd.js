const notifications = await Service.import("notifications");

export const Dnd = () =>
  Widget.Button({
    class_name: "quick-tools-menu-button",
    child: Widget.Icon({
      class_name: "quick-tools-menu-icon",
    }).hook(notifications, (self) => {
      self.icon = notifications.dnd
        ? "user-offline-symbolic"
        : "user-available-symbolic";
    }),
    on_clicked: (self) => {
      notifications.dnd = !notifications.dnd;
      self.toggleClassName("quick-tools-activated", notifications.dnd);
    },
  }).hook(notifications, (self) => {
    self.tooltip_text = notifications.dnd ? "Disable DND" : "Enable DND";
  });
