const hyprland = await Service.import("hyprland");

let updatesAvailable = Variable("0");

//make it a connector so that we can use it in hooks
updatesAvailable.connect("changed", () => {
  console.log("made it a connector");
});

const checkUpdates = () => {
  Utils.execAsync(`bash -c "checkupdates | wc -l"`)
    .then((out) => {
      updatesAvailable.value = out;
      console.log(out);
    })
    .catch((err) => console.log(err));
};

Utils.interval(30000, () => checkUpdates);

const updateLabel = Widget.Label().hook(updatesAvailable, (self) => {
  if (updatesAvailable.value === "0") {
    self.label = "";
  } else {
    self.css = "padding:0px 2px";
    self.label = updatesAvailable.value;
  }
});

const updateIcon = Widget.Icon().hook(updatesAvailable, (self) => {
  self.icon = "software-update-available-symbolic";
  if (updatesAvailable.value === "0") {
    self.css = "font-size:1px;color:transparent;";
  } else {
    self.css = "font-size:20px;padding:0px 1px;color:white";
  }
});

export const Updates = () =>
  Widget.EventBox({
    child: Widget.Box({
      children: [updateIcon, updateLabel],
    }),
    onPrimaryClick: () => {
      hyprland.message(`dispatch exec [ float; size 50% ] foot yay -Syu`);
    },
  });
