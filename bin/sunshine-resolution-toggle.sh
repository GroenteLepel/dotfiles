#!/usr/bin/env bash

set -euo pipefail

OUTPUT="DisplayPort-2"
HANDHELD_MODE="1280x800_90.00"
DOCKED_MODE="2560x1440_120.00"
STATE_FILE="/tmp/sunshine-resolution-state-DisplayPort-2"
LOG_FILE="/tmp/sunshine-resolution.log"

log() {
  local level="$1"
  local message="$2"
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message" | tee -a "$LOG_FILE" >&2
}

find_current_mode_and_rate() {
  xrandr --query | awk -v output="$OUTPUT" '
    $1 == output && $2 == "connected" { in_output = 1; next }
    in_output && $2 == "connected" { in_output = 0 }
    in_output && /\*/ {
      mode = $1
      rate = ""
      for (i = 2; i <= NF; i++) {
        if ($i ~ /\*/) {
          rate = $i
          gsub(/\*/, "", rate)
          gsub(/\+/, "", rate)
          break
        }
      }
      print mode "|" rate
      exit
    }
  '
}

mode_exists_for_output() {
  local mode="$1"
  xrandr --query | awk -v output="$OUTPUT" -v wanted_mode="$mode" '
    $1 == output && $2 == "connected" { in_output = 1; next }
    in_output && $2 == "connected" { in_output = 0 }
    in_output && $1 == wanted_mode { found = 1; exit }
    END { exit(found ? 0 : 1) }
  '
}

validate_target_modes() {
  if ! mode_exists_for_output "$HANDHELD_MODE"; then
    log "ERROR" "Mode $HANDHELD_MODE is missing for $OUTPUT"
    exit 1
  fi
  if ! mode_exists_for_output "$DOCKED_MODE"; then
    log "ERROR" "Mode $DOCKED_MODE is missing for $OUTPUT"
    exit 1
  fi
}

save_state() {
  local mode="$1"
  local rate="$2"
  {
    printf 'MODE=%s\n' "$mode"
    printf 'RATE=%s\n' "$rate"
  } > "$STATE_FILE"
}

load_state_field() {
  local field="$1"
  awk -F '=' -v wanted="$field" '$1 == wanted { print $2; exit }' "$STATE_FILE"
}

set_output_mode() {
  local mode="$1"
  local rate="${2:-}"
  if [[ -n "$rate" ]]; then
    xrandr --output "$OUTPUT" --mode "$mode" --rate "$rate"
  else
    xrandr --output "$OUTPUT" --mode "$mode"
  fi
}

run_do() {
  validate_target_modes

  if [[ -f "$STATE_FILE" ]]; then
    log "ERROR" "State file already exists ($STATE_FILE). Refusing to continue."
    exit 1
  fi

  local current
  current="$(find_current_mode_and_rate || true)"
  if [[ -z "$current" ]]; then
    log "ERROR" "Could not determine current mode for $OUTPUT"
    exit 1
  fi

  local current_mode current_rate
  current_mode="${current%%|*}"
  current_rate="${current#*|}"
  save_state "$current_mode" "$current_rate"

  local width="${SUNSHINE_CLIENT_WIDTH:-}"
  local height="${SUNSHINE_CLIENT_HEIGHT:-}"
  local fps="${SUNSHINE_CLIENT_FPS:-unknown}"
  local hdr="${SUNSHINE_CLIENT_HDR:-unknown}"

  if [[ -z "$width" || -z "$height" ]]; then
    log "ERROR" "Missing SUNSHINE_CLIENT_WIDTH/HEIGHT"
    exit 1
  fi

  local target_mode target_rate
  case "${width}x${height}" in
    "1280x800")
      target_mode="$HANDHELD_MODE"
      target_rate="90.00"
      ;;
    "2560x1440")
      target_mode="$DOCKED_MODE"
      target_rate="120.00"
      ;;
    *)
      log "WARN" "Unexpected request ${width}x${height} @${fps} HDR=${hdr}; leaving mode unchanged."
      exit 2
      ;;
  esac

  log "INFO" "Switching $OUTPUT to $target_mode for request ${width}x${height} @${fps} HDR=${hdr}"
  set_output_mode "$target_mode" "$target_rate"
}

run_undo() {
  if [[ ! -f "$STATE_FILE" ]]; then
    log "ERROR" "State file not found ($STATE_FILE); cannot restore previous mode."
    exit 1
  fi

  local restore_mode restore_rate
  restore_mode="$(load_state_field MODE)"
  restore_rate="$(load_state_field RATE)"

  if [[ -z "$restore_mode" ]]; then
    log "ERROR" "Saved state is invalid: missing MODE"
    exit 1
  fi

  log "INFO" "Restoring $OUTPUT to $restore_mode${restore_rate:+ @${restore_rate}}"
  set_output_mode "$restore_mode" "$restore_rate"
  rm -f "$STATE_FILE"
}

main() {
  if [[ $# -ne 1 ]]; then
    log "ERROR" "Usage: $0 do|undo"
    exit 1
  fi

  case "$1" in
    do)
      run_do
      ;;
    undo)
      run_undo
      ;;
    *)
      log "ERROR" "Unknown action: $1 (expected do|undo)"
      exit 1
      ;;
  esac
}

main "$@"
