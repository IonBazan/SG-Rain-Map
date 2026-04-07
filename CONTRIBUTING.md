# Contributing to SG Rain Map

Thank you for taking the time to contribute!

## Reporting bugs

Please open a GitHub Issue and include:
- macOS version
- Steps to reproduce
- What you expected vs. what happened
- Console output from Xcode if relevant (crash logs, network errors)

## Suggesting features

Open an Issue with the `enhancement` label. Describe the use-case clearly — "I want to do X so that Y" is more useful than just describing the feature.

## Submitting a pull request

1. Fork the repository and create a branch from `main`:
   ```bash
   git checkout -b feature/my-feature
   ```
2. Make your changes. Keep each PR focused on a single concern.
3. Ensure the app builds cleanly (`⌘B`) with no warnings on the latest Xcode.
4. Test on at least macOS 14 (Sonoma).
5. Open the PR with a clear description of what changed and why.

## Code style

- Swift 6, SwiftUI, native Apple frameworks only — no third-party dependencies.
- Use `@Observable` for view models, `actor` for services.
- Add `// MARK:` comments to separate logical sections.
- Prefer clarity over cleverness.

## Data & privacy rules

- The app must remain free of analytics, tracking, or remote logging of any kind.
- Network access is limited to `weather.gov.sg` radar images only.
- Location data must never leave the device.
