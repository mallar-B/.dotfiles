export const calendar = Widget.Revealer({
  reveal_child: false,
  transition: "slide_down",
  transition_duration: 300,
  child: Widget.Calendar({
    class_name: "calendar",
    showDayNames: true,
    showDetails: false,
    showHeading: true,
    showWeekNumbers: true,
    detail: (self, y, m, d) => {
      return `<span color="white">${y}. ${m}. ${d}.</span>`;
    },
    onDaySelected: ({ date: [y, m, d] }) => {
      print(`${y}. ${m}. ${d}.`);
    },
    // vpack: "fill",
    vexpand: true,
    hexpand: true,
  }),
});

export const Calendar = () =>
  Widget.Window({
    css: "border-radius: 5px;",
    name: "calendar",
    class_name: "calendar-window",
    anchor: ["top"],
    keymode: "none",
    visible: false,
    child: Widget.Box({
      // vertical: true,
      css: "padding: 1px;min-width:310px",
      children: [calendar],
    }),
  });
