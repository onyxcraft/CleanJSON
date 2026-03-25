# Changelog

All notable changes to CleanJSON will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-25

### Added
- Initial release of CleanJSON for macOS 14+
- JSON formatting and beautification with configurable indentation (2/4 spaces, tabs)
- JSON minification
- Real-time syntax validation with detailed error messages and line numbers
- Tree view with collapsible JSON structure visualization
- Search functionality to find keys and values within JSON
- JSON path display for selected nodes
- Copy formatted/minified JSON to clipboard
- JSON file comparison with diff highlighting
- JSON to YAML conversion and preview
- Dark mode support
- Menu bar integration with keyboard shortcuts
- File open/save support for .json files
- Paste JSON directly from clipboard
- Settings panel for customization
- App sandbox security
- MVVM architecture with SwiftUI
- No external dependencies

### Features
1. **Editor View**
   - Monospaced font for better readability
   - Syntax validation indicator
   - Format/minify buttons
   - Configurable indentation
   - Search within JSON
   - YAML preview toggle

2. **Tree View**
   - Hierarchical JSON structure display
   - Expand/collapse nodes
   - Node type indicators
   - Path display for selected nodes
   - Copy path to clipboard

3. **Compare View**
   - Side-by-side JSON comparison
   - Added/removed/modified indicators
   - Color-coded diff display
   - Support for comparing files

4. **Menu Commands**
   - File operations (New, Open, Save)
   - Format operations (Format, Minify, Validate)
   - View switching (Tree, Compare, YAML)
   - Keyboard shortcuts for all major functions

5. **Settings**
   - Default indent style preference
   - Auto-format on paste option
   - Validate on paste option

### Technical Details
- Bundle ID: com.lopodragon.cleanjson
- Minimum macOS: 14.0
- Architecture: SwiftUI + AppKit, MVVM pattern
- Zero external dependencies
- Sandboxed for App Store compliance

[1.0.0]: https://github.com/lopodragon/cleanjson/releases/tag/v1.0.0
