# Multi-Cloud Game Platform Configuration

## Summary

Use one shared Firebase/GCP platform for identity and social features, and make every game an independent product with its own Flutter package, cloud project/account, backend, database, chat, game logic, leaderboard, and deployment pipeline.

The mobile app calls the shared platform for login, inbox, friendships, and lobby data. It never connects directly to every game provider for discovery. It launches a selected game module, which calls only that game’s backend.

```text
Flutter shell
   ├── Firebase Auth + Platform Firestore
   ├── Platform Catalogue API
   ├── Inbox / friendships / direct messages
   └── Game client package
             ↓
        Game-specific API + database + match chat + leaderboard
```

## Ownership and Data Boundaries

```text
Shared Platform: Firebase/GCP
├── Firebase Authentication
├── users, profiles, avatars, devices
├── friendships, blocks, reports
├── direct messages and inbox
├── game catalogue, availability, active-player counts
├── launch entitlements and feature flags
└── inbox notification containing a link to a completed game result

Each Game: independent provider/project/database
├── game rooms and matchmaking
├── authoritative game rules and moves
├── in-match chat
├── match records and full results
├── game-specific leaderboard
├── game assets, telemetry, and anti-cheat logs
└── game-specific notification event generation
```

The shared platform stores no copy of match scores or leaderboards. On completion, a game sends a trusted event that creates an inbox item such as: “Your Hidden Hand result is ready.” That item deep-links to the game’s own result screen.

Use `platformUserId`—the Firebase Auth UID—as the only cross-system user identifier. Games may store that ID, but must not create duplicate accounts or maintain profiles, friendships, or direct-message records.

## Integration Configuration

```text
apps/mobile_shell/
    Shared Flutter lobby, authentication, inbox, social screens.

packages/platform_contracts/
    Versioned pure-Dart contracts:
    PlatformUserId, GameId, GameLaunchConfig, GameStatus,
    ResultNotificationEvent, GameRoute.

packages/game_sdk/
    Common interface every compatible Flutter game implements:
    game metadata, launch entry point, authenticated API client,
    result deep-link handler.

games/<game-id>/
    flutter_client/     Game UI and compatible libraries
    game_engine/        Rules, state, local-only logic
    backend/            Authoritative API/realtime server
    infra/<provider>/   IaC, secrets, database, deployment
    contracts/          Versioned game API/event definitions
    test/

platform_backend/
    catalogue, friendship, inbox, notification, report, auth integrations.
```

Use a monorepo with path-based CI and `CODEOWNERS`: platform developers own shared packages; each game team owns only its game folder and cloud project. Publish shared Dart contracts as internal versioned packages.

A game with normal, compatible Flutter libraries stays a package inside the shell. Flutter still resolves one final dependency graph, so incompatible Flutter or native SDK versions cannot safely coexist in one build. If that occurs, isolate that game as a separately compiled app/module later; do not attempt to solve it merely with folders.

## Runtime Flows

```text
Login
Flutter shell → Firebase Auth → Firebase UID
                          ↓
              same bearer token sent to every game backend

Lobby activity count
Game backend → signed status update → Platform Catalogue API
Flutter shell → one catalogue request → all game tiles

Match completion
Game backend → save result in game database
Game backend → signed ResultNotificationEvent → Platform Inbox API
Platform → inbox item with gameId + matchId link
User → opens game’s own result/leaderboard screen
```

- Firebase ID tokens are validated by every game backend; Firebase supports backend verification through its Admin SDK or a standards-compliant JWT library. [Firebase ID-token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens)
- Game status updates contain only `gameId`, availability, approximate active-player count, and timestamp. The catalogue marks old updates as unavailable/stale; the app does not fan out to each cloud provider.
- Game-to-platform calls use signed server-to-server credentials stored in each game provider’s secret manager, with key rotation and an idempotency key per event.
- Match chat stays in the game database, is accessible only to active match members, and expires after 30 days by default. Reported chat is retained only by the game’s moderation process.
- A platform block prevents players from being matched or chatting together; each game checks the platform block status at match creation.
- User deletion is orchestrated by the platform: it sends a deletion request to every game, and each game erases or anonymizes its own player records and chat according to its retention policy.

Use Firestore directly from the mobile app only for platform-owned social data, with Firebase Auth, App Check, and restrictive Security Rules. Do not allow direct mobile writes to authoritative game results, leaderboards, or match state. Firebase’s official guidance confirms that mobile Firestore access is governed by Authentication and Security Rules, while server clients require IAM controls. [Firestore security guidance](https://firebase.google.com/docs/firestore/security/get-started)

## Testing and Operations

- Test Firestore rules in the Firebase Emulator: users can read only their own inbox, only conversation members can read direct messages, and friendship/block writes obey server validation.
- Contract-test every game against `platform_contracts`: token validation, launch configuration, catalogue metric reporting, and result-notification event compatibility.
- Test game isolation: a Hidden Hand credential cannot access Casefile data; game databases are never queried by the platform.
- Test event idempotency: retrying a completed-match event creates one inbox item only.
- Test failure states: expired token, unavailable game, stale player count, unavailable game API, blocked player, and result link to a deleted/expired match.
- Give every platform/game cloud project its own budget alert, usage dashboard, error logging, and environment separation. Do not depend on free tiers for production capacity: for example, Firestore’s free quota is limited to one free database per project and some features require billing. [Firestore pricing](https://cloud.google.com/firestore/pricing?authuser=451499271)

Assumptions locked for the first build: Firebase/GCP owns shared platform data; game result details and leaderboards remain game-owned; game chat is temporary and game-owned; the platform keeps only inbox links to results; the mobile shell receives live card data from one platform catalogue API; and games remain Flutter packages unless their dependencies truly conflict.
