const audio = await Service.import("audio")
const hyprland = await Service.import("hyprland")

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

export const icon = Widget.Icon({
    class_name: "audio-icon",
    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
})

export const volumeLabel = Widget.Label().hook(audio.speaker, self =>{
    self.label = " " + Math.round(audio.speaker.volume * 100).toString() + "%";
})

const volumeIndicator = Widget.Box({
    class_name: "audiobox",
    children: [icon, volumeLabel,]
}).hook(audio.speaker, self =>{
    self.tooltip_text = audio.speaker.name;
})

const volumeUp = () =>{
    if (!audio.speaker) return;
    if (audio.speaker.volume <= 0.09) audio.speaker.volume += 0.01;
    else audio.speaker.volume += 0.03;
}

const Speaker = Widget.EventBox({
    child: volumeIndicator,
    onScrollUp: () =>{
        if (!audio.speaker) return;
        if (audio.speaker.volume <= 0.09) audio.speaker.volume += 0.01;
        else audio.speaker.volume += 0.03;
    },
    onScrollDown: () =>{
        if (!audio.speaker) return;
        if (audio.speaker.volume <= 0.09) audio.speaker.volume -= 0.01;
        else audio.speaker.volume -= 0.03;
    },
    onMiddleClick: () =>{ audio.speaker.is_muted = !audio.speaker.is_muted },
    onPrimaryClick: () => { hyprland.messageAsync(`dispatch exec [ float; size 50%; ] pavucontrol`) },
    onSecondaryClick: () => { Utils.execAsync(['pkill', 'pavucontrol']).catch(err => console.log(err)) }
})

export default Speaker;
