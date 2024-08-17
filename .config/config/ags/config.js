import { ClientTitle } from "./widgets/client_title/clientTitle.js";
import { Workspaces } from "./widgets/workspaces/workspaces.js";
import { NotificationPopups } from "./widgets/notifications/notificationPopups.js";
import { Date } from "./widgets/date/date.js";
import { Media } from "./widgets/media/media.js";
import { SysTray } from "./widgets/systray/sysTray.js";
import { AudioOptions } from "./widgets/audio_options/audioOptions.js";
import { PowerButton } from "./widgets/powerbutton/powerbutton.js";
import { PowerMenu } from "./widgets/powerbutton/powermenu.js";
import { AppLauncher } from "./widgets/applauncher/applauncher.js";
import { QuickToolsMenu } from "./widgets/quick_tools/quickToolsMenu.js";
import { QuickTools } from "./widgets/quick_tools/quickToolsButton.js";
import { VolumeIndicator } from "./widgets/volume_indicator/volumeIndicator.js";
import { ResourceIndicatorButton } from "./widgets/resource_indicator/resoruceIndicatorButton.js";
import { Updates } from "./widgets/updates/Updates.js";

// import {TestWindow} from "./debug/testWindow.js"
// import { TestButton, TestButton2 } from "./debug/testButton.js"

export const user = Utils.exec("whoami");

// layout of the bar
function Left() {
  return Widget.Box({
    spacing: 8,
    children: [Workspaces(), Updates(), ClientTitle()],
  });
}
function Center() {
  return Widget.Box({
    spacing: 8,
    children: [
      Date(),
      //
      // TestButton(),
      // TestButton2(),
    ],
  });
}

function Right() {
  return Widget.Box({
    hpack: "end",
    spacing: 8,
    children: [
      Media(),
      ResourceIndicatorButton(),
      AudioOptions(),
      QuickTools(),
      SysTray(),
      PowerButton(),
    ],
  });
}

function Bar(monitor = 0) {
  return Widget.Window({
    name: `bar-${monitor}`, // name has to be unique
    class_name: "bar",
    monitor,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      start_widget: Left(),
      center_widget: Center(),
      end_widget: Right(),
    }),
  });
}

App.config({
  style: "./style.css",
  windows: [
    Bar(),
    NotificationPopups(),
    PowerMenu(),
    AppLauncher(),
    QuickToolsMenu(),
    VolumeIndicator(),

    // TestWindow(),
  ],
});

// auto reloading css
Utils.monitorFile(`/home/${user}/.config/ags/style.css`, () => {
  App.applyCss(`/home/${user}/.config/ags/style.css`);
});

export {};
