import { calendar } from "../calendar/calendar.js";

const date = Variable("", {
  poll: [1000, 'date "+%T"'],
});

export function Date() {
  return Widget.Button({
    child: Widget.Label({
      class_name: "clock",
      label: date.bind(),
    }),
    onClicked: () => {
      if (calendar.reveal_child) {
        calendar.reveal_child = false;
        Utils.timeout(300, () => {
          App.toggleWindow("calendar");
        });
      } else {
        App.toggleWindow("calendar");
        calendar.reveal_child = true;
      }
    },
  });
}
