from typing import cast

from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.image import Image
from fabric.widgets.button import Button
from fabric.widgets.wayland import WaylandWindow
from fabric.notifications import Notifications, Notification
from fabric.utils import invoke_repeater, get_relative_path

from gi.repository import GdkPixbuf
from lxml import html


NOTIFICATION_WIDTH = 360
NOTIFICATION_IMAGE_SIZE = 64
NOTIFICATION_TIMEOUT = 10 * 1000  # 10 seconds


class NotificationWidget(Box):
    def __init__(self, notification: Notification, **kwargs):
        self._notification = notification

        super().__init__(
            size=(NOTIFICATION_WIDTH, -1),
            name="notification",
            spacing=8,
            orientation="v",
            **kwargs,
        )

        if self._notification.urgency == 2:
            self.set_style(
                """
                padding: 10px;
                border: solid 2px var(--ws-urgent);
                border-radius: 10px;
                background-color: var(--window-bg);
                """
            )

        # Build the notification content
        self._build_notification_content()

    def strip_html(self, text):
        if not text:
            return ""

        try:
            tree = html.fromstring(text)
            return tree.text_content().strip()
        except Exception as e:
            print(f"[strip_html error] {e} on input: {text!r}")
            return text

    def _build_notification_content(self):
        body_container = Box(spacing=4, orientation="h")

        # Add image if available
        if image_pixbuf := self._notification.image_pixbuf:
            body_container.add(
                Image(
                    pixbuf=image_pixbuf.scale_simple(
                        NOTIFICATION_IMAGE_SIZE,
                        NOTIFICATION_IMAGE_SIZE,
                        GdkPixbuf.InterpType.BILINEAR,
                    )
                )
            )

        # Add text content
        body_container.add(
            Box(
                spacing=4,
                orientation="v",
                children=[
                    # Header box with summary and close button
                    Box(
                        orientation="h",
                        children=[
                            Label(
                                label=self.strip_html(self._notification.summary)
                                or "(no summary)",
                                ellipsization="middle",
                            )
                            .build()
                            .add_style_class("summary")
                            .unwrap(),
                        ],
                        h_expand=True,
                        v_expand=True,
                    ).build(
                        lambda box, _: box.pack_end(
                            Button(
                                name="close-button",
                                image=Image(
                                    icon_name="window-close-symbolic",
                                    icon_size=18,
                                ),
                                v_align="center",
                                h_align="end",
                                on_clicked=lambda *_: self._notification.close(),
                            ),
                            False,
                            False,
                            0,
                        )
                    ),
                    # Body text
                    Label(
                        label=self.strip_html(self._notification.body) or "",
                        line_wrap="word-char",
                        v_align="start",
                        h_align="start",
                    )
                    .build()
                    .add_style_class("body")
                    .unwrap(),
                ],
                h_expand=True,
                v_expand=True,
            )
        )

        self.add(body_container)

        # Add action buttons if available
        if actions := self._notification.actions:
            self.add(
                Box(
                    spacing=4,
                    orientation="h",
                    children=[
                        Button(
                            style_classes="action-button",
                            h_expand=True,
                            v_expand=True,
                            label=action.label,
                            on_clicked=lambda *_, action=action: action.invoke(),
                        )
                        for action in actions
                    ],
                )
            )

        # Set up notification lifecycle
        self._setup_notification_lifecycle()

    def _setup_notification_lifecycle(self):
        # Destroy this widget once the notification is closed
        self._notification.connect(
            "closed",
            lambda *_: (
                parent.remove(self) if (parent := self.get_parent()) else None,
                self.destroy(),
            ),
        )

        # Automatically close the notification after the timeout period
        invoke_repeater(
            NOTIFICATION_TIMEOUT,
            lambda: self._notification.close("expired"),
            initial_call=False,
        )


if __name__ == "__main__":
    app = Application(
        "notifications",
        WaylandWindow(
            title="notification",
            anchor="top right",
            style="background-color:transparent",
            child=Box(
                size=2,  # so it's not ignored by the compositor
                spacing=4,
                orientation="v",
                style="margin:10px",
            ).build(
                lambda viewport, _: Notifications(
                    on_notification_added=lambda notifs_service, nid: viewport.add(
                        NotificationWidget(
                            cast(
                                Notification,
                                notifs_service.get_notification_from_id(nid),
                            )
                        )
                    )
                )
            ),
            visible=True,
            all_visible=True,
        ),
    )

    app.set_stylesheet_from_file(get_relative_path("./style.css"))

    app.run()
