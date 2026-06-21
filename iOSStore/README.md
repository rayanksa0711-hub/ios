# iOS Store

A native iOS client for distributing signed `.ipa` apps and games from a Cloudflare R2 bucket with Over-The-Air (OTA) installation.

## Features

- **Native SwiftUI design** matching Apple Human Interface Guidelines.
- **Bottom tab bar** with blur / frosted-glass background.
- **Squircle cards**, SF Pro typography, automatic Dark Mode.
- **Arabic & English** localization with RTL support.
- **Cloudflare R2** catalog integration.
- **OTA install** via `itms-services://` and `manifest.plist`.
- Tabs: Home, Games, Apps, Updates/Profile.

## Requirements

- macOS with Xcode 14+
- iOS 16.0+ deployment target
- Apple ID for free 7-day signing (testing) or paid Apple Developer account

## Project Structure

```
iOSStore/
├── iOSStore/
│   ├── iOSStoreApp.swift          # App entry point
│   ├── Models/
│   │   └── StoreItem.swift        # Data model
│   ├── Services/
│   │   ├── R2Service.swift        # R2 JSON catalog fetcher
│   │   └── OTAInstallService.swift# OTA manifest + install
│   ├── ViewModels/
│   │   └── StoreViewModel.swift   # Shared catalog state
│   ├── Views/
│   │   ├── MainTabView.swift      # Tab controller
│   │   ├── HomeView.swift         # Featured + categories
│   │   ├── GamesView.swift        # Games list
│   │   ├── AppsView.swift         # Apps list
│   │   ├── ProfileView.swift      # Stats + notes
│   │   ├── AppDetailView.swift    # App details + Install
│   │   ├── StoreItemCard.swift    # List card
│   │   └── BlurTabBar.swift       # Frosted tab bar style
│   ├── Resources/
│   │   └── LaunchScreen.storyboard
│   ├── Assets.xcassets/
│   ├── Info.plist
│   ├── en.lproj/Localizable.strings
│   └── ar.lproj/Localizable.strings
├── iOSStore.xcodeproj/             # Pre-built Xcode project
├── project.yml                     # XcodeGen spec (alternative)
└── store.example.json              # Example R2 catalog
```

## Open the Project

### Option A: Use the included Xcode project

1. Open `iOSStore.xcodeproj` in Xcode.
2. Select your development team in **Signing & Capabilities**.
3. Update `PRODUCT_BUNDLE_IDENTIFIER` if needed.
4. Build and run on a connected iPhone.

### Option B: Generate with XcodeGen (recommended)

