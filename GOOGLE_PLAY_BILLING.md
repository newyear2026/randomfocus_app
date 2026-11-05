# RandomFocus Pro — Google Play one-time purchase

## Product

- Package: `com.randomfocus.app`
- Product ID: `randomfocus_pro_lifetime`
- Type: one-time, non-consumable purchase; never consume the transaction
- Approved launch price: **USD 2.99**; other regions use Play's localized prices
- Title: `RandomFocus Pro`
- Description: `Unlock ad-free focus, custom timer durations and probabilities, and saved focus presets with a one-time purchase.`
- Quantity: one. Do not enable multi-quantity, rental, subscription, or repeat purchase.
- Benefits: remove banner/interstitial ads, customize focus durations/weights, save/apply presets.
- Free timer and basic history remain available.

## Current delivery state

Newest signed Android artifact: **1.4.1 (27)**,
`build/releases/randomfocus-1.4.1-27.aab` (54,576,733 bytes), built 2026-10-25.
SHA-256: `40e6a5c49024674868babf05045c5add4c306b32d8096625d925301ef9c05ca5`;
full record in `build/releases/randomfocus-1.4.1-27.verification.json`
(billing permission present, certificate matches the previous release,
bundletool validation passed, not debuggable, production ad unit IDs).
The earlier `randomfocus-1.4.1-26.aab` is superseded; neither has been uploaded.

**This artifact is stale: do not upload it.** Source has advanced past the
2026-10-25 build (Korean locale, upright wheel labels, the interstitial/ad
lifecycle rework, focus session recording). Bump the version code and rebuild
before any upload. D-Day recovery backs up the unreadable local value before a
confirmed reset; landscape/large-text timers preserve a square dial and usable
controls.

The dedicated runtime account and the required cloud APIs are configured.
The user explicitly approved and the agent applied these build-account roles
on 2026-10-24 for `96665827051-compute@developer.gserviceaccount.com`:
source bucket `gcf-v2-sources-96665827051-us-central1` object viewer,
`gcf-artifacts` repository writer, and project log writer. Other bindings were
preserved. The runtime account retains Play access to RandomFocus only.

The verification function was built and reached ACTIVE state. This project
rejects `allUsers` IAM bindings under domain-restricted sharing. Mobile HTTPS
access uses Cloud Run's service-specific `invokerIamDisabled: true` setting on
`verifyrandomfocuspro`; the project organization policy was not changed.
The source uses `invoker: private` to avoid the rejected allUsers binding;
operators must verify the service-specific public setting after deployments.
See Google's supported configuration:
https://cloud.google.com/run/docs/authenticating/public

Current Play Console still requires a billing-enabled bundle upload before
product registration. No product, AAB upload, production rollout, or paid/test
purchase was completed by the agent. Chrome's file chooser integration is
blocked by the extension's file-URL permission; the internal-test draft is
left ready for a manual upload. Use the latest AAB above, then register and
activate `randomfocus_pro_lifetime` at USD 2.99.

**Pro sales are not live yet.** Endpoint readiness must be `ready: true` after
catalog setup, followed by a license-tester purchase and restoration check.
The server readiness response distinguishes a missing product from denied
catalog access, while Google/network outages remain unavailable errors.
The latest server source has 16 passing tests. The deployed endpoint was checked
on 2026-10-24: GET returned HTTP 200 with `ready: false` and
`reason: product-not-configured`; malformed purchase requests returned HTTP 400,
and unsupported methods returned HTTP 405. No real receipt was submitted.
Rechecked 2026-11-04: GET still returns HTTP 200 with `ready: false` and
`reason: product-not-configured`. Because the server reports a missing product
rather than `catalog-access-denied`, the runtime account's Play access and the
`RANDOMFOCUS_BILLING_ENABLED` flag are both in place; only steps 4 and 5 below
(upload and product registration) remain.

An optional seven-day Artifact Registry cleanup-policy change was rejected by
automatic approval review because artifact deletion was outside the approved
scope. No retention policy was changed; this housekeeping is not required for
purchase verification.

