#/bin/bash

source ~/.config/fabric/venv/bin/activate
export GTK_THEME=Everblush
export PYTHONPATH=$(pwd)

pid=$(ps aux | grep '[p]owermenu.py$' | awk '{print $2}')
if [ -n "$pid" ]; then
    kill "$pid"
else
    python ~/.config/fabric/window_layers/powermenu/powermenu.py
fi


