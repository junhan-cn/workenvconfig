#!/bin/bash 

tmux attach-session -t`tmux ls | head  -1 | awk -F ":" '{print $1}'`
