#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$SCRIPT_DIR/GlowWatt.xcodeproj/project.pbxproj"

usage() {
    echo "Usage: $(basename "$0") [version] [build]"
    echo "Example: $(basename "$0") 1.28 28"
    echo
    echo "If version or build is omitted, the script will prompt for it."
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if (( $# > 2 )); then
    usage >&2
    exit 1
fi

if [[ ! -f "$PROJECT_FILE" ]]; then
    echo "Error: Xcode project not found at $PROJECT_FILE" >&2
    exit 1
fi

current_versions="$(awk '
    /^[[:space:]]*MARKETING_VERSION = [^;]+;/ {
        value = $3
        sub(/;$/, "", value)
        if (!seen[value]++) values = values (values ? ", " : "") value
    }
    END { print values }
' "$PROJECT_FILE")"

current_builds="$(awk '
    /^[[:space:]]*CURRENT_PROJECT_VERSION = [^;]+;/ {
        value = $3
        sub(/;$/, "", value)
        if (!seen[value]++) values = values (values ? ", " : "") value
    }
    END { print values }
' "$PROJECT_FILE")"

echo "Current project values:"
echo "  Version: ${current_versions:-not set}"
echo "  Build:   ${current_builds:-not set}"
echo

version="${1:-}"
build="${2:-}"

if [[ -z "$version" ]]; then
    read -r -p "Version number (for example, 1.28): " version
fi

if [[ -z "$build" ]]; then
    read -r -p "Build number (for example, 28): " build
fi

# CFBundleShortVersionString supports one to three dot-separated integers.
if [[ ! "$version" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
    echo "Error: version must contain one to three numbers separated by dots (for example, 1.28 or 1.28.1)." >&2
    exit 1
fi

# Keep build numbers simple and App Store friendly.
if [[ ! "$build" =~ ^[0-9]+$ ]]; then
    echo "Error: build must be a non-negative whole number (for example, 28)." >&2
    exit 1
fi

version_setting_count="$(grep -Ec '^[[:space:]]*MARKETING_VERSION = [^;]+;' "$PROJECT_FILE" || true)"
build_setting_count="$(grep -Ec '^[[:space:]]*CURRENT_PROJECT_VERSION = [^;]+;' "$PROJECT_FILE" || true)"

if (( version_setting_count == 0 || build_setting_count == 0 )); then
    echo "Error: could not find both version settings in the Xcode project." >&2
    exit 1
fi

temporary_file="$(mktemp "${TMPDIR:-/tmp}/glowatt-version.XXXXXX")"
trap 'rm -f "$temporary_file"' EXIT

awk -v version="$version" -v build="$build" '
    /^[[:space:]]*MARKETING_VERSION = [^;]+;/ {
        sub(/MARKETING_VERSION = [^;]+;/, "MARKETING_VERSION = " version ";")
    }
    /^[[:space:]]*CURRENT_PROJECT_VERSION = [^;]+;/ {
        sub(/CURRENT_PROJECT_VERSION = [^;]+;/, "CURRENT_PROJECT_VERSION = " build ";")
    }
    { print }
' "$PROJECT_FILE" > "$temporary_file"

if ! plutil -lint "$temporary_file" >/dev/null; then
    echo "Error: the updated Xcode project did not pass validation; no changes were made." >&2
    exit 1
fi

cp "$temporary_file" "$PROJECT_FILE"

echo "Updated all target build configurations:"
echo "  Version: $version ($version_setting_count settings)"
echo "  Build:   $build ($build_setting_count settings)"
