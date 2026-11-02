#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ $# -gt 1 ]]; then
  echo "Usage: bash scripts/run-ios-simulator.sh [simulator-UDID]" >&2
  exit 1
fi

for tool in flutter xcrun python3; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing $tool. See the iOS setup instructions in README.md." >&2
    exit 1
  fi
done

simulator_id=$(python3 - "${1:-}" <<'PY'
import json
import subprocess
import sys

inventory = json.loads(subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "--json"], text=True
))
devices = [
    device
    for runtime, entries in inventory["devices"].items()
    if ".iOS-" in runtime
    for device in entries
    if device.get("isAvailable")
]
requested = sys.argv[1]
if requested:
    candidates = [device for device in devices if device["udid"] == requested]
else:
    candidates = [device for device in devices
                  if "iPhone" in device.get("deviceTypeIdentifier", "")]
    candidates.sort(key=lambda device: device["state"] != "Booted")
if not candidates:
    sys.exit("No matching iOS simulator. Install an iOS runtime in Xcode, "
             "or choose a UDID from: xcrun simctl list devices available")
print(candidates[0]["udid"])
PY
)

echo "Running working tree: $(git branch --show-current) @ $(git rev-parse --short HEAD)"
echo "Simulator: $simulator_id"
xcrun simctl bootstatus "$simulator_id" -b
open -a Simulator --args -CurrentDeviceUDID "$simulator_id"
exec flutter run -d "$simulator_id"
