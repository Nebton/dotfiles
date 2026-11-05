import Pango from "gi://Pango"

const notifications = await Service.import("notifications")

/** @param {import('resource:///com/github/Aylur/ags/service/notifications.js').Notification} n */
function NotificationIcon({ app_entry, app_icon, image }) {
    if (image) {
        return Widget.Box({
            css: `background-image: url("${image}");`
                + "background-size: contain;"
                + "background-repeat: no-repeat;"
                + "background-position: center;"
                + "color:white;",
        })
    }

    let icon = "dialog-information-symbolic"
    if (Utils.lookUpIcon(app_icon))
        icon = app_icon

    if (app_entry && Utils.lookUpIcon(app_entry))
        icon = app_entry

    return Widget.Box({
        child: Widget.Icon(icon),
    })
}

/** @param {import('resource:///com/github/Aylur/ags/service/notifications.js').Notification} n */
function Notification(n) {
    // Terminals often send the entire message as a title with no body.
    // Keep the heading compact and give those messages the body layout too.
    const messageInTitle = !n.body.trim() && (n.summary.length > 80 || n.summary.includes("\n"));
    const heading = messageInTitle ? (n.app_name || "Notification") : n.summary;
    const message = messageInTitle ? n.summary : n.body;
    const icon = Widget.Box({
        vpack: "start",
        class_name: "icon",
        child: NotificationIcon(n),
    })

    const title = Widget.Label({
        class_name: "title",
        xalign: 0,
        justification: "left",
        hexpand: true,
        width_chars: 40,
        max_width_chars: 40,
        truncate: "none",
        wrap: true,
        wrap_mode: Pango.WrapMode.WORD_CHAR,
        lines: -1,
        label: heading,
        use_markup: true,

    })

    const body = Widget.Label({
        class_name: "body",
        hexpand: true,
        use_markup: true,
        xalign: 0,
        justification: "left",
        label: message,
        width_chars: 40,
        max_width_chars: 40,
        truncate: "none",
        wrap: true,
        wrap_mode: Pango.WrapMode.WORD_CHAR,
        lines: -1,
    })

    const actions = Widget.Box({
        class_name: "actions",
        children: n.actions.map(({ id, label }) => Widget.Button({
            class_name: "action-button",
            on_clicked: () => {
                n.invoke(id)
                n.dismiss()
            },
            hexpand: true,
            child: Widget.Label(label),
        })),
    })

    return Widget.EventBox(
        {
            attribute: { id: n.id },
            on_primary_click: n.dismiss,
        },
        Widget.Box(
            {
                class_name: `notification ${n.urgency}`,
                vertical: true,
            },
            Widget.Box([
                icon,
                Widget.Box(
                    { vertical: true, hexpand: true, spacing: 6 },
                    title,
                    Widget.Scrollable({
                        visible: Boolean(message),
                        hscroll: "never",
                        vscroll: "automatic",
                        propagate_natural_height: true,
                        max_content_height: 360,
                        child: body,
                        setup: scroll => scroll.connect("size-allocate", () => {
                            // Layer-shell uses the minimum requested height.
                            // Request the wrapped text height, up to the scroll limit.
                            const [, natural] = body.get_preferred_height_for_width(
                                scroll.get_allocated_width());
                            const height = Math.min(360, natural);
                            if (scroll.min_content_height !== height)
                                scroll.min_content_height = height;
                        }),
                    }),
                ),
            ]),
            actions,
        ),
    )
}

export function NotificationPopups(monitor = 0) {
    const list = Widget.Box({
        vertical: true,
        children: notifications.popups.map(Notification),
    })

    function onDismissed(_, /** @type {number} */ id) {
        // A replacement may arrive with the same ID; remove every old widget.
        list.children.filter(child => child.attribute.id === id)
            .forEach(child => child.destroy());
    }

    function onNotified(_, /** @type {number} */ id) {
        const n = notifications.getNotification(id);
        onDismissed(null, id);
        if (n?.popup)
            list.children = [Notification(n), ...list.children];
    }

    list.hook(notifications, onNotified, "notified")
        .hook(notifications, onDismissed, "dismissed")

    return Widget.Window({
        monitor,
        name: `notifications${monitor}`,
        class_name: "notification-popups",
        anchor: ["top", "right"],
        child: Widget.Box({
            css: "min-width: 2px; min-height: 2px;",
            class_name: "notifications",
            vertical: true,
            child: list,

            /** this is a simple one liner that could be used instead of
                hooking into the 'notified' and 'dismissed' signals.
                but its not very optimized becuase it will recreate
                the whole list everytime a notification is added or dismissed */
            // children: notifications.bind('popups')
            //     .as(popups => popups.map(Notification))
        }),
    })
}
