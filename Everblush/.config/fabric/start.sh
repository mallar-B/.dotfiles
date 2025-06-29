#/bin/bash

source ~/.config/fabric/venv/bin/activate
export GTK_THEME=Everblush
export PYTHONPATH="$HOME/.config/fabric"

pid=$(ps aux | grep '[b]ar.py$' | awk '{print $2}')
pid2=$(ps aux | grep '[p]owermenu.py$' | awk '{print $2}')

if [ -n "$pid" ]; then
    # kill "$pid" && GTK_DEBUG=interactive python ~/.config/fabric/window_layers/bar/bar.py&
    kill "$pid" && python ~/.config/fabric/window_layers/bar/bar.py&
    kill "$pid2" && GTK_DEBUG=interactive python ~/.config/fabric/window_layers/powermenu/powermenu.py&
    # kill "$pid2" && python ~/.config/fabric/window_layers/powermenu/powermenu.py&
else
    python ~/.config/fabric/window_layers/bar/bar.py&
    python ~/.config/fabric/window_layers/powermenu/powermenu.py&
fi

