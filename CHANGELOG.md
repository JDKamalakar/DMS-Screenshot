# Changelog

All notable changes to the **DMS Screenshot** plugin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.7.0] - 2026-10-12

### Added
- **Focused Window Capture (`window`)**:
  - Direct support for capturing the focused application window (`dms screenshot window`) on compatible Wayland compositors (Hyprland, Mango, niri).
- **Scrolling Capture (`scroll`)**:
  - Interactive continuous scrolling capture (`dms screenshot scroll`) that stitches content as you scroll downward or upward.
- **Scroll Capture Cadence (`--interval`)**:
  - Customizable capture interval from `30ms` to `1000ms` (default: `45ms`) with a dedicated slider setting in the settings page and a numeric configuration field in the quick widget settings form.
- **Specific Output Monitor Capture (`output` / `-o`)**:
  - Capture a specific monitor display output by name (e.g. `DP-1`, `HDMI-A-1`) with an interactive configuration field.
- **Grid Layout for Screenshot Modes**:
  - Modern segmented pill capture mode selector reorganized into a clean 2-row (3×2) grid layout:
    - **Row 1**: Interactive Region, Focused Window, Scrolling Capture
    - **Row 2**: Focused Screen, All Screens, Specific Output

### Changed
- **Segmented UI Settings**:
  - Redesigned and integrated modern segmented settings cards with smooth Shape-based corner animations, pill transitions, and interactive ripples adapted from `DMS-ScreenCapture_Toolbar`.
- **Plugin Manifest Version**:
  - Bumped version in `plugin.json` to `1.7.0`.

### Removed
- **Repeat Last Mode**:
  - Removed deprecated `last` (Repeat Last Region) option from both the settings UI and quick widget capture menu.

---

## [1.5.3] - 2026-05-10

### Fixed
- Removed `dms` CLI dependency requirement from plugin manifest.

---

## [1.5.2] - 2026-05-09

### Changed
- Removed unused `GraphicalEffects` imports to improve loading performance on Qt 6 / Quickshell.

---

## [1.5.0] - 2026-05-08

### Added
- Strftime date and time template expansion (`%Y`, `%m`, `%d`, `%H`, `%M`, `%S`) for filenames and custom directory paths.
- Capture shutter countdown delay (Off, 3s, 5s, 10s) before firing for non-interactive modes.
- Output format selector (PNG, JPEG, PPM) with custom JPEG quality compression control (1–100%).
- Stdout pipe mode integration with custom editor command support (e.g., `swappy -f -`).
