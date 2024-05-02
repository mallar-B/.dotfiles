//debugging for now

const QuickToolsIcon = Widget.Icon('emblem-system-symbolic')

export const QuickTools = () => Widget.Button({
    child: QuickToolsIcon,
    on_clicked: () => {
        Utils.notify('summary', 'bodydddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd', 'icon-name')
    },
})