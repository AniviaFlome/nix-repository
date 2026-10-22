#!/bin/sh
# Wrapper for dota2-rpc-client. The binary resolves config.json, lang/ and
# templates/ relative to its own location (/proc/self/exe) and needs them
# writable, so seed a per-user copy on first run (and re-seed after package
# updates, preserving the user's config.json).
set -e
export GSETTINGS_SCHEMA_DIR="@gsettingsSchemas@"
appDir="@appDir@"
version="@version@"
dataDir="${XDG_DATA_HOME:-$HOME/.local/share}/dota2-rpc-client"
stamp="$dataDir/.version"
if [ ! -f "$stamp" ] || [ "$(cat "$stamp")" != "$version" ]; then
  mkdir -p "$dataDir/uploads"
  cp -f "$appDir/dota2-rpc-client" "$appDir/libdiscord_game_sdk.so" "$dataDir/"
  rm -rf "$dataDir/lang" "$dataDir/templates"
  cp -r "$appDir/lang" "$appDir/templates" "$dataDir/"
  if [ ! -f "$dataDir/config.json" ]; then
    cp "$appDir/config.json" "$dataDir/"
  fi
  chmod +x "$dataDir/dota2-rpc-client"
  printf '%s' "$version" >"$stamp"
fi
exec "$dataDir/dota2-rpc-client" "$@"
