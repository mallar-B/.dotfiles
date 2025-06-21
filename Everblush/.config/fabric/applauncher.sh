#/bin/bash

source ~/.config/fabric/venv/bin/activate
export GTK_THEME=Everblush

pid=$(ps aux | grep '[a]pplauncher.py$' | awk '{print $2}')
c=""
if [ -n "$pid" ]; then
    kill "$pid" && GTK_DEBUG=interactive python ~/.config/fabric/applauncher.py
    # kill "$pid" && python ~/.config/fabric/bar.py
else
    python ~/.config/fabric/applauncher.py
fi

