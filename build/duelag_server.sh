#!/bin/sh
echo -ne '\033c\033]0;UO-dueller\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/duelag_server.pck" "$@"
