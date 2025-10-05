# Repository Guidelines

## Project Structure & Module Organization
- `GlowWatt/`: Main iOS app (SwiftUI). UI in `Views/`, logic in `Managers/`, assets in `Assets.xcassets`, app entry `GlowWattApp.swift`.
- `GlowWattWidget/`: Widget and Live Activities code (`Widgets/`, `LiveActivities/`).
- `GlowWattWatchOS Watch App/` and `GlowWattWatchOSWidget/`: watchOS app and widget targets.
- `Shared/`: Cross‑target modules (`API/`, `LiveActivities/`, `Storage/`). Start here for shared models/utilities.
- Config: per‑target `Info.plist`, icons and colorsets under each target’s assets.

## Build, Test, and Development Commands
- Open in Xcode: `open GlowWatt.xcodeproj` (preferred for day‑to‑day dev).
- List schemes: `xcodebuild -list`.
- Build app (simulator): `xcodebuild -scheme GlowWatt -destination 'platform=iOS Simulator,name=iPhone 15' build`.
- Run tests (if present): `xcodebuild test -scheme GlowWatt -destination 'platform=iOS Simulator,name=iPhone 15'`.
- Widgets/watchOS: swap `-scheme` to `GlowWattWidget` or watchOS targets as needed.

## Coding Style & Naming Conventions
- Swift 5, SwiftUI. Indent 4 spaces, 120‑col soft wrap.
- Types: PascalCase (`PriceManager`), methods/vars: camelCase (`fetchComEdPrice`).
- Views end with `View` and live under `Views/...` (e.g., `Home/PriceView.swift`).
- Managers end with `Manager` and live under `Managers/`.
- Keep platform‑agnostic code in `Shared/`. Avoid UIKit in shared code unless guarded.

## Testing Guidelines
- Framework: XCTest (add `Tests/` per target when introducing tests).
- Name tests `ThingTests.swift`; one test class per unit under test.
- Aim for coverage of Managers and API boundaries; snapshot/UI tests optional.
- Run via Xcode or `xcodebuild test` (see above).

## Commit & Pull Request Guidelines
- Commits: present tense, scoped summaries (e.g., `PriceManager: fix rate parsing`).
- Prefer small, focused commits; reference issues like `#123` when relevant.
- PRs: clear description, before/after screenshots for UI, steps to test, affected targets (app/widget/watchOS), and any migration notes.

## Security & Configuration Tips
- Network calls live in `Shared/API/`. Do not hardcode secrets; use build configs if needed.
- Validate external responses and handle failures gracefully in Managers.
