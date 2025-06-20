from fabric.core.fabricator import Fabricator
from fabric.utils import exec_shell_command
from fabric.widgets.box import Box
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.label import Label
from fabric.widgets.overlay import Overlay


class CpuWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(name="bar-cpu-progress-bar-container", **kwargs)

        cpu_bash_command = "bash -c '$HOME/.local/bin/cpu_usage.sh'"

        self.cpu_usage = Fabricator(
            interval=3500,
            poll_from=lambda f: exec_shell_command(cpu_bash_command),
            on_changed=lambda f, value: self.update_cpu_progress_bar(value.strip()),
        )

        self.cpu_icon = Label(
            name="cpu-icon", style_classes=["bar-process-icon"], label=""
        )

        self.cpu_progress_bar = CircularProgressBar(
            name="cpu-progress-bar",
            style_classes=["bar-circular-progress-bar"],
            size=35,
            show_pie=False,
            max_value=100,
            child=Overlay(child=self.cpu_icon),
        )

        self.children = [self.cpu_progress_bar]

    def update_cpu_progress_bar(self, value, *_):
        # After splitting structure of lines will be [cpu n: a%, cpu n-1: b%,..., cpu 0: c%,'']
        lines = value.split(";")
        total_percentage_value = lines[-2].strip().split(" ")[1].rstrip("%")
        self.cpu_progress_bar.value = float(total_percentage_value)

        tooltip_text = ""
        for line in lines[:-1]:
            line = line.strip(" ")
            tooltip_text += (
                f"<span bgcolor='#141b1e' fgcolor='#dadada'><big>{line}</big></span>"
            )
        print(tooltip_text)
        # Set tooltip of the box
        self.set_tooltip_markup(tooltip_text)


class MemWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(name="bar-mem-progress-bar-container", **kwargs)

        mem_bash_command = "bash -c '$HOME/.local/bin/mem_usage.sh'"

        self.mem_usage = Fabricator(
            interval=5000,
            poll_from=mem_bash_command,
            on_changed=lambda f, value: self.update_mem_progress_bar(value.strip()),
        )

        self.mem_icon = Label(
            name="mem-icon", style_classes=["bar-process-icon"], label=""
        )

        self.mem_progress_bar = CircularProgressBar(
            name="mem-progress-bar",
            style_classes=["bar-circular-progress-bar"],
            size=35,
            show_pie=False,
            max_value=100,
            child=Overlay(child=self.mem_icon),
        )
        self.children = [self.mem_progress_bar]

    def update_mem_progress_bar(self, value, *_):
        lines = value.split(" ")

        total_mem = float(lines[0])
        used_mem = float(lines[1])
        used_percent = float(lines[2])

        used_mem_gb = used_mem / 1024
        total_mem_gb = total_mem / 1024
        available_mem_gb = total_mem_gb - used_mem_gb

        self.mem_progress_bar.value = used_percent
        # Set tooltip of the box
        self.set_tooltip_markup(
            f"""
            <span bgcolor='#141b1e' fgcolor='#dadada'><big>Total: {total_mem_gb:.2f} GB</big></span>
            <span bgcolor='#141b1e' fgcolor='#dadada'><big>Used: {used_mem_gb:.2f} GB ({used_percent}%)</big></span>
            <span bgcolor='#141b1e' fgcolor='#dadada'><big>Available: {available_mem_gb:.2f} GB</big></span>
            """
        )


class SystemInfo(Box):
    def __init__(self, **kwargs):
        super().__init__(name="bar-system-info-container", **kwargs)

        self.cpu_box = CpuWidget()
        self.mem_box = MemWidget()
        self.children = [self.cpu_box, self.mem_box]
