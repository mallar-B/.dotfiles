const hyprland = await Service.import('hyprland')

const dispatch = ws => hyprland.messageAsync(`dispatch workspace ${ws}`);

export const Workspaces = () => Widget.EventBox({
    
    onScrollUp: () => dispatch('+1'),
    onScrollDown: () => dispatch('-1'),

    child: Widget.Box({
        class_name: "workspaces",
        children: Array.from({ length: 10 }, (_, i) => i + 1).map(i => Widget.Button({
            class_name: hyprland.active.workspace.bind("id").as(id => `${i === id ? "focused" : ""}`),
            attribute: i,
            label: `${i}`,
            onClicked: () => dispatch(i),
        })),

        setup: self => self.hook(hyprland, () => self.children.forEach(btn => {
            btn.visible = hyprland.workspaces.some(ws => ws.id === btn.attribute);
        })),
    }),
})