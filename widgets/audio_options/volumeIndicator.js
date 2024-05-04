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

const icon = Widget.Icon({
    class_name: "audio-icon",
    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
})

const volumeLabel = Widget.Label().hook(audio.speaker, self =>{
    self.label = " " + Math.round(audio.speaker.volume * 100).toString() + "%";
})

const levelbar = Widget.Box({
    vexpand: false,
    child:Widget.LevelBar({
        vertical: false,
        class_name: "volume-indicator",
        widthRequest: 300,
    }).hook(audio.speaker, self => {
        self.value = audio.speaker.volume
        self.child.label = `${Math.round(audio.speaker.volume * 100)}%`})
})

export const VolumeIndicator = () => Widget.Window({
    css: "baground-color: red;",
    name: "volume-indicator",
    anchor: ["bottom",],
    child: Widget.Box({
        css:"margin-bottom: 90px ;min-width: 300px; background-color: red;",
        children: [
            icon,
            volumeLabel,
            levelbar
        ]
    }),
})