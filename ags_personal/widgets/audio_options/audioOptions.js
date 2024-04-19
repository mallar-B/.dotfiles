import Mic from "./mic.js";
import  Speaker  from "./speaker.js";


export function AudioOptions(){
    return Widget.Box({
        children: [
            Speaker,
            Mic,
        ]
        })
}