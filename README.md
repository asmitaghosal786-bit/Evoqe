# EVOQE

EVOQE is a Flutter fashion and beauty app for discovering products, building
looks, and trying styles virtually. The app connects to the EVOQE Python
backend for Shopify catalog, Gemini AI, and YouCam integrations; Supabase
handles user authentication.

## Project links

- **Backend repository:** [View the backend code](https://github.com/Sam74012/Evoqe_backend)
- **YouTube demo video:** [View demo](https://youtu.be/4FwTfLOy-cE?si=EPxT-b3Ks4iWWMWA)
- **Presentation:** [View the slides](https://drive.google.com/file/d/18o2OD2pqh5nK4Y_kLMEL61QopqPrxuLJ/view?usp=sharing)


## Features

- Email and password sign-up, login, and password reset with Supabase Auth.
- A personalized onboarding flow with style preferences and a digital style
  profile.
- A Shopify-backed product discovery catalog with categories, filters,
  product details, variants, and price information.
- A styling assistant that recommends products from the synced catalog.
- Lookbook analysis from a selected inspiration image, written description,
  or both.
- Fashion, jewelry, and makeup try-on flows using profile photos captured
  during onboarding.
- A digital closet, saved looks, and a single-store shopping bag.
- Shopify-hosted checkout; payment details and orders are handled by Shopify,
  not by this app.

## Architecture

- **Flutter app:** UI, navigation, onboarding, local profile data, encrypted
  profile photos, and calls to the API.
- **EVOQE backend:** FastAPI service that connects to Shopify Admin and
  Storefront APIs, Gemini, and YouCam. See the [backend repository](https://github.com/Sam74012/evoqe_backend)
  for server setup and endpoint documentation.
- **Supabase:** email/password authentication and session management.
- **On-device storage:** profile data and photos are stored locally. Photos
  are encrypted in app-private storage and sent to the backend only when the
  user starts a try-on flow.

The Flutter app must not contain Shopify Admin credentials, Gemini or YouCam
keys, or the backend admin token. It uses only the Supabase public anon/
publishable key.

## Requirements

- Flutter SDK with Dart 3.13.2 or newer, as specified by `pubspec.yaml`.
- Android Studio or Xcode and a configured simulator/emulator, or a connected
  device.
- A running EVOQE backend. Follow its README to configure Shopify, Supabase,
  Gemini, and YouCam as needed.
- A Supabase project with email/password authentication enabled.

## Configure and run

From this repository root, install dependencies:

```shell
flutter pub get
```

Start the backend and configure Supabase as described in the
[backend README](https://github.com/Sam74012/evoqe_backend#readme). Then run
the app with compile-time configuration:

```shell
flutter run `
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 `
  --dart-define=SHOPIFY_STORE_DOMAIN=your-store.myshopify.com `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

Configuration values:

| Define | Description |
| --- | --- |
| `API_BASE_URL` | Backend base URL. Defaults to `http://10.0.2.2:8000` for an Android emulator reaching a backend on the host machine. |
| `SHOPIFY_STORE_DOMAIN` | Default Shopify store domain, such as `your-store.myshopify.com`. |
| `SUPABASE_URL` | Supabase project URL. |
| `SUPABASE_ANON_KEY` | Supabase public anon/publishable key. Never use a service-role key in the app. |

Use `http://127.0.0.1:8000` or `http://localhost:8000` as appropriate for an
iOS simulator. For a physical device, use the development computer's LAN IP
address and ensure the device can reach it. Use an HTTPS backend URL for
release builds; local HTTP is for development only.

### Supabase email confirmation

The current demo signup flow expects Supabase to return a session immediately.
In the Supabase Dashboard, disable email confirmation under
**Authentication → Sign In / Providers → Email** (the menu labels can vary).
Email addresses will not be verified in this mode. Re-enable confirmation and
configure reliable email delivery before production. Add
`com.example.evoqe://auth-callback` to the allowed redirect URLs for password
reset.

### Provider and service configuration

The app itself only needs the four `--dart-define` values above. Configure
Shopify, Gemini, YouCam, database, and backend Supabase credentials on the
server, not in this Flutter repository. Some screens require the corresponding
provider integrations and catalog data to be configured and available on the
backend.

The backend enforces a 10 MiB limit for YouCam images. When using a
`*.vercel.app` API URL, the Flutter client limits the total image request to
4 MiB and resizes selected images to help stay within hosting request limits.

## Authentication and privacy notes

- Supabase manages account credentials and authentication sessions.
- The app stores the session in platform secure storage.
- Profile data is encrypted before it is stored in the local database.
- Captured profile photos are encrypted in app-private storage and are not
  uploaded at sign-up.
- Try-on sends a selected profile photo to the backend after the user starts
  the feature. The backend forwards it to YouCam and does not intentionally
  retain it in the application database or durable object storage.
- Review current Supabase and YouCam policies, retention periods, and consent
  requirements before distributing the app.

## Tests and analysis

Run the Flutter tests and static analysis from the repository root:

```shell
flutter test
flutter analyze
```

## Repository layout

```text
lib/
  data/       Local profile storage, encryption, and secure media storage
  models/     App, catalog, and profile data models
  screens/    App screens and user flows
  services/   Authentication, backend API, navigation, and cart services
  state/      Shared application state
  widgets/    Reusable UI components
test/         Flutter widget and model tests
```

## Known scope

- The cart is held in app memory and supports items from one Shopify store at
  a time.
- Checkout opens Shopify's hosted checkout page. The app does not collect card
  details or implement order history.
- Product prices are returned by the backend in the store's currency. The
  current app UI is designed around USD-formatted prices; configure demo
  stores accordingly.
- AI output and try-on availability depend on provider credentials, quotas,
  product data, and the YouCam capabilities enabled for the account.
