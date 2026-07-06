# Changelog

All notable changes to the sl (Steam Locomotive) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0] - 2026-07-06

### Added
- Flicker-free double-buffered renderer on the alternate screen — the frame
  is composed off-screen and emitted as a single write, and your previous
  terminal contents are restored when the train has passed
- Animated wheels with a 4-frame rotation cycle on every train type
- Particle-based smoke that drifts behind the train and dissipates, with
  grayscale shading on 256-color terminals
- Coal cars (`-n`/`--cars`, up to 8), adapted from Toyoda Masashi's original sl
- Train type selection flag (`-t`/`--type`: classic, small, d51, c51)
- Whistle (`-w`/`--whistle`) — the train toots as it passes
- Rebuilt accident mode: screen shake, spark shower, and smoldering wreck
- Rebuilt flying mode: smoothstep climb with stardust trail
- Static train output when stdout is not a terminal, so `sl | cat` prints
  a train instead of escape codes
- Color control: `--no-color` flag, `NO_COLOR` environment variable honored
- Monotonic frame pacing (animation speed no longer drifts with render time)
- Speed clamping (0.1–20.0) so `-s 0` can no longer hang the animation
- Professional project documentation (CONTRIBUTING.md, etc.)
- Enhanced README with badges and comprehensive information
- Links to [StevenMilanese.com](https://stevenmilanese.com) throughout documentation

### Changed
- `-l`/`--long` now couples two coal cars behind the D51, making the long
  train actually long
- Terminal resize is applied at the next frame instead of mid-draw
- SIGWINCH handler is only registered on platforms that have it (Windows
  compatibility)

### Fixed
- Full-screen clear per frame caused visible flicker; replaced by the
  double-buffered renderer
- Character-by-character color replacement could corrupt output when the
  train was clipped at the screen edge
- Escape codes were written even when stdout was a pipe or file
- Flying mode drifted downward instead of flying
- Degenerate terminal sizes (0×0 pseudo-terminals) now fall back to 80×24

## [2.0.0] - 2024-06-05

### Added
- Complete rewrite as a standalone Python script
- Multiple train types (Classic, D51, C51)
- Flying mode (`-F` flag)
- Accident mode (`-a` flag)
- Speed control (`-s` option)
- Colorful ASCII art with ANSI escape sequences
- Dynamic smoke generation
- Terminal resize handling (SIGWINCH)
- Graceful interrupt handling (SIGINT)
- Comprehensive help system
- No external dependencies (pure Python)

### Changed
- Migrated from simple script to professional command-line tool
- Improved animation smoothness
- Better terminal compatibility

### Removed
- Dependency on colorama (now uses built-in ANSI codes)

## [1.0.0] - 2024-06-01

### Added
- Initial release
- Basic train animation
- Simple colorful output using colorama
- Right-to-left animation

---

*For more information, visit [StevenMilanese.com](https://stevenmilanese.com)*