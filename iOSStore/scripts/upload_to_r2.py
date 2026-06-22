#!/usr/bin/env python3
"""
upload_to_r2.py

Uploads store.json and manifests/ to Cloudflare R2.
"""

import boto3
from botocore.config import Config
from pathlib import Path
import sys

ACCOUNT_ID = "a1205b738c718247fe0d61ddffc8486e"
ACCESS_KEY_ID = "8f846642cd812f7bc61c29f9d2acde18"
SECRET_ACCESS_KEY = "8d42d91e0df0e7b96fe06d42dd8d84a3c8d91d2dc54f9d0f9ddac2c90d54a054"
BUCKET_NAME = "logic"

ENDPOINT_URL = f"https://{ACCOUNT_ID}.r2.cloudflarestorage.com"

s3 = boto3.client(
    "s3",
    endpoint_url=ENDPOINT_URL,
    aws_access_key_id=ACCESS_KEY_ID,
    aws_secret_access_key=SECRET_ACCESS_KEY,
    config=Config(signature_version="s3v4"),
)


def upload_file(local_path: Path, key: str, content_type: str):
    print(f"Uploading {local_path} -> s3://{BUCKET_NAME}/{key}")
    s3.upload_file(
        str(local_path),
        BUCKET_NAME,
        key,
        ExtraArgs={"ContentType": content_type},
    )


def main():
    base_dir = Path(__file__).parent.parent
    store_json = base_dir / "store.json"
    manifests_dir = base_dir / "manifests"

    if not store_json.exists():
        print(f"Missing {store_json}", file=sys.stderr)
        sys.exit(1)

    if not manifests_dir.exists():
        print(f"Missing {manifests_dir}", file=sys.stderr)
        sys.exit(1)

    # Upload store.json to root
    upload_file(store_json, "store.json", "application/json")

    # Upload all plist files under manifests/
    for plist in sorted(manifests_dir.glob("*.plist")):
        upload_file(plist, f"manifests/{plist.name}", "application/xml")

    print("\nUpload complete!")
    print(f"Public URL: https://pub-0fc82a9a07484a8d934259115aa51517.r2.dev/store.json")


if __name__ == "__main__":
    main()
