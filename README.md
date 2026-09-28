# Movie App — ITI Flutter Graduation Project

A Flutter movie browsing app built on the TMDB API, with Firebase authentication
and four persistent, per-user movie lists (Favorites, Watched, Watching, Want to Watch).

## Project Overview
Users can register/login, browse Popular / Top Rated / Now Playing movies from
TMDB, search for any movie, view full details, and organize movies into four
personal lists that persist locally between app restarts.

## Features
- Email/password registration, login, logout (Firebase Authentication)
- Browse movies by category (Popular, Top Rated, Now Playing) on the Home screen
- Debounced live search (waits 500ms after typing stops before calling the API)
- Movie details screen with poster, overview, rating, release date, runtime
- Add/remove a movie from Favorites, Watched, Watching, Want to Watch
- All four lists persist locally via SQLite and are scoped per logged-in user
- Loading, error, and empty states handled on every screen

## Technologies
- Flutter & Dart
- `provider` — state management
- `http` — TMDB REST API calls
- `sqflite` — local database for the four movie lists
- `firebase_auth` / `firebase_core` — authentication
- `cached_network_image` — poster/backdrop image loading & caching

## Architecture
A simple layered architecture:
- `models/` — plain Dart classes for API and database data (`Movie`, `MovieListItem`)
- `services/` — all external I/O: `TmdbService` (network), `DBHelper` (SQLite), `AuthService` (Firebase)
- `providers/` — app state exposed to the UI via `ChangeNotifier` (`AuthProvider`, `MovieProvider`, `ListProvider`)
- `screens/` — UI only; screens read providers and call their methods, never talk to services directly
- `widgets/` — shared UI (loading/error/empty states)

This was chosen because it's simple to explain and enforces one rule: **UI never
imports `http`, `sqflite`, or `firebase_auth` directly** — it always goes
through a provider, which goes through a service.

## State Management
`provider` is used with `ChangeNotifier`:
- `AuthProvider` — current Firebase user, login/register/logout, auth-related errors
- `MovieProvider` — Home screen sections and search results, each wrapped in a
  `MovieSection` (movies + isLoading + error) reused across all lists
- `ListProvider` — the four movie lists for the logged-in user; rebuilt via
  `ChangeNotifierProxyProvider` whenever the logged-in user changes

## API (TMDB)
`TmdbService` wraps every TMDB endpoint used (`/movie/popular`, `/movie/top_rated`,
`/movie/now_playing`, `/movie/{id}`, `/search/movie`). Responses are parsed into
`Movie.fromJson` immediately — no raw JSON is passed to the UI. Network failures,
non-200 responses, and empty results are all converted into a `TmdbException`
that the UI shows as a friendly error message with a retry button.

**Setup:** get a free API key at https://www.themoviedb.org/settings/api. The key
is loaded from a local `.env` file via `flutter_dotenv` — it's never hardcoded
and never committed to GitHub (`.env` is in `.gitignore`).

## Authentication
`AuthService` wraps `firebase_auth` for register/login/logout and maps Firebase
error codes (e.g. `wrong-password`, `email-already-in-use`) to readable messages.
`AuthProvider` exposes `AuthStatus` (unknown/authenticated/unauthenticated) which
`SplashScreen` uses to route to `HomeScreen` or `LoginScreen`.

## Database
SQFLite, **one table** (`movie_list_items`) for all four lists — a `listType`
column (`favorite` / `watched` / `watching` / `wantToWatch`) distinguishes them,
and a `userId` column scopes rows to the logged-in user. This avoids duplicating
near-identical tables and DAO code four times.
Supported operations: insert/replace (add to list), delete (remove from list),
query by list+user (view a list), query by movie+list+user (check current status
for the Details screen toggle buttons).

## Project Structure
```
lib/
  models/        Movie, MovieListItem + ListType enum
  services/      TmdbService, DBHelper, AuthService
  providers/     AuthProvider, MovieProvider, ListProvider
  screens/       Splash, Login, Register, Home, Details, Search, MyLists
  widgets/       LoadingView, ErrorView, EmptyView
  main.dart      Firebase init + Provider tree + routing
```

## Setup Instructions
1. Install Flutter SDK and run `flutter pub get` in the project root.
2. Create a Firebase project, enable **Email/Password** sign-in under Authentication.
3. Run `flutterfire configure` (or add `google-services.json` / `GoogleService-Info.plist` manually) to connect Firebase to this app.
4. Get a TMDB API key from https://www.themoviedb.org/settings/api.
5. put tmdb api key in `.env` file.
6. Run `flutter run`.

## Screenshots
screenshots in seperated folder with name screenshot

## Known Limitations
- Only one poster/backdrop image size is used (no responsive image sizing).
- Search does not support pagination (only the first page of results is shown).
- No password-reset flow (only register/login/logout are implemented, as required).
