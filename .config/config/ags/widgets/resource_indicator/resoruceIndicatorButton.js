const hyprland = await Service.import("hyprland");

const cpuInfo = Widget.Label().poll(
  3000,
  (label) =>
    (label.label =
      "CPU " +
      Utils.exec(`bash -c /home/$(whoami)/.local/bin/print_cpu.sh`) +
      "%  "),
);

const memInfo = Widget.Label().poll(
  3000,
  (label) =>
    (label.label =
      "MEM " +
      Utils.exec(`bash -c /home/$(whoami)/.local/bin/print_mem.sh`) +
      "%"),
);

export const ResourceIndicatorButton = () =>
  Widget.EventBox({
    css: "margin: 2px",
    child: Widget.Box({
      css: "padding: 1px",
      children: [cpuInfo, memInfo],
    }),
    onPrimaryClick: () =>
      hyprland.message(`dispatch exec [ float; size 70% ] foot btop`),
  });
