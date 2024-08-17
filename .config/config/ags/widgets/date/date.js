const time = Widget.Label().poll(
  1000,
  (label) => (label.label = Utils.exec('date +"%H:%M"')),
);

const date = Widget.Label().poll(
  10000,
  (label) => (label.label = Utils.exec('date +"%d/%m"')),
);

const day = Widget.Label().poll(
  10000,
  (label) => (label.label = Utils.exec('date +"%a"')),
);

const rightSeperator = Widget.Label({
  css: "font-size:20px",
  label: "|",
});

const leftSeperator = Widget.Label({
  css: "font-size:20px",
  label: "|",
});

export function Date() {
  return Widget.EventBox({
    css: "",
    child: Widget.Box({
      children: [date, leftSeperator, time, rightSeperator, day],
    }),
  });
}
