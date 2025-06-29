#/bin/bash

source ~/.config/fabric/venv/bin/activate
export GTK_THEME=Everblush
export PYTHONPATH=$(pwd)

pid=$(ps aux | grep '[a]pplauncher.py$' | awk '{print $2}')
c=""
if [ -n "$pid" ]; then
    # kill "$pid" && GTK_DEBUG=interactive python ~/.config/fabric/window-layers/applauncher/applauncher.py
    # kill "$pid" && python ~/.config/fabric/window-layers/applauncher/applauncher.py
    kill "$pid"
else
    python ~/.config/fabric/window-layers/applauncher/applauncher.py
fi

