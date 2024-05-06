const audio = await Service.import("audio")

const icons = {
    101: "overamplified",
    67: "high",
    34: "medium",
    1: "low",
    0: "muted",
}
function getIcon() {
    const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
        threshold => threshold <= audio.speaker.volume * 100)

    return `audio-volume-${icons[icon]}-symbolic`
}

const volumeIcon = Widget.Icon({
    class_name: "volume-icon",
    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
})

const volumeLabel = Widget.Box({
    class_name: "volume-label-box",
    hpack: "center",
    child:Widget.Label().hook(audio.speaker, self =>{
        self.label = " " + Math.round(audio.speaker.volume * 100).toString();
    })
})

const volumeSlider = Widget.Box({
    child:Widget.Slider({
        class_name:"volume-slider",
        hexpand: true,
        draw_value: false,
        width_request: 250,
        on_change: ({ value }) => audio.speaker.volume = value,
        setup: self => self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0
        }),
    })
})

export const toReveal = Widget.Revealer({    
    reveal_child: true,
    transition: "slide_up",
    transition_duration: 400,
    child: Widget.Box({
        class_name: "volume-indicator-box",
        children: [
            volumeIcon,
            volumeSlider,
            volumeLabel,
            
        ]
    }),
})

export const VolumeIndicator = () => Widget.Window({
    css: "background-color: transparent;",
    name: "volume-indicator",
    anchor: ["bottom",],
    child: Widget.Box({
        css: "padding: 1px;",
        children: [
            toReveal,
        ]
})
})