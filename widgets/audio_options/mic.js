const audio = await Service.import("audio")

//debug function
const mtest = () => { 
    print(`${audio.microphone.volume}`)
}

const icon = Widget.Icon().hook(audio.microphone, self =>{
    const icons = {
        on: "audio-input-microphone-symbolic",
        off: "microphone-disabled-symbolic",
    };
    self.icon = audio.microphone.is_muted ? `${icons.off}` : `${icons.on}`;
})

const micLabel = Widget.Label().hook(audio.microphone,self => {
    self.label = " " + Math.round(audio.microphone.volume * 100).toString() + "%"
})

const micIndicator = Widget.Box({
    css: 'margin-left: 2px',
    children: [icon, micLabel],
}).hook(audio.speaker, self =>{
    self.tooltip_text = audio.microphone.name;
})


const Mic = Widget.EventBox({
    class_name: "audiobox",
    child: micIndicator,
    onScrollUp: () =>{audio.microphone.volume += 0.03},
    onScrollDown: () => {audio.microphone.volume -= 0.03},
    onPrimaryClick: () => { Utils.execAsync('pavucontrol').catch(err => console.log(err)) },
    onSecondaryClick: () => { Utils.execAsync(['pkill', 'pavucontrol']).catch(err => console.log(err)) }
})
export default Mic