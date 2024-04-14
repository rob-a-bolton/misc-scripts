#!/bin/bash


FILE="$1"

if [[ -z "$FILE" ]]; then
  echo "No sound file provided" 1>&2
  exit 1
fi
if [[ ! -f "$FILE" ]]; then
  FILE="$HOME/downloads/sounds/$FILE"
fi
if [[ ! -f "$FILE" ]]; then
  echo "File not found at $1 or $FILE" 1>&2
  exit 1
fi

PWINFO="$(pw-dump)"

sink_str=$(jq -r 'map(select(.info.props["target.object"] == null and .info.props["media.class"] == "Stream/Input/Audio")) | map(.info.props["node.name"]) | @sh' <<< "$PWINFO")
sinks="$(echo $sink_str | sed "s/'\([^']\+\)' */\1\n/g" )"
IFS=$'\n'
for sink in $sinks; do
  pw-play --target "$sink" "$FILE"&
done
pw-play --volume 0.5 "$FILE"&
