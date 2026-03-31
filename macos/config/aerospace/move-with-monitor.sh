#!/bin/bash
# Usage: move-with-monitor.sh (left|right)
# Moves window in direction; if at boundary, moves to adjacent monitor

direction=$1
if [[ "$direction" == "left" ]]; then
    monitor_dir="prev"
else
    monitor_dir="next"
fi

aerospace move --boundaries workspace --boundaries-action fail "$direction" \
    || aerospace move-node-to-monitor --focus-follows-window "$monitor_dir"
