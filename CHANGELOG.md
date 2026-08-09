# Changelog

All notable changes to the sl (Steam Locomotive) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.0.0] - 2026-08-09 — The Sea Update

### Added
- Four vessels join the roster via `-t`: `galleon` (three-masted pirate
  ship with a flapping Jolly Roger, animated pennants, rigging, gunports,
  and a rubber-duck figurehead), `steamer` (sternwheeler whose paddle
  wheel turns on the same 4-frame machinery as the locomotive wheels,
  with churn that streams aft), `sloop` (racing yacht for narrow
  terminals), and `tug` (drawn in three-quarter perspective — it travels
  diagonally on the angle its art implies, so it appears to grow as it
  approaches the viewer)
- Animated sea for side-view vessels: a drifting swell pattern on the
  surface, deterministic glints below, hull bob on a slow sine, bow
  spray, and stern wake (three new particle kinds: spray, wake, bubble)
- `-d`/`--dolphin` — on special request, a dolphin dives ahead of the
  ship along its drawn angle, cut cleanly at the waterline, with splash.
  Requesting a dolphin with a train books sea passage instead
- At sea, `-a` finds an iceberg: crunch, shudder, bubbles, and a
  dignified descent below the waterline. The iceberg wins
- At sea, `-F` is the Flying Dutchman: the ship climbs out of the water
  trailing stardust while the sea stays below
- Per-vessel whistles for `-w`: the steamer HOOOONKs, the tug TOOOOTs,
  the galleon goes YARRR!, the sloop rings its little bell
- Per-vessel liveries (white sails, red hulls, brass fittings), honored
  in surprise mode too
- Surprise mode: about 1 typo in 3 is now nautical; dolphins accompany
  1 in 5 sea voyages
- CODE_OF_CONDUCT.md (Contributor Covenant 2.1), fixing the broken link in
  CONTRIBUTING.md
- `--speed` help text now documents the 0.1–20 clamp

### Changed
- `-n`/`--cars` is rail-only; coal cars do not float and the count is
  ignored at sea (documented in `--help`)
- `-t`/`--type` now fully overrides `-l`: it no longer inherits the two
  implicit coal cars (`-l` alone still couples them)

### Fixed
- Trailing smoke now lingers and dissipates after the train exits, instead
  of being cut off the moment the last car leaves the screen
- In accident mode on terminals narrower than the train, the crash now
  happens at the left edge instead of off-screen
- `make demo` labeled its first run "Classic Train" but ran surprise mode;
  it now runs `./sl -t classic`
- LICENSE copyright year updated to 2024-2026

### Notes
- Tug and dolphin artwork adapted from reference pieces contributed by
  the project author

## [3.1.0] - 2026-07-06

### Added
- Surprise mode: a bare `sl` (the classic mistyped `ls`) now randomizes the
  whole show each run — train type, coal-car count, color livery (named
  themes plus fully random one-offs), and speed, with an occasional whistle
  (25%), a rare flight (10%), and a very rare crash (5%)

### Changed
- Any command-line flag disables surprise mode entirely; explicit options
  remain fully deterministic and backward compatible

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