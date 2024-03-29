#!/usr/bin/env bash

pager="less"
if command -v bat >/dev/null 2>&1; then
    pager="col -b | bat --paging=always --style=plain -l man"
fi

get_input () {
    temp_file=$(mktemp)
    (tmux command-prompt -p "$@" "run-shell \"echo '%1' > $temp_file\"") &
    wait
    selected=$(cat "$temp_file")
    rm "$temp_file"
    echo "$selected"
}

if tmux list-windows | grep -q 'man'; then
    id=$(tmux list-windows | grep 'man' | sed 's#\([0-9]\+\):.*#\1#')
    tmux select-window -t "$id"
else
    selected=$(get_input "Enter man query:")
    if command -v batman >/dev/null 2>&1; then
        if [ "$selected" = "" ]; then
            tmux neww -n 'man' -at 4 bash -c "batman"
        else
            tmux neww -n 'man' -at 4 bash -c "/usr/bin/man \"$selected\" | $pager"
        fi
    else
        if [ "$selected" = "" ]; then
            exit 0
        fi
        tmux neww -n 'man' -at 4 bash -c "/usr/bin/man '$selected' | $pager"
    fi
fi