If the included project has issues, install [XcodeGen](https://github.com/yonaskolb/XcodeGen) and run:

```bash
cd iOSStore
xcodegen generate
```

This regenerates a clean `iOSStore.xcodeproj` from `project.yml`.

### Option C: Create manually

1. In Xcode choose **File → New → Project → iOS App**.
2. Name it **iOSStore**, set interface to **SwiftUI**.
3. Drag all files from `iOSStore/` into the new project.
4. Copy `Info.plist` values, especially `R2_PUBLIC_URL`.

## Configure Cloudflare R2

1. Upload your signed `.ipa` files and `.png` icons to the R2 bucket `ios-store`.
2. Make the bucket publicly accessible or use an R2 public URL.
3. Upload `store.json` to the root of the public bucket.
4. Set your public URL in one of these places:
   - `iOSStore/Info.plist` → `R2_PUBLIC_URL`
   - `project.yml` → `R2_PUBLIC_URL`

Example `store.json`:

```json
{
  "items": [
    {
      "id": "com.example.mygame",
      "name": "My Awesome Game",
      "developer": "Example Studio",
      "category": "game",
      "description": "Short description",
      "icon_url": "https://pub-....r2.dev/icons/mygame.png",
      "ipa_url": "https://pub-....r2.dev/ipas/mygame.ipa",
      "bundle_id": "com.example.mygame",
      "version": "1.2.0",
      "size_bytes": 67108864,
      "screenshots": [],
      "telegram_description": "Full description from Telegram"
    }
  ]
}
```

## OTA Install Flow

The app opens an `itms-services://` URL pointing to a `manifest.plist`:

```
itms-services://?action=download-manifest&url=https://pub-....r2.dev/manifests/com.example.mygame.plist
```

For this to work:

1. The `.ipa` must be signed with a valid certificate.
2. The `manifest.plist` must be served over **HTTPS** with a valid certificate.
3. The device must trust the signing certificate.

### Generating manifest.plist

The app includes `OTAInstallService.generateManifestPlist(for:)`. You can either:

- Pre-generate manifests with the helper and upload them to `R2/manifests/<bundle_id>.plist`.
- Serve manifests dynamically from a backend endpoint.

Example manifest:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key><string>software-package</string>
                    <key>url</key><string>https://pub-....r2.dev/ipas/mygame.ipa</string>
                </dict>
                <dict>
                    <key>kind</key><string>display-image</string>
                    <key>url</key><string>https://pub-....r2.dev/icons/mygame.png</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key><string>com.example.mygame</string>
                <key>bundle-version</key><string>1.2.0</string>
                <key>kind</key><string>software</string>
                <key>title</key><string>My Awesome Game</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
```

## Testing & Signing

### Free Apple ID (7-day certificate)

For initial testing:

1. Connect your iPhone to a Mac.
2. In Xcode, select your iPhone as the run destination.
3. Go to **Signing & Capabilities**, choose **Automatically manage signing**, and select your personal Apple ID team.
4. Build and run. The app installs directly from Xcode.

### Sideloadly (sideloading without Xcode)

If you already have a signed `.ipa` of this store app:

1. Download [Sideloadly](https://sideloadly.io/).
2. Connect your iPhone via USB.
3. Drag the `.ipa` into Sideloadly and enter your Apple ID.
4. Install. Re-sign every 7 days if using a free account.

### Paid Developer Account

For production distribution without re-signing every week:

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/).
2. Use a Distribution certificate and Ad Hoc or Enterprise provisioning profile.
3. Re-sign the `.ipa` with the paid certificate before uploading to R2.

## Design & Brand Colors

The app uses a premium dark theme inspired by the provided screenshots.

Official brand colors (editable in `iOSStore/Views/Theme.swift`):

| Color | Hex | Usage |
|---|---|---|
| Midnight Navy | `#002855` | Backgrounds, frames, UI elements |
| Muted Gold | `#BD9648` | Buttons, glow, tags, accents |
| Pure White | `#FFFFFF` | Primary text |

## Custom Background Image

The app supports a custom background image across all tabs.

1. Add your image to:
   ```
   iOSStore/Assets.xcassets/Background.imageset/background.png
   ```
2. Make sure `Background.imageset/Contents.json` references `background.png`.
3. The background is automatically applied to Home, Games, Apps, and Profile screens.

## Build IPA with GitHub Actions (No Mac required)

A ready-to-use workflow is included in `.github/workflows/build-ipa.yml`. It runs on a GitHub macOS runner and produces a signed IPA automatically.

### Required GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Description |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | Your `.p12` certificate encoded as base64 |
| `P12_PASSWORD` | Password for the `.p12` certificate |
| `BUILD_PROVISION_PROFILE_BASE64` | Your `.mobileprovision` profile encoded as base64 |
| `KEYCHAIN_PASSWORD` | Any random password for the temporary keychain |
| `CODE_SIGN_IDENTITY` | e.g. `iPhone Distribution: Your Name (TEAM_ID)` |
| `PROVISIONING_PROFILE_SPECIFIER` | Name of your provisioning profile |
| `R2_PUBLIC_URL` | Your public R2 URL (optional) |

### Encode certificate and profile

On a Mac:

```bash
base64 -i Certificates.p12 -o cert.txt
base64 -i Profile.mobileprovision -o prov.txt
```

Paste the contents of `cert.txt` and `prov.txt` into the GitHub secrets.

### Update exportOptions.plist

Edit `scripts/exportOptions.plist`:

- Replace `YOUR_TEAM_ID` with your Apple Team ID.
- Replace `com.yourcompany.iosstore` with your bundle ID.
- Replace `YOUR_PROVISIONING_PROFILE_NAME` with your provisioning profile name.

### Trigger the build

Push to `main` or go to **Actions → Build iOS IPA → Run workflow**.

When finished, download `iOSStore.ipa` from the workflow artifacts.

## Important Notes

- OTA install only works on physical devices; the simulator does not support `itms-services://`.
- Free Apple ID signing expires every 7 days and limits the number of app IDs.
- HTTPS is mandatory for both the manifest and the `.ipa`.
- This project is intended for distributing your own signed apps, not for bypassing App Store review.

## License

Internal use only.
