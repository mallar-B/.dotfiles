import {Notification} from "./notification.js"

const notifications = await Service.import("notifications")
const { timeout, idle } = Utils

function Animated(id) {
    const n = notifications.getNotification(id)
    const widget = Notification(n)

    const inner = Widget.Revealer({
        transition: "slide_left",
        transition_duration: 300,
        child: widget,
    })

    const outer = Widget.Revealer({
        transition: "slide_down",
        transition_duration: 300,
        child: inner,
    })

    const box = Widget.Box({
        hpack: "end",
        child: outer,
    })

    idle(() => {
        outer.reveal_child = true
        timeout(100, () => {
            inner.reveal_child = true
        })
    })

    return Object.assign(box, {
        dismiss() {
            inner.reveal_child = false
            timeout(100, () => {
                outer.reveal_child = false
                timeout(100, () => {
                    box.destroy()
                })
            })
        },
    })
}

function PopupList() {
    const map = new Map
    const box = Widget.Box({
        hpack: "end",
        vertical: true,
        // css:`min-width: 1px;`,
    })

    function remove(_, id) {
        map.get(id)?.dismiss()
        map.delete(id)
    }

    return box
        .hook(notifications, (_, id) => {
            if (id !== undefined) {
                if (map.has(id))
                    remove(null, id)

                if (notifications.dnd)
                    return

                const w = Animated(id)
                map.set(id, w)
                box.children = [w, ...box.children]
            }
        }, "notified")
        .hook(notifications, remove, "dismissed")
        .hook(notifications, remove, "closed")
}

export const NotificationPopups = (monitor=0) => Widget.Window({
    monitor,
    name: `notifications${monitor}`,
    anchor: ["top", "right"],
    class_name: "notifications",
    child: Widget.Box({
        css: "padding: 2px;",
        child: PopupList(),
    }),
})
