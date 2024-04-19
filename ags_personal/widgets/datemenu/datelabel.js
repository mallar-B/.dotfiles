import GLib from "gi://GLib"

const timeCounter = Variable('',{
    poll: [1000, function(){
        return GLib.DateTime.new_now_local().format(" %T"); //https://docs.gtk.org/glib/struct.DateTime.html
    }]
})

const date = Variable( '',{
    poll: [1000, function(){
        return GLib.DateTime.new_now_local().format("%d/%m");
    }]
})

const DateLabel = () => Widget.Box({
    vpack: 'center',
    className: 'spacing-h-4 bar-clock-box',
    children: [
        Widget.Label({
            className: 'bar-date',
            label: date.bind()
        }),
        Widget.Label({
            className: 'bar-date',
            label:  timeCounter.bind()
        }),
    ],
});

export default DateLabel;