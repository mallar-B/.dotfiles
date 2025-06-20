from fabric.widgets.button import Button
from fabric.widgets.eventbox import EventBox
from fabric.audio.service import Audio
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.box import Box
from fabric.widgets.overlay import Overlay
from fabric.widgets.label import Label
from fabric.widgets.image import Image
from fabric.utils import exec_shell_command_async
from utils import add_cursor_hover


class BarVolume(Box):
    def __init__(self, **kwargs):
        super().__init__(name="bar-volume", **kwargs)

        self.audio = Audio(max_volume=153)

        self.progress_bar = CircularProgressBar(
            name="bar-volume-progress-bar",
            style_classes=["bar-circular-progress-bar"],
            show_pie=False,
            size=35,
        )

        self.icon = Image(
            icon_name="multimedia-volume-control-symbolic",
            size=16,
        )

        self.event_box = EventBox(
            events="scroll",
            child=Overlay(
                child=self.progress_bar,
                overlays=self.icon,
            ),
            tooltip_text=(
                self.audio.speaker.name if self.audio.speaker else "No speaker"
            ),
        )

        self.audio.connect("notify::speaker", self.on_speaker_changed)
        self.event_box.connect("scroll-event", self.on_scroll)
        self.event_box.connect("button-press-event", self.on_click)
        self.event_box.connect("button-release-event", self.on_release)
        # self.icon.connect("notify::label", self.get_icon)
        # self.icon.connect("scroll-event", self.get_icon)
        self.add(self.event_box)
        add_cursor_hover(self.event_box, "pointer")
        add_cursor_hover(self, "pointer")

    def on_click(self, _, event):
        if event.button == 1:
            exec_shell_command_async(
                "bash -c 'pgrep pavucontrol >/dev/null && pkill pavucontrol || pavucontrol &'"
            )
            return
        if event.button == 3:
            exec_shell_command_async(
                "bash -c '$HOME/.local/bin/sound_source_toggle.sh'"
            )
            return
        if event.button == 2:
            exec_shell_command_async(
                "bash -c 'pactl set-sink-mute @DEFAULT_SINK@ toggle'"
            )
            return
        return

    def on_release(self, _, event):
        if event.button == 2:
            self.get_icon()  # update icon after muting
            return

    def on_scroll(self, _, event):
        match event.direction:
            case 0:
                self.audio.speaker.volume += 8
            case 1:
                self.audio.speaker.volume -= 8
        self.get_icon()
        return

    def on_speaker_changed(self, *_):
        if not self.audio.speaker:
            return
        self.progress_bar.value = self.audio.speaker.volume / 100
        self.audio.speaker.bind(
            "volume", "value", self.progress_bar, lambda _, v: v / 100
        )
        self.get_icon()
        return

    def get_icon(self, *_):
        if not self.audio.speaker:
            return
        # self.event_box.set_tooltip_text(self.audio.speaker.name)
        self.event_box.set_tooltip_markup(
            f"<span bgcolor='#141b1e' fgcolor='#dadada'><big>{self.audio.speaker.name}</big></span>"
        )
        speaker = self.audio.speaker
        size = 18
        print(speaker.volume)
        if speaker.volume <= 0 or speaker.muted:
            self.icon.set_from_icon_name("audio-volume-muted-symbolic", size)
            return
        if speaker.volume > 0 and speaker.volume <= 30:
            self.icon.set_from_icon_name("audio-volume-low-symbolic", size)
            return
        if speaker.volume > 30 and speaker.volume <= 60:
            self.icon.set_from_icon_name("audio-volume-medium-symbolic", size)
            return
        if speaker.volume > 60 and speaker.volume <= 100:
            self.icon.set_from_icon_name("audio-volume-high-symbolic", size)
            return
        if speaker.volume > 100:
            self.icon.set_from_icon_name("audio-volume-overamplified-symbolic", size)
            return

        return
