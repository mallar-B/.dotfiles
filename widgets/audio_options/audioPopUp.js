//for later work, not necessary module

const volumeSlider = Widget.Slider({
    min: 0,
    max:100,
    hexpand: true,
    draw_value: false 
})




const child = Widget.Box({
    css: 'min-width: 180px',
    visible: true,
    children: [
        volumeSlider,
]
})

const toReveal = Widget.Window({
    name: `test`,
    anchor: ["top", "right"],
    visible: false,
    child: child
})


export default toReveal;

