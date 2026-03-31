#!/bin/bash
# Move focused window to workspace; if workspace is empty, move it to current monitor first
workspace=$1

windows=$(aerospace list-windows --workspace "$workspace" --count 2>/dev/null)

if [ "$windows" -eq 0 ] 2>/dev/null; then
  monitor=$(aerospace list-monitors --focused --format '%{monitor-name}')
  aerospace move-workspace-to-monitor --workspace "$workspace" "$monitor"
fi

aerospace move-node-to-workspace "$workspace"
