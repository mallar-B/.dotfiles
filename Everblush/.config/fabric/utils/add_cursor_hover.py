def add_cursor_hover(widget, cursor="pointer"):
    def enter(w, *_):
        w.set_cursor(cursor)

    def leave(w, *_):
        w.set_cursor("default")

    widget.connect("enter_notify_event", enter)
    widget.connect("leave_notify_event", leave)
