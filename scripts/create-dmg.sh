#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEME="pomodoro"
APP_NAME="pomodoro"
BUILD_DIR="$PROJECT_ROOT/build"
DMG_NAME="Pomodoro"
VERSION="${1:-1.0}"

echo "==> Building $APP_NAME (Release)..."
cd "$PROJECT_ROOT"
xcodebuild -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  clean build

APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Release/$APP_NAME.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: App not found at $APP_PATH"
  exit 1
fi

DMG_DIR="$BUILD_DIR/dmg"
DMG_TEMP="$DMG_DIR/temp"
DMG_OUT="$BUILD_DIR/${DMG_NAME}-${VERSION}.dmg"

rm -rf "$DMG_DIR"
mkdir -p "$DMG_TEMP"

echo "==> Preparing DMG contents..."
cp -R "$APP_PATH" "$DMG_TEMP/"
ln -s /Applications "$DMG_TEMP/Applications"

echo "==> Creating DMG..."
hdiutil create -volname "$DMG_NAME" \
  -srcfolder "$DMG_TEMP" \
  -ov -format UDZO \
  "$DMG_OUT"

rm -rf "$DMG_DIR"
echo "==> Done: $DMG_OUT"
