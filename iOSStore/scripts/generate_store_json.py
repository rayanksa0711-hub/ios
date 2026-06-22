#!/usr/bin/env python3
"""
generate_store_json.py

Scans a local directory of game/app folders and generates a store.json catalog
ready for Cloudflare R2. Each folder is treated as one store item.

Expected folder layout:
    games/
        Agar.io_2.21.1.1658611480/
            Agar.io_2.21.1.1658611480.ipa
            icon.png
        Clash of Clans_14.635.4/
            Clash of Clans_14.635.4.ipa
            icon.png

Usage:
    python3 scripts/generate_store_json.py \
        --input-dir ./games \
        --base-url https://pub-xxxxxxxx.r2.dev/logic \
        --output store.json

The script tries to read the bundle identifier and version from the IPA's
Info.plist. If that fails it falls back to a sanitized bundle id derived from
the folder name.
"""

import argparse
import json
import os
import plistlib
import re
import sys
import zipfile
from pathlib import Path
from urllib.parse import quote


def sanitize_bundle_id(name: str) -> str:
    """Turn a display name into a safe bundle id suffix."""
    cleaned = re.sub(r"[^a-zA-Z0-9]", "-", name).lower().strip("-")
    return f"com.logic.{cleaned}" if cleaned else "com.logic.unknown"


def parse_folder_name(folder_name: str) -> tuple[str, str]:
    """
    Extract app name and version from a folder like:
        'Agar.io_2.21.1.1658611480' -> ('Agar.io', '2.21.1')
        'Clash of Clans_14.635.4'   -> ('Clash of Clans', '14.635.4')
    """
    parts = folder_name.rsplit("_", 1)
    if len(parts) == 2:
        name, version_build = parts
        # Some versions already contain underscores as separators.
        # Split by dot and take the first 2-3 numeric components as version.
        vb_parts = version_build.split(".")
        version_parts = []
        for part in vb_parts:
            # Accept version components like 2, 21, 1, 14, 635, 4.
            # Stop at the build number (typically a long integer like 1658611480).
            if re.match(r"^\d+$", part) and len(part) <= 5:
                version_parts.append(part)
            elif re.match(r"^\d+[a-zA-Z]+$", part):
                version_parts.append(part)
            else:
                break
        version = ".".join(version_parts) if version_parts else version_build
        return name, version
    return folder_name, "1.0"


def find_ipa_and_icon(folder: Path) -> tuple[Path | None, Path | None]:
    """Find the first .ipa and the first icon image inside a folder."""
    ipa = next((f for f in folder.iterdir() if f.suffix.lower() == ".ipa"), None)
    icon = next(
        (f for f in folder.iterdir() if f.stem.lower() in ("icon", "appicon", "logo")
         and f.suffix.lower() in (".png", ".jpg", ".jpeg")),
        None,
    )
    return ipa, icon


def extract_ipa_info(ipa_path: Path) -> dict:
    """Read Info.plist from an IPA to get bundle id and version."""
    info = {"bundle_id": None, "version": None}
    try:
        with zipfile.ZipFile(ipa_path, "r") as zf:
            payload = [n for n in zf.namelist() if n.startswith("Payload/") and n.endswith(".app/Info.plist")]
            if not payload:
                return info
            plist_path = payload[0]
            with zf.open(plist_path) as plist_file:
                plist = plistlib.load(plist_file)
                info["bundle_id"] = plist.get("CFBundleIdentifier")
                info["version"] = plist.get("CFBundleShortVersionString") or plist.get("CFBundleVersion")
    except Exception as e:
        print(f"  Warning: could not read IPA info: {e}", file=sys.stderr)
    return info


def build_store_item(folder: Path, base_url: str) -> dict | None:
    folder_name = folder.name
    name, version = parse_folder_name(folder_name)
    ipa, icon = find_ipa_and_icon(folder)

    if not ipa:
        print(f"  Skipping {folder_name}: no .ipa found", file=sys.stderr)
        return None

    print(f"Processing {folder_name}...")
    ipa_info = extract_ipa_info(ipa)
    bundle_id = ipa_info.get("bundle_id") or sanitize_bundle_id(name)
    version = ipa_info.get("version") or version

    # Ensure base_url has no trailing slash for clean joining.
    base = base_url.rstrip("/")
    encoded_folder = quote(folder_name, safe="/")
    encoded_ipa = quote(ipa.name, safe="/")
    ipa_url = f"{base}/{encoded_folder}/{encoded_ipa}"

    icon_url = ""
    if icon:
        encoded_icon = quote(icon.name, safe="/")
        icon_url = f"{base}/{encoded_folder}/{encoded_icon}"

    size_bytes = ipa.stat().st_size

    return {
        "id": bundle_id,
        "name": name,
        "developer": "LOGIC STORE",
        "category": "game",
        "description": f"{name} - ready to install via LOGIC STORE.",
        "icon_url": icon_url,
        "ipa_url": ipa_url,
        "bundle_id": bundle_id,
        "version": version,
        "size_bytes": size_bytes,
        "screenshots": [],
        "telegram_description": "",
    }


def main():
    parser = argparse.ArgumentParser(description="Generate store.json from local game/app folders")
    parser.add_argument("--input-dir", required=True, help="Directory containing game/app folders")
    parser.add_argument("--base-url", required=True, help="Public R2 base URL where folders are hosted")
    parser.add_argument("--output", default="store.json", help="Output store.json path")
    args = parser.parse_args()

    input_dir = Path(args.input_dir)
    if not input_dir.is_dir():
        print(f"Error: {input_dir} is not a directory", file=sys.stderr)
        sys.exit(1)

    items = []
    for entry in sorted(input_dir.iterdir()):
        if entry.is_dir():
            item = build_store_item(entry, args.base_url)
            if item:
                items.append(item)

    catalog = {"items": items}

    output_path = Path(args.output)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)

    print(f"\nGenerated {output_path} with {len(items)} item(s).")


if __name__ == "__main__":
    main()