## Console registration values

Upload a freshly built, billing-enabled AAB to the internal-test draft first
(the stored artifacts predate the current source — see Current delivery state),
then open Monetize with Play → Products → One-time products.

| Field | Value |
| --- | --- |
| Product ID | `randomfocus_pro_lifetime` (must match exactly) |
| Default language | English (United States), `en-US` |
| Name | `RandomFocus Pro` |
| Description | `Unlock ad-free focus, custom timer durations and probabilities, and saved focus presets with a one-time purchase.` |
| Purchase option | Buy, permanent access; not rental |
| Purchase option ID, if requested | `lifetime` |
| US price | USD 2.99, one-time payment |
| Multi-quantity | Disabled |

Check regional prices and availability, then save and activate the buy option.
Non-consumable behavior is implemented in the app/server by acknowledging the
purchase without consuming it; some Console forms do not expose a separate
consumable/non-consumable selector. Product registration alone does not activate
checkout: backend deployment and a successful readiness check are still required.

## Setup and remaining activation steps

1. In project `cs-project-nuszgcho`, create the runtime service account
   `randomfocus-billing@cs-project-nuszgcho.iam.gserviceaccount.com`.
   Do not create/download a private-key JSON file or embed credentials in Flutter.
2. Enable `cloudfunctions.googleapis.com`, `cloudbuild.googleapis.com`,
   `artifactregistry.googleapis.com`, `run.googleapis.com`, and
   `androidpublisher.googleapis.com` for this project.
3. Invite that service account in Play Console → Users and permissions, with
   access to **RandomFocus only**, not every app. Google documents these billing
   permissions: **View financial data, orders, and cancellation survey responses**
   and **Manage orders and subscriptions**. Also allow viewing this app's product
   catalog if required by the console. Do not grant production-release or
   account-administration privileges.
4. Rebuild the signed, billing-enabled AAB from current source with a fresh
   version code, then upload it to an internal-test draft. Complete the normal
   test-track setup as needed. This is not a production rollout.
5. Create and activate the product above and its buy purchase option in
   RandomFocus → Monetize with Play → Products → One-time products. Use USD 2.99
   as the base price and check regional availability/localized prices.
6. Create untracked `functions/.env.cs-project-nuszgcho` containing:

   ```dotenv
   RANDOMFOCUS_BILLING_ENABLED=true
   ```

   Default behavior is false: new purchases stay disabled until this is enabled
   **and** Google's catalog API succeeds. Existing purchases can still verify
   when new sales are disabled.
7. From the repository root:

   ```sh
   npm --prefix functions ci --ignore-scripts
   firebase deploy --project cs-project-nuszgcho --only functions:randomfocus-billing
   ```

   This deploys only the dedicated codebase. The function is public over HTTPS,
   checks every purchase token against Google Play, and runs as the dedicated
   service account. It uses at most three 256 MiB instances with zero minimum
   instances; invocations/builds/storage can incur Google Cloud charges.
8. Confirm the readiness response:

   ```sh
   curl --fail --silent --show-error https://us-central1-cs-project-nuszgcho.cloudfunctions.net/verifyRandomFocusPro
   ```

   It must return `ready: true`, `packageName: com.randomfocus.app`, and
   `productId: randomfocus_pro_lifetime`. A flag alone is insufficient: this GET
   also confirms the runtime identity can read the product in Google's catalog.

The approved build-service-account permissions are for
`96665827051-compute@developer.gserviceaccount.com`:
`roles/storage.objectViewer` on source bucket
`gcf-v2-sources-96665827051-us-central1`, `roles/artifactregistry.writer` on
repository `projects/cs-project-nuszgcho/locations/us-central1/repositories/gcf-artifacts`,
and `roles/logging.logWriter` on project `cs-project-nuszgcho`.
Preserve existing IAM bindings and etags when applying an approved change.

## Purchase behavior and security

- Flutter uses `in_app_purchase` and `buyNonConsumable`; prices come from Play.
- The purchase stream is observed before querying existing purchases.
- Only the allowlisted product with a `google_play` receipt can enter verification.
- Only an HTTPS server response for this package/product, with state `purchased`
  and confirmed Google acknowledgment, can grant Pro.
