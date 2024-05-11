const date = Variable("", {
    poll: [1000, 'date "+%T"'],
})

export function Date() {
    return Widget.Label({
        class_name: "clock",
        label: date.bind(),
    })
}
