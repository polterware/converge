#!/bin/bash

# Script para obter a versão atual do app

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_FILE="$PROJECT_ROOT/pomodoro.xcodeproj/project.pbxproj"

VERSION=$(grep -A 1 "MARKETING_VERSION" "$PROJECT_FILE" | grep -o '[0-9]\+\.[0-9]\+' | head -1)
BUILD=$(grep -A 1 "CURRENT_PROJECT_VERSION" "$PROJECT_FILE" | grep -o '[0-9]\+' | head -1)

echo "$VERSION"
if [[ "$1" == "--build" ]]; then
    echo "Build: $BUILD"
fi