- Pending/canceled/error/invalid purchases cannot unlock Pro or be acknowledged.
- The server checks Google's purchase/consumption state and acknowledges a paid
  non-consumable without consuming it. Already acknowledged restores are idempotent.
- Checkout is disabled when backend readiness or product lookup fails. A missing
  product catalog entry does not prevent an existing valid purchase restoring.
- Purchases are restored automatically on startup and checked on resume, including
  pending transactions completed outside the app and revoked/refunded purchases.
- Temporary network errors preserve Pro already verified in the running session.
  On a cold offline start, verification needs connectivity; a local ownership
  boolean is deliberately not trusted. The free timer/history still open, and
  ads stay blocked while ownership is unknown. Retry restore after reconnecting.
- There is no app login or cross-store entitlement. Ownership follows the Google
  Play purchasing account. A new device/reinstall must use that same Play account.
- Purchase tokens are confidential bearer receipts. They are sent in the HTTPS
  POST body, never in URLs/logs/analytics, and are not stored by this backend.
  No payment-card data is processed by the app or function. The repository
  policy files (`PRIVACY_POLICY.md`, `PRIVACY_POLICY_EN.md`,
  `PRIVACY_POLICY_KO.md`) carry the purchase-verification disclosure as of
  2026-11-04. **The published policy document still has to be replaced with that
  text before selling** — as of 2026-11-04 the live URL still served the
  January 2025 version, which claims no data leaves the device and does not
  mention purchases, Firebase Analytics, or Crashlytics.
- The Firebase project is shared with other apps; use the isolated codebase and
  runtime account, and never replace its other functions, rules, or app settings.

## Verification

Local checks do not charge money:

```sh
flutter analyze --no-pub lib test
flutter test --no-pub
flutter test --no-pub --dart-define=RANDOMFOCUS_PRO_PREVIEW=true test/pro_preview_test.dart
npm --prefix functions test
flutter build appbundle --release --no-pub
```

After cloud/product activation, use a Play **license tester** and install from the
internal-test track. Confirm the purchase sheet displays a test payment method,
the correct one-time product and localized price before completing it. Verify:

1. Successful test purchase unlocks Pro and stops all ads.
2. Cancel/error/slow test payment never grants Pro prematurely.
3. Reinstall/another Android device restores with the same Play account.
4. Pending payment completed outside the app unlocks on return.
5. Refund **with revoke** removes access on the next successful refresh.
6. Server outage prevents new checkout and preserves an already verified session.

Live test purchase, live restoration, and production rollout are not verified by
the unit tests and require the activated backend/product and tester device.

Local validation on 2026-11-04: all 261 Flutter tests and 16 server verification
tests passed; `flutter analyze` reported issues only under the
`output/store-screenshots/` snapshot directory, none in `lib` or `test`.
Earlier validation on 2026-10-24: 208 Flutter tests and 16 server tests passed; app/test static analysis and server syntax checks passed. The
signed release AAB was built and its manifest, ZIP, and certificate checked.
Android's Kotlin plugin was updated to 2.3.21 because the installed advertising
SDK uses Kotlin 2.3 metadata. AGP 8.13.2 includes the compatible R8 8.13.19;
Gradle 8.14 and the new compiler-options DSL keep this toolchain compatible
while preserving JVM target 11. Versioned AAB copies live under `build/releases/`
so Flutter cannot accidentally select an old named bundle in its output folder.

## Official references

- https://pub.dev/packages/in_app_purchase
- https://developer.android.com/google/play/billing/integrate
- https://developer.android.com/google/play/billing/security
- https://developers.google.com/android-publisher/getting_started
- https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.products/get
- https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.products/acknowledge
- https://developers.google.com/android-publisher/api-ref/rest/v3/monetization.onetimeproducts/get
- https://developer.android.com/build/releases/agp-8-13-0-release-notes
- https://kotlinlang.org/docs/gradle-configure-project.html
