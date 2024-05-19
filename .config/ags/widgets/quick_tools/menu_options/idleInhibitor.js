import { QuickToolsMenuOptions } from "../quickToolsMenu.js";

const isRunning = () => {
  return Utils.exec(`pidof hypridle`) ? "running" : null;
};

export const IdleInhibitor = () => {
  //check if hypridle is installed
  if (Utils.exec("pacman -Q hypridle").slice(0, 8) !== "hypridle") return null;
  return Widget.Button({
    vexpand: true,
    class_name: "quick-tools-menu-button",
    tooltip_text: "Enable idle-inhibitor",
    //
    // setup: (self) => {
    //   self.toggleClassName("quick-tools-activated", !isRunning());
    // },
    on_clicked: (self) => {
      if (isRunning())
        // check if hypridle is running
        Utils.execAsync(`pkill hypridle`).catch((err) => console.log(err));
      else Utils.execAsync(`hypridle &`).catch((err) => console.log(err));
      self.tooltip_text = !isRunning()
        ? "Disable idle-inhibitor"
        : "Enable idle-inhibitor";
      self.toggleClassName("quick-tools-activated", !isRunning());
      // close quicktools revealer
      QuickToolsMenuOptions.reveal_child = false;
      Utils.timeout(400, () => {
        App.toggleWindow("quicktools-menu");
      });
    },
    child: Widget.Icon({
      icon: "media-optical-bd-symbolic",
      class_name: "quick-tools-menu-icon",
    }),
  });
};
