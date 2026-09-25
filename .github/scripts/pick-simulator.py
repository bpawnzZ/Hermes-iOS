#!/usr/bin/env python3
"""Pick the newest available iOS simulator and boot it.

Prints the chosen simulator as "<name>|<udid>|<runtime>" on stdout.

Exists as a file rather than inline shell so the CI workflow stays readable
and this logic can be tested on its own. Runtime identifiers look like
`com.apple.CoreSimulator.SimRuntime.iOS-26-5`, so the version must be parsed
from the whole identifier -- taking only the last dotted component compares
"5" against "18" and silently picks the older runtime.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys


def main() -> int:
    raw = subprocess.run(
        ["xcrun", "simctl", "list", "devices", "available", "--json"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    devices = json.loads(raw)["devices"]

    candidates = []
    for runtime, devs in devices.items():
        if "iOS" not in runtime:
            continue
        usable = [d for d in devs if d.get("isAvailable") and "iPhone" in d["name"]]
        if not usable:
            continue
        match = re.search(r"iOS-(\d+)(?:-(\d+))?", runtime)
        version = (int(match.group(1)), int(match.group(2) or 0)) if match else (0, 0)
        candidates.append((version, runtime, usable[0]))

    if not candidates:
        print("no available iPhone simulator found", file=sys.stderr)
        return 1

    candidates.sort(key=lambda c: c[0])
    _, runtime, device = candidates[-1]
    print(f"{device['name']}|{device['udid']}|{runtime}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
