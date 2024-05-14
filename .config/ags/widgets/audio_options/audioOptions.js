import Mic from "./mic.js";
import  Speaker  from "./speaker.js";

export function AudioOptions(){
    return Widget.Box({
        class_name: "audio-options",
        children: [
            Speaker,
            Mic,
        ]
        })
}
