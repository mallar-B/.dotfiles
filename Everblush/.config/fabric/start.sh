#/bin/bash

source ~/.config/fabric/venv/bin/activate
export GTK_THEME=Everblush
export PYTHONPATH="$HOME/.config/fabric"

pid=$(ps aux | grep '[b]ar.py$' | awk '{print $2}')
pid2=$(ps aux | grep '[p]owermenu.py$' | awk '{print $2}')
pid3=$(ps aux | grep '[n]otification.py$' | awk '{print $2}')

## Bar
if [ -n "$pid" ]; then
    # kill "$pid" && GTK_DEBUG=interactive python ~/.config/fabric/window_layers/bar/bar.py&
    kill "$pid" && python ~/.config/fabric/window_layers/bar/bar.py &
else
    python ~/.config/fabric/window_layers/bar/bar.py &
fi

## Powermenu
if [ -n "$pid2" ]; then
    # kill "$pid2" && GTK_DEBUG=interactive python ~/.config/fabric/window_layers/powermenu/powermenu.py&
    kill "$pid2" && python ~/.config/fabric/window_layers/powermenu/powermenu.py &
else
    python ~/.config/fabric/window_layers/powermenu/powermenu.py &
fi

## Notifications
if [ -n "$pid3" ]; then
    # kill "$pid3" && GTK_DEBUG=interactive python ~/.config/fabric/window_layers/notification/notification.py
    kill "$pid3" && python ~/.config/fabric/window_layers/notification/notification.py &
else
    python ~/.config/fabric/window_layers/notification/notification.py &
fi
