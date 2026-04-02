#!/usr/bin/env bash

export WEZTERM_UNIX_SOCKET="$1"
readonly PROFILE="$2"

readonly CONFIG_DIR="$HOME/.config/wezterm/workspaces"
readonly CONFIG_FILE="$CONFIG_DIR/workspaces.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  exit 1
fi

if [[ -z "$PROFILE" ]]; then
  exit 1
fi

readonly WEZTERM_PATH=$(jq -r '.wezterm_path' "$CONFIG_FILE")
if [[ -z "$WEZTERM_PATH" || "$WEZTERM_PATH" == "null" ]]; then
  exit 1
fi

sleep 1

readonly WORKSPACE_COUNT=$(jq ".groups.${PROFILE} | length" "$CONFIG_FILE")

for ((workspace_index=1; workspace_index<WORKSPACE_COUNT; workspace_index++)); do
  workspace_name=$(jq -r ".groups.${PROFILE}[$workspace_index].name" "$CONFIG_FILE")
  workspace_directory=$(jq -r ".groups.${PROFILE}[$workspace_index].directory" "$CONFIG_FILE")

  pane_id=$("$WEZTERM_PATH" cli spawn --new-window --workspace "$workspace_name" --cwd "$workspace_directory" 2>/dev/null)

  window_id=$("$WEZTERM_PATH" cli list --format json | jq -r ".[] | select(.pane_id == $pane_id) | .window_id")

  tab_count=$(jq -r ".groups.${PROFILE}[$workspace_index].tabs // 3" "$CONFIG_FILE")

  for ((tab_index=2; tab_index<=tab_count; tab_index++)); do
    "$WEZTERM_PATH" cli spawn --window-id "$window_id" --cwd "$workspace_directory" 2>/dev/null
  done

  "$WEZTERM_PATH" cli activate-pane --pane-id "$pane_id" 2>/dev/null
done
