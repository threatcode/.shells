# silence eval "add-path NODE_PATH /home/linuxbrew/.linuxbrew/Cellar/node/(^node_modules*/)#/node_modules"
# re 'add-path NODE_PATH' '/usr/local/lib/node_modules/' '/usr/lib/nodejs' '/usr/lib/node_module' '/usr/share/javascript'

export CALENDAR_HEATMAP_ASSETS_PATH="$codedir/misc/calendarheatmap/charts/assets" # @todo bundle the assets (font) into the `go install` itself
