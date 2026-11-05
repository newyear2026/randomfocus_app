# Trying Pro locally

The Android one-time purchase implementation and verification server are in
place. Live Google Play sales still require the setup and live checks in
[GOOGLE_PLAY_BILLING.md](GOOGLE_PLAY_BILLING.md). This debug preview is for duration
weights, named presets and the ad-free timer. It does not test real payments or
restoration. App Store billing remains unconfigured.

From this repository, start a **debug** build with an explicit preview define:

```sh
/Users/jaewook/development/flutter/bin/flutter devices
/Users/jaewook/development/flutter/bin/flutter run --debug --no-pub -d DEVICE_ID --dart-define=RANDOMFOCUS_PRO_PREVIEW=true
```

For an iOS simulator, open Simulator first and use its device ID. For a physical
iPhone, connect and trust the Mac, enable Developer Mode and use a configured
development signing team. The preview does not change signing settings.

A red `PRO PREVIEW` ribbon identifies this mode. Open **Settings → Times &
probabilities** to select times and save weights; open **Presets** to save,
apply, edit and delete named configurations. Try 25 / 45 / 60 minutes with
50% / 30% / 20%, then check the wheel and the ad-free timer. Restart with the
same define to check saved settings and presets.

The preview never starts ad consent or the ad SDK, and purchase/restore controls
are disabled. It uses the app's existing Firebase setup; this option does not
change telemetry settings or add any data collection.

To return to the free experience, stop the process and start a new debug run
without the define. Hot reload does not change compile-time defines. Avoid
exercising ads during this feature preview. Saved configurations stay on the
device, but no ownership flag is saved or restored. Release and profile builds
ignore the preview define because the store-selection guard requires `kDebugMode`.

Local regression checks (no live store or ads):

```sh
flutter test --no-pub
flutter test --no-pub --dart-define=RANDOMFOCUS_PRO_PREVIEW=true test/pro_preview_test.dart
dart analyze lib test
```
