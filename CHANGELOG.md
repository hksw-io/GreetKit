# Changelog

All notable changes to GreetKit are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **Breaking.** The primary button is now the system prominent glass button
  (`.buttonStyle(.glassProminent)`) instead of a hand-drawn pill. `GreetStyle.tint` colors it, and
  the platform supplies the pressed, hovered, focused, disabled, and Increase Contrast treatments
  it previously faked. On macOS the button now reacts to the pointer and takes a focus ring.

### Removed

- **Breaking.** `GreetStyle.primaryButtonProgressTint`. The in-button progress view now inherits a
  legible color from the button style, so the previous hardcoded `.white` fallback is gone.
  `primaryButtonForegroundColor` remains as an opt-in override of the label color.

## [1.0.0] - 2026-07-24

First tagged release. Everything before this tag was consumed from the `master` branch.

### Added

- `GreetView` — the welcome sheet, with three initializers: a plain sheet, a single
  `primaryDestination`, and a `primaryRouteDestination` chain with `onPrimaryRoutesComplete`.
- `GreetContent` — the content protocol, with defaults for `appIcon`, `subtitle`, `primaryRoutes`,
  `primaryRouteNextButtonText`, `primaryRouteDoneButtonText`, `primaryButtonLoadingAccessibilityValue`,
  and `skipButtonText`.
- `GreetFeatureItem` and `GreetPrimaryRoute` — content models keyed by a stable `id`.
- `GreetBackground` — `.system`, `.softGradient`, `.linearGradient`, `.animatedGradient`, and `.custom`,
  applied with `greetBackground(_:)`.
- `GreetGradientPalette` and `GreetGradientMotion` for tuning the gradient backgrounds.
- `GreetStyle` — foreground and tint roles, applied with `greetStyle(_:)`.
- `primaryButtonLoadingAccessibilityValue` on `GreetContent`, so the VoiceOver value announced while
  the primary button is loading comes from the app instead of a hardcoded English string.
- GitHub Actions CI running the macOS build, the test suite, and an iOS build.

### Fixed

- The skip button now hit-tests across its full 44pt minimum control height. Previously only the text
  glyphs were tappable, so the reserved height below the label did nothing.
- The route chain no longer keys its transition animation off a route that is not on screen. Because
  `primaryRoutes` is a computed property, a route could disappear while it was open and leave the view
  showing the overview while the animation phase still named the missing route.

### Changed

- Route navigation state moved into an internal `GreetRouteState` value type, covered by unit tests.
- The primary button and the responsive horizontal padding are each defined once and shared by the
  overview footer and the route destinations.
- Replaced two soft-deprecated SwiftUI calls: `ScrollView(_:showsIndicators:)` (the
  `scrollIndicators(_:axes:)` modifier was already applied) and `Color(_ color: UIColor)`.
- `GreetStyle`, `GreetGradientPalette`, `GreetBackgroundContext`, `GreetFeatureItem`, and
  `GreetPrimaryRoute` are now `Sendable`. `GreetBackground` is not, because `.custom` stores a closure
  returning `AnyView`, which SwiftUI declares as `~Sendable`.

### Removed

- The two ID-less `GreetFeatureItem` initializers. They generated a fresh `UUID().uuidString` on every
  evaluation, which defeats SwiftUI's diffing for a `features` array built in a computed property. Pass
  a stable `id:` instead.
- `GreetBackground.animatedMesh(primary:secondary:accent:)`. Use
  `animatedGradient(brand:palette:motion:)` instead.

  Both were already marked deprecated and are removed here rather than after 1.0.0, since no tagged
  release ever shipped them.

[unreleased]: https://github.com/hksw-io/GreetKit/compare/1.0.0...HEAD
[1.0.0]: https://github.com/hksw-io/GreetKit/releases/tag/1.0.0
