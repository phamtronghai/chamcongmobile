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

1. Open **Teams** → **Integrations** → **Developer Portal** (Apple Developer Portal integration).
2. Connect and add your App Store Connect API key. Note the **API key name** you entered — this label is what Codemagic expects in `codemagic.yaml`.
3. Issuer ID, Key ID, and `.p8` private key content are configured in that integration UI.

Then edit **[codemagic.yaml](../codemagic.yaml)** at the top of workflow `ios-testflight`:

```yaml
integrations:
  app_store_connect: YOUR_ASC_API_KEY_NAME
```

Replace `YOUR_ASC_API_KEY_NAME` with the **exact same string** as the API key name in Codemagic (validation error `"integration" requires workflow -> integrations -> app_store_connect` means this block was missing or the name did not match).

The workflow publishes with:

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
