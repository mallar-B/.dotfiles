#/bin/bash

source ~/.config/fabric/venv/bin/activate
export PYTHONPATH=$(pwd)

pid=$(ps aux | grep '[b]ar.py$' | awk '{print $2}')
c=""
if [ -n "$pid" ]; then
    kill "$pid" && GTK_DEBUG=interactive python ~/.config/fabric/window-layers/bar/bar.py
    # kill "$pid" && python ~/.config/fabric/window-layers/bar/bar.py
else
    python ~/.config/fabric/window-layers/bar/bar.py
fi

