#!/bin/bash
# Switch to workspace; if it's empty, move it to the current monitor first
workspace=$1

windows=$(aerospace list-windows --workspace "$workspace" --count 2>/dev/null)
echo $windows

if [ "$windows" -eq 0 ] 2>/dev/null; then
  monitor=$(aerospace list-monitors --focused --format '%{monitor-name}')
  aerospace move-workspace-to-monitor --workspace "$workspace" "$monitor"
fi

aerospace workspace "$workspace"
