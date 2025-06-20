#/bin/bash

source ~/.config/fabric/venv/bin/activate

pid=$(ps aux | grep '[b]ar.py$' | awk '{print $2}')
c=""
if [ -n "$pid" ]; then
    kill "$pid" && GTK_DEBUG=interactive python ~/Fabric/bar.py
    # kill "$pid" && python ~/.config/fabric/bar.py
else
    python ~/.config/fabric/bar.py
fi

