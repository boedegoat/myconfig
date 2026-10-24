#!/bin/sh

action=${1:-toggle}
center_width=${2:-120}

current_pane=$(tmux display-message -p '#{pane_id}')
window_id=$(tmux display-message -p '#{window_id}')
zen_pane=$(tmux show-options -wvq -t "$window_id" @zen_center_pane)

zen_enabled() {
    [ -n "$zen_pane" ] && tmux display-message -p -t "$zen_pane" '#{pane_id}' >/dev/null 2>&1
}

disable_zen() {
    zen_enabled || return 0

    tmux list-panes -t "$window_id" -F '#{pane_id} #{@zen_padding}' |
        while read -r pane marker; do
            [ "$marker" = 1 ] && tmux kill-pane -t "$pane"
        done

    tmux set-option -wuq -t "$window_id" @zen_center_pane
    tmux select-pane -t "$zen_pane"
}

enable_zen() {
    if zen_enabled; then
        return 0
    fi

    pane_count=$(tmux display-message -p -t "$window_id" '#{window_panes}')
    window_width=$(tmux display-message -p -t "$window_id" '#{window_width}')

    if [ "$pane_count" -ne 1 ]; then
        tmux display-message 'Zen mode only works with a single pane'
        return 1
    fi

    total_margin=$((window_width - center_width - 2))
    if [ "$total_margin" -lt 10 ]; then
        tmux display-message 'Zen mode: window is too narrow'
        return 1
    fi

    side_width=$((total_margin / 2))
    right_pane=$(tmux split-window -h -d -t "$current_pane" -P -F '#{pane_id}' 'exec cat')
    left_pane=$(tmux split-window -h -b -d -t "$current_pane" -P -F '#{pane_id}' 'exec cat')

    tmux set-option -pq -t "$left_pane" @zen_padding 1
    tmux set-option -pq -t "$right_pane" @zen_padding 1
    tmux set-option -wq -t "$window_id" @zen_center_pane "$current_pane"

    tmux select-layout -t "$window_id" even-horizontal >/dev/null
    tmux resize-pane -t "$left_pane" -x "$side_width"
    tmux resize-pane -t "$current_pane" -x "$center_width"
    tmux select-pane -t "$current_pane"
}

split_from_full_width() {
    direction=$1

    if zen_enabled; then
        current_pane=$zen_pane
    fi
    current_path=$(tmux display-message -p -t "$current_pane" '#{pane_current_path}')
    disable_zen
    tmux split-window "$direction" -t "$current_pane" -c "$current_path"
}

case "$action" in
    on)
        enable_zen
        ;;
    off)
        disable_zen
        ;;
    toggle)
        if zen_enabled; then
            disable_zen
        else
            enable_zen
        fi
        ;;
    split-horizontal)
        split_from_full_width -h
        ;;
    split-vertical)
        split_from_full_width -v
        ;;
    *)
        tmux display-message "Unknown zen action: $action"
        exit 2
        ;;
esac
