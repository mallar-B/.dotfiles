// const application = await Service.import("applications")


// const AppItem = app => Widget.Button({
//     on_clicked: () => {
//         App.closeWindow(WINDOW_NAME)
//         app.launch()
//     },
//     attribute: { app },
//     child: Widget.Box({
//         children: [
//             // Widget.Icon({
//             //     icon: app.icon_name || "",
//             //     size: 42,
//             // }),
//             Widget.Label({
//                 class_name: "title",
//                 label: app.name,
//                 xalign: 0,
//                 vpack: "center",
//                 truncate: "end",
//             }),
//         ],
//     }),
// })

// export const AppLauncher = () =>Widget.Window({
//     name: "applauncher",
//     anchor: ["top", "right"],
//     visible: true,
//     child: Widget.Box({
//         css:"min-height:100px; min-width:100px; background-color:red",
//         vertical: true,
//             children: [
//             Widget.Entry({
//                 placeholder_text: 'type here',
//                 // text:`${appName}`,
//                 visibility: true, // set to false for passwords
//                 onAccept: ({ text }) => console.log(text)
//             }),

//             // wrap the list in a scrollable
//             Widget.Scrollable({
//                 hscroll: "never",
//                 css: `min-width: 500px;`
//                     + `min-height: 500px;`,
//                 child:  Widget.Box({css: "min-height:100px; min-width:100px; background-color:blue"}),
//             }),
//         ],
//     })
// })