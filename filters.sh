# shellcheck shell=sh
# shellcheck disable=SC2154

on_event() (
	echo "$event" | jq -e --arg event_type "$1" '.type == $event_type' > /dev/null
)
