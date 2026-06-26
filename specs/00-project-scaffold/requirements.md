# 00 — Project Scaffold — Requirements

## Overview

Stand up a buildable, runnable macOS agent app skeleton using XcodeGen, so all
subsequent features have a project to compile into. Authoring happens on Linux; the
project is generated and built on a Mac.

## User stories

- **US-1.** As a developer on Linux, I want the Xcode project defined as text
  (`project.yml`) so I can author it without Xcode and avoid binary `.xcodeproj` churn.
- **US-2.** As a developer on a Mac, I want one command each to generate, build, test,
  and run the app, so the round-trip is fast and unambiguous.
- **US-3.** As a user, I want the app to run as a menu-bar agent with no Dock icon.

## Acceptance criteria (EARS)

- **00-AC-1.** THE SYSTEM SHALL define the Xcode project in a text `project.yml`
  consumed by XcodeGen; the generated `.xcodeproj` SHALL be gitignored.
- **00-AC-2.** THE SYSTEM SHALL declare three targets: `LatchEngine` (framework),
  `LatchApp` (application, depends on `LatchEngine`), and `LatchEngineTests` (unit-test
  bundle for `LatchEngine`).
- **00-AC-3.** THE SYSTEM SHALL set the deployment target to macOS 13.0 for all targets.
- **00-AC-4.** THE SYSTEM SHALL configure `LatchApp` as an agent app via
  `INFOPLIST_KEY_LSUIElement = YES` so no Dock icon appears.
- **00-AC-5.** THE SYSTEM SHALL declare the `KeyboardShortcuts` SPM dependency
  (`https://github.com/sindresorhus/KeyboardShortcuts`, from 2.0.0) on `LatchApp` and
  commit a pinned `Package.resolved`.
- **00-AC-6.** THE SYSTEM SHALL reference an entitlements file
  (`Sources/LatchApp/Resources/Latch.entitlements`); the MVP build SHALL be
  unsandboxed (no `com.apple.security.app-sandbox` true).
- **00-AC-7.** THE SYSTEM SHALL provide a `Makefile` with `gen`, `build`, `test`, and
  `run` targets that wrap `xcodegen` and `xcodebuild`/`open`.
- **00-AC-8.** WHEN `make gen && make build` runs on a Mac with XcodeGen installed,
  THE SYSTEM SHALL produce a `LatchApp.app` bundle that launches and shows no Dock icon.
- **00-AC-9.** THE SYSTEM SHALL provide a `.gitignore` excluding `*.xcodeproj`,
  `.build/`, `DerivedData/`, and `.DS_Store`.
- **00-AC-10.** THE SYSTEM SHALL provide a `README.md` documenting the Mac build steps
  and noting the repo is private (no license).

## Out of scope

- Code signing for distribution (handled at release time; unsigned dev build is fine).
- App Store / notarization configuration.
- App icon artwork (a placeholder SF Symbol is acceptable for MVP).
