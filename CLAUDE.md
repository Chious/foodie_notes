# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter run                    # Run on connected device/emulator
flutter run -d chrome          # Run on Chrome (web)
flutter emulator --launch <name>  # Launch a specific emulator
flutter analyze                # Static analysis (uses flutter_lints)
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter pub get                # Install dependencies
```

## Project Overview

食誌 (Foodie Notes) is a diet tracking app targeting Taiwanese users. Core features: AI food recognition via photo, barcode scanning, manual food search, nutrition tracking, and body data management. Currently in **Phase 1 (UI-only)** — all data comes from `MockData` in `lib/models/mock_data.dart`, no backend or local persistence yet.

The planned architecture (see `docs/ADR/`) is: Flutter + SQLite client, Node.js server for AI recognition and food database queries, deployed on Cloudflare. Android is the primary target platform.

## Architecture

**Routing**: `go_router` with `StatefulShellRoute.indexedStack` for the main tab structure. Onboarding routes (`/welcome`, `/goal-setup`) are top-level; the 4 tab branches (`/today`, `/stats`, `/food`, `/me`) share a persistent `MainShell` scaffold; `/scanner` pushes as a full-screen modal over the shell.

**Bottom nav has 5 items but 4 branches**: The center scan button (index 2) doesn't correspond to a shell branch — it pushes `/scanner` via `context.push()`. `MainShell` handles the index mapping between the 5-item nav bar and the 4 shell branches.

**Theme**: Material 3 with Noto Sans TC (via `google_fonts`). Colors defined in `AppColors` (olive-green primary `#6B7A4F`, warm beige background `#FAF8F3`). Text styles in `AppTextStyles`.

**UI language**: Traditional Chinese (zh-TW). Labels, meal names, and navigation items are all in Chinese.

## Key Conventions

- Models are plain Dart classes with `const` constructors (no code generation)
- Screens live in `lib/screens/<feature>/` with one file per screen
- Shared widgets live in `lib/widgets/`
- ADRs documenting product decisions are in `docs/ADR/`
