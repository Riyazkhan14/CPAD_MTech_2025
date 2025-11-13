# task_manager_b4a

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Task Manager (Back4App / Parse + Flutter)

A small Flutter task manager app that uses Parse Server (Back4App) for backend storage and authentication via the `parse_server_sdk_flutter` package.

This README describes how to set up, run, and troubleshoot the project, with a focus on the authentication/login flow.

## Tech stack

- Flutter (Dart)
- parse_server_sdk_flutter (Parse Server client for Flutter)
- Back4App / Parse Server (hosted)
- flutter_dotenv for environment variables
- Riverpod (light usage for current user provider)

## Quick start (macOS)

Prerequisites:
- Flutter SDK installed and on PATH
- Xcode / Android Studio (for iOS / Android emulators and build tools)
- A device/emulator connected or available

1. Install dependencies

```zsh
cd /Users/riyaz/Documents/CPAD/task_manager_b4a # Add actual Directory where application folder is placed.
flutter pub get
```

2. Ensure environment variables are available

This project expects a `.env` file in the project root with these keys:

- PARSE_APP_ID
- PARSE_CLIENT_KEY (optional depending on your Back4App settings)
- PARSE_SERVER_URL

An example `.env` is already present in the repo root. I have shared the project, so removing credentials and replace with placeholders. I will Share this file separately with other Projects Files.

3. Run the app

```zsh
flutter run
# or for verbose logs
flutter run -v
```

4. Run tests

```zsh
flutter test
```

## Project layout (key files)

- `lib/main.dart` — app entrypoint; loads `.env` and calls `initParse()` before running the app.
- `lib/core/parse_init.dart` — initializes Parse with environment variables.
- `lib/core/providers.dart` — Riverpod provider(s) (e.g., `currentUserProvider`).
- `lib/features/auth/presentation/login_page.dart` — login/signup/reset UI and logic. (Contains debug logging to help diagnose login failures.)
- `lib/features/auth/data/auth_repo.dart` — small repository wrapper for login/signup/logout.
- `lib/features/tasks/...` — task model, repository and UI for the main app.

## Auth contract (what the app expects)

- Sign up: `ParseUser(email, password, email)` — username is set to the email.
- Login: the app constructs `ParseUser(username, password, username)` where username is the email.
- Logout: `ParseUser.currentUser()` + `logout()`.

Success criteria: when a login completes, the app pushes `/tasks` route and a `ParseUser.currentUser()` will return a ParseUser with a session token.

## Troubleshooting login issues

If signup works but login does not, check these common causes:

1. Environment variables
   - Confirm `.env` is present and contains `PARSE_APP_ID` and `PARSE_SERVER_URL`.
2. Username mismatch
   - Signup uses the email as the username. Login also needs to pass the same username field. The project already uses the same shape (username=email) for both signup and login.
3. Inspect console logs
   - The login page now prints richer debug messages on the console. Look for one of these lines when you attempt to login:
     - `Login success for: <username>, session: <token>`
     - `Login failed: code=<code> message=<message>`
     - `Login exception: <exception>`
   - Use `flutter run -v` to see verbose logs. These messages help identify errors such as invalid credentials, unverified email, missing permissions, or server misconfiguration.
4. Network / Server
   - Ensure your device/emulator has network access and the `PARSE_SERVER_URL` is reachable.
5. Back4App / Parse settings
   - If you are using Back4App, check the app's security and authentication settings (email verification, client key requirements, REST/API keys).

If you paste the exact console debug output (the `code` and `message` printed by the app), I can help interpret the Parse error and propose a fix.

## Developer notes & next steps

- `lib/features/auth/presentation/login_page.dart` was updated to use the same `username` parameter as signup and to add `debugPrint` lines and a `try/catch` around the login call to surface server errors.
- Consider centralizing all auth calls through `AuthRepo` so UI code is thin and error handling/logging is consistent.
- Add small unit tests around `AuthRepo` by mocking Parse responses.

## How to contribute

1. Fork the repo.
2. Make changes and run `flutter test`.
3. Open a PR with a description of the change and any test coverage.

## Contact / help

If you get an error during login, copy the debug output printed in the console and open an issue or paste it here; I'll help diagnose it.

