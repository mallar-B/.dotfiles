const hyprland = await Service.import("hyprland")

export const ClientTitle = () => Widget.Label({
        class_name: "client-title",
        label: hyprland.active.client.bind("title"),
        truncate: "end",
        maxWidthChars: 32,
        wrap: true,
    })
