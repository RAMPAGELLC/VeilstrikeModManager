#!/bin/sh
echo -ne '\033c\033]0;Veilstrike Mod Manager\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/VeilstrikeModManager.x86_64" "$@"
