import DateMenu from "./widgets/datemenu/datemenu.js";
import DateLabel from "./widgets/datemenu/datelabel.js";

const time = Variable('', {
    poll: [1000, function() {
        return Date().toString()
    }],
})


const dateLabel = DateLabel();
const test = DateMenu();

const Bar = (/** @type {number} */ monitor) => Widget.Window({
    monitor,
    name: `bar${monitor}`,
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    child: Widget.CenterBox({
        start_widget: Widget.Label({
            hpack: 'center',
            label: 'Welcome to AGS!',
        }),
        center_widget: test,
        end_widget: Widget.Label({
            hpack: 'center',
            label: time.bind(),
        }),
    }),
})

App.config({
    windows: () => [
        Bar(),
    ]
})
