#!/usr/bin/env python3
"""
generate_manifests.py

Reads store.json and emits one manifest.plist per app/game.
Upload the generated files to your R2 bucket under manifests/<bundle_id>.plist.

Usage:
    python3 scripts/generate_manifests.py store.json --out-dir manifests/
"""

import argparse
import json
import os
import xml.etree.ElementTree as ET
from urllib.parse import quote


def escape_xml(text: str) -> str:
    return (
        text.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
    )


def build_manifest(item: dict) -> str:
    ipa_url = escape_xml(item.get("ipa_url", ""))
    icon_url = escape_xml(item.get("icon_url", ""))
    bundle_id = escape_xml(item.get("bundle_id", item.get("id", "")))
    version = escape_xml(item.get("version", "1.0"))
    title = escape_xml(item.get("name", "App"))

    plist = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>{ipa_url}</string>
                </dict>
                <dict>
                    <key>kind</key>
                    <string>display-image</string>
                    <key>url</key>
                    <string>{icon_url}</string>
                </dict>
                <dict>
                    <key>kind</key>
                    <string>full-size-image</string>
                    <key>url</key>
                    <string>{icon_url}</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>{bundle_id}</string>
                <key>bundle-version</key>
                <string>{version}</string>
                <key>kind</key>
                <string>software</string>
                <key>title</key>
                <string>{title}</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
"""
    return plist


def main():
    parser = argparse.ArgumentParser(description="Generate iOS OTA manifest plist files from store.json")
    parser.add_argument("store_json", help="Path to store.json")
    parser.add_argument("--out-dir", default="manifests", help="Output directory for plist files")
    args = parser.parse_args()

    with open(args.store_json, "r", encoding="utf-8") as f:
        catalog = json.load(f)

    os.makedirs(args.out_dir, exist_ok=True)

    for item in catalog.get("items", []):
        bundle_id = item.get("bundle_id", item.get("id"))
        plist = build_manifest(item)
        filename = f"{bundle_id}.plist"
        filepath = os.path.join(args.out_dir, filename)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(plist)
        print(f"Generated {filepath}")


if __name__ == "__main__":
    main()
