# Hybrid Cross-Platform Game Platform

## Summary

Use a single PlayPal mobile app with a lightweight shared shell, while each game remains independently owned in code and backend infrastructure.

For smooth iOS and Android gameplay, ship all approved game code with the app release, but initialize only the selected game at runtime. The app downloads only the selected game’s remote assets, session data, chat connection, and live state after the player presses Launch.

```text
Installed with app release
├── PlayPal shell: login, lobby, inbox, friendships
├── Shared contracts and game SDK
└── Game Flutter code and required compatible native libraries

Loaded only when a game is launched
├── Game API configuration
├── CDN assets / maps / media
├── Match session and live game state
├── Realtime chat connection
└── Local cache for that selected game
```

Do not attempt to install new Flutter/Dart packages after a user taps a game. iOS rules prohibit downloading or executing code that adds functionality after App Store review. Android supports deferred components, but Flutter supports them only for Android/web and still requires uploading one complete Android App Bundle. [Apple guideline 2.5.2](https://developer.apple.com/app-store/review/guidelines/uk/), [Flutter deferred components](https://docs.flutter.dev/perf/deferred-components)

## App and Package Configuration

```text
apps/mobile_shell/
    Firebase login, game catalogue, launch routing, inbox, friendships.

packages/platform_contracts/
    Pure Dart models and versioned interfaces shared by shell and games.

packages/game_sdk/
    Game registration, authenticated launch context, result-link handler.

games/<game-id>/
    flutter_client/      Game UI, compatible Flutter dependencies
    game_engine/         Rules and local state
    backend/             Authoritative game API/realtime server
    infra/<provider>/    Database, secrets, deployment, monitoring
    contracts/           Game-specific API and event schemas
    test/
```

Use an Android App Bundle for Google Play and a normal reviewed IPA for iOS. Start with all games bundled for consistent behavior. Later, use Android-only deferred components only for asset-heavy games whose download size proves problematic—not for the first release.

Each game’s Flutter package may use different libraries, but all packages must remain version-compatible in the final mobile build. If a future game requires conflicting native or Flutter SDK versions, isolate it as a separate app/module rather than compromising the shared shell.

## Backend and Database Configuration

```text
Firebase/GCP Platform
├── Firebase Authentication: one global platformUserId
├── Firestore: profiles, friendships, direct messages, inbox, blocks
├── Platform Catalogue API: game status and active-player counts
├── Result Notification API: creates inbox links only
├── Push notifications, reports, device tokens
└── Shared game registry and feature flags

Game Provider / Database
├── Own cloud account/project and secrets
├── Own match state, matchmaking, results, leaderboards
├── Own temporary in-match chat and moderation data
├── Own realtime API / WebSocket service
└── Own game assets, analytics, and game logs
```

The platform stores no match scores or leaderboard copies. A game owns its full result and leaderboard; on completion it sends a trusted event that creates an inbox item linking to `/game/<gameId>/result/<matchId>`.

Game cards call only `GET /catalogue` from the platform. Each game backend sends signed availability and active-player metrics to the platform, avoiding direct mobile calls to multiple providers.

## Runtime and Security Flow

```text
Launch game
Mobile shell → Firebase ID token → selected game backend
Game backend validates token → creates/joins match → opens game chat
Game completes → saves result in its database
Game backend → signed notification event → Platform inbox
Player opens inbox link → game-owned result / leaderboard screen
```

- Every game validates the Firebase ID token and receives the same `platformUserId`; Firebase supports verification in custom backends through its Admin SDK or standard JWT validation. [Firebase token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens)
- Games use server-authoritative validation for moves, winners, scores, and matchmaking. The client never writes authoritative result or leaderboard data.
- Match chat is game-owned, restricted to current match participants, and expires after 30 days. Reported messages are retained only within that game’s moderation process.
- Firebase owns direct messages and inbox only. Firestore client access is protected with Firebase Auth, App Check, and restrictive Security Rules; authoritative platform writes use server IAM. [Firestore security guidance](https://firebase.google.com/docs/firestore/security/get-started)
- Platform-to-game and game-to-platform calls use dedicated signed server credentials, secret rotation, idempotency keys, and no cross-database access.
- User deletion, blocks, and abuse reports originate centrally; each game receives a signed request and removes or anonymizes its own records.

## Test Plan

- Verify first launch, repeat launch, offline asset/cache behavior, and game exit cleanup on Android and iOS.
- Contract-test token validation, game launch configuration, catalogue status updates, and result-notification events.
- Verify that replayed match-completion events create one inbox item only.
- Verify game isolation: a game credential cannot read another game’s database or platform social data.
- Verify Firestore rules for inbox, direct-message membership, friendships, blocks, and report visibility.
- Load-test each game backend independently for matchmaking, WebSocket sessions, chat, and leaderboard reads.
- Configure per-provider budget alerts, error logs, uptime checks, and development/staging/production environments.

Assumptions: Firebase/GCP is the shared platform; each game owns its own cloud/database; full results and leaderboards stay game-owned; platform retains only inbox links; all game code ships in the iOS release and initial Android release; Android-only deferred delivery is a future optimization for large modules/assets.
