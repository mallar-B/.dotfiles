//debugging for now

export const QuickTools = () => Widget.Button({
    class_name: "quick-tools-button",
    on_clicked: () => App.toggleWindow("quicktools-menu"),
    child: Widget.Icon({
        class_name: "quick-tools-icon",
        icon: "emblem-system-symbolic",
    }),
    tooltip_text:"Quick Tools",
})