from fabric.widgets.datetime import DateTime


class Date (DateTime):
    def __init__(self, **kwargs):
        super().__init__(
            name="date",
            formatters=["%a|%H:%M|%d-%m", "%H:%M:%S"],
            **kwargs
        )
