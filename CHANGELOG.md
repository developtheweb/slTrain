# Changelog

All notable changes to the sl (Steam Locomotive) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Professional project documentation (CONTRIBUTING.md, etc.)
- Enhanced README with badges and comprehensive information
- Links to [StevenMilanese.com](https://stevenmilanese.com) throughout documentation

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