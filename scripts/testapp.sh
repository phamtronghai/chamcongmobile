#!/usr/bin/env bash
# Chạy app trên Android emulator + iOS simulator (tự boot nếu chưa mở).
# Usage: ./scripts/testapp.sh   hoặc   make testapp
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# --- Cấu hình (sửa nếu đổi máy ảo) ---
# Xem id AVD: flutter emulators  hoặc  emulator -list-avds
ANDROID_AVD="${ANDROID_AVD:-Pixel_10_Pro}"
IOS_SIMULATOR_NAME="${IOS_SIMULATOR_NAME:-iPhone 17 Pro}"
IOS_SIMULATOR_UDID="${IOS_SIMULATOR_UDID:-BA7CF17C-8D83-47FB-A3F5-DFEE600DB227}"
BOOT_TIMEOUT_SEC="${BOOT_TIMEOUT_SEC:-120}"

log() { printf '\033[1;36m[testapp]\033[0m %s\n' "$*"; }

device_connected() {
  local pattern="$1"
  flutter devices 2>/dev/null | grep -qi "$pattern"
}

wait_for_device() {
  local pattern="$1"
  local label="$2"
  local elapsed=0
  while ! device_connected "$pattern"; do
    if (( elapsed >= BOOT_TIMEOUT_SEC )); then
      echo "Timeout: không thấy $label sau ${BOOT_TIMEOUT_SEC}s" >&2
      exit 1
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
}

ensure_android() {
  if device_connected "android"; then
    log "Android đã sẵn sàng."
    return
  fi
  log "Khởi động Android AVD: $ANDROID_AVD"
  flutter emulators --launch "$ANDROID_AVD" &
  wait_for_device "android" "Android emulator"
}

ensure_ios() {
  if device_connected "ios"; then
    log "iOS Simulator đã sẵn sàng."
    return
  fi
  log "Khởi động iOS Simulator: $IOS_SIMULATOR_NAME"
  if ! xcrun simctl boot "$IOS_SIMULATOR_UDID" 2>/dev/null; then
    xcrun simctl boot "$IOS_SIMULATOR_NAME" 2>/dev/null || true
  fi
  open -a Simulator
  wait_for_device "ios" "iOS Simulator"
}

resolve_device_ids() {
  # Lấy device id từ `flutter devices` (dòng có • id • platform).
  ANDROID_ID="$(flutter devices 2>/dev/null | awk '/android/ { for (i=1;i<=NF;i++) if ($i=="•") { print $(i+1); exit } }')"
  IOS_ID="$(flutter devices 2>/dev/null | awk '/ios/ && !/macos/ { for (i=1;i<=NF;i++) if ($i=="•") { print $(i+1); exit } }')"

  if [[ -z "${ANDROID_ID:-}" || -z "${IOS_ID:-}" ]]; then
    echo "Không lấy được device id. Chạy: flutter devices" >&2
    flutter devices >&2 || true
    exit 1
  fi
  log "Android: $ANDROID_ID"
  log "iOS:     $IOS_ID"
}

cleanup() {
  if [[ -n "${ANDROID_PID:-}" ]] && kill -0 "$ANDROID_PID" 2>/dev/null; then
    kill "$ANDROID_PID" 2>/dev/null || true
  fi
  if [[ -n "${IOS_PID:-}" ]] && kill -0 "$IOS_PID" 2>/dev/null; then
    kill "$IOS_PID" 2>/dev/null || true
  fi
}

ensure_android
ensure_ios
resolve_device_ids

log "flutter run trên 2 thiết bị (Ctrl+C dừng cả hai)…"
trap cleanup INT TERM EXIT

flutter run -d "$ANDROID_ID" &
ANDROID_PID=$!
flutter run -d "$IOS_ID" &
IOS_PID=$!

wait "$ANDROID_PID" "$IOS_PID"
