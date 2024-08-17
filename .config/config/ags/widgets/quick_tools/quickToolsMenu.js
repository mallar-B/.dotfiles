import { BluetoothIndicator } from "./menu_options/bluetooth.js";
import { IdleInhibitor } from "./menu_options/idleInhibitor.js";
import { NetworkIndicator } from "./menu_options/network.js";
import { WallpaperChange } from "./menu_options/wallpaperChange.js";
import { Dnd } from "./menu_options/dnd.js";

export const QuickToolsMenuOptions = Widget.Revealer({
  reveal_child: false,
  transition: "slide_down",
  transition_duration: 400,
  child: Widget.Box({
    // vertical: true,
    class_name: "quick-tools-menu",
    children: [
      WallpaperChange(),
      IdleInhibitor(),
      Dnd(),
      NetworkIndicator(),
      BluetoothIndicator(),
    ],
  }),
});
export const QuickToolsMenu = () =>
  Widget.Window({
    name: "quicktools-menu",
    css: "border-radius:5px; background-color:transparent",
    keymode: "exclusive",
    visible: false,
    anchor: ["top", "right"],
    child: Widget.Box({
      css: "padding: 1px 0px; margin: 4px 5px 0 0;",
      children: [QuickToolsMenuOptions],
    }),
  }).keybind("Escape", () => {
    QuickToolsMenuOptions.reveal_child = false;
    Utils.timeout(400, () => {
      App.toggleWindow("quicktools-menu");
    });
  });
