# 00 — Project Scaffold — Design

## Tooling choice

XcodeGen (`project.yml`) is the source of truth. The `.xcodeproj` is a generated,
gitignored artifact. SPM dependencies are declared inside `project.yml`, giving us a
real `.app` bundle plus clean dependency management without hand-editing pbxproj.

## Files

```
project.yml
Makefile
.gitignore
README.md
Sources/PastaApp/Resources/pasta.entitlements
Sources/PastaApp/AppDelegate.swift            # minimal entry for scaffold (expanded in 06)
Sources/PastaEngine/Engine.swift              # placeholder marker file (replaced by real types)
```

> Note: real source files arrive with their features. Scaffold only needs enough for the
> three targets to compile: a trivial `@main` `AppDelegate` showing a status item stub,
> and one engine file so the framework target is non-empty.

## project.yml (shape)

```yaml
name: pasta
options:
  bundleIdPrefix: com.pasta
  deploymentTarget:
    macOS: "13.0"
  createIntermediateGroups: true

packages:
  KeyboardShortcuts:
    url: https://github.com/sindresorhus/KeyboardShortcuts
    from: 2.0.0

targets:
  PastaEngine:
    type: framework
    platform: macOS
    sources: [Sources/PastaEngine]
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.pasta.engine
        GENERATE_INFOPLIST_FILE: YES

  PastaApp:
    type: application
    platform: macOS
    sources: [Sources/PastaApp]
    dependencies:
      - target: PastaEngine
      - package: KeyboardShortcuts
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.pasta.app
        GENERATE_INFOPLIST_FILE: YES
        INFOPLIST_KEY_LSUIElement: YES
        INFOPLIST_KEY_NSHumanReadableCopyright: ""
        CODE_SIGN_ENTITLEMENTS: Sources/PastaApp/Resources/pasta.entitlements
        CODE_SIGN_STYLE: Automatic
        MARKETING_VERSION: "0.1.0"
        CURRENT_PROJECT_VERSION: "1"

  PastaEngineTests:
    type: bundle.unit-test
    platform: macOS
    sources: [Tests/PastaEngineTests]
    dependencies:
      - target: PastaEngine

schemes:
  PastaApp:
    build:
      targets: { PastaApp: all }
    run:
      config: Debug
  PastaEngineTests:
    build:
      targets: { PastaEngine: all, PastaEngineTests: all }
    test:
      targets: [PastaEngineTests]
```

## Makefile (shape)

```make
.PHONY: gen build test run clean
gen:   ; xcodegen generate
build: gen ; xcodebuild -project pasta.xcodeproj -scheme PastaApp -configuration Debug build
test:  gen ; xcodebuild -project pasta.xcodeproj -scheme PastaEngineTests test
run:   build ; open "$$(xcodebuild -project pasta.xcodeproj -scheme PastaApp -showBuildSettings | awk '/ BUILT_PRODUCTS_DIR /{d=$$3}/ FULL_PRODUCT_NAME /{n=$$3}END{print d"/"n}')"
clean: ; rm -rf pasta.xcodeproj .build DerivedData
```

## pasta.entitlements (shape)

MVP is unsandboxed for friction-free global hotkey, pasteboard polling, and login item.
Minimal/empty entitlements plist (no `app-sandbox` key set true):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict></dict></plist>
```

## .gitignore

```
*.xcodeproj
.build/
DerivedData/
.DS_Store
```

## Edge cases / notes

- `GENERATE_INFOPLIST_FILE: YES` means Info.plist keys are driven from build settings
  (`INFOPLIST_KEY_*`) — no standalone Info.plist to maintain.
- `Package.resolved` lives at `pasta.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`
  after first resolve; since `.xcodeproj` is gitignored, commit a copy at repo root
  (or under a tracked path) so dependency versions are pinned for reviewers. Document the
  pin location in README.
- Activation policy `.accessory` is also set in code (see feature 06) as belt-and-suspenders
  with `LSUIElement`.
