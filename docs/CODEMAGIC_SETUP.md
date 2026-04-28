# Codemagic iOS TestFlight Setup

## 1) Apple prerequisites (already required once)

- Apple Developer Identifier (App ID): `com.pth.chamcong`
- App Store Connect app record created with bundle ID `com.pth.chamcong`
- Team ID: `SFB7XGV2NZ`
- App Store Connect API Key (`.p8`) with role `App Manager`
- APNs Auth Key (`.p8`) uploaded to Firebase iOS app (for `firebase_messaging`)

## 2) Connect repository in Codemagic

1. Go to Codemagic and add app from your Git provider.
2. Select repository `phamtronghai/chamcongmobile`.
3. Ensure workflow file is `codemagic.yaml` at repo root.

## 3) Configure App Store Connect integration

In Codemagic Team settings:

1. Open `Integrations` -> `App Store Connect`.
2. Add key with:
   - Issuer ID
   - Key ID
   - Private key content (full text from `.p8`)
3. Save integration.

The workflow uses:

```yaml
publishing:
  app_store_connect:
    auth: integration
```

## 4) Build and upload

1. Start workflow `ios-testflight`.
2. Codemagic will:
   - fetch signing files for `com.pth.chamcong`
   - build IPA
   - upload to TestFlight
3. Wait Apple processing (usually 10-30 minutes).
4. Add internal testers in App Store Connect -> TestFlight.

## 5) Important notes

- `ios/Runner/GoogleService-Info.plist` must belong to iOS app with bundle ID `com.pth.chamcong`.
- `lib/firebase_options.dart` should be regenerated after Firebase iOS app update:
  - run `flutterfire configure`
- Do not commit `.p8` key files into repository.
