#!/bin/bash

# Release script for Converge macOS app
# This script builds the app, creates a DMG, signs it, and publishes to GitHub

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="converge"
SCHEME_NAME="converge"
APP_NAME="Converge"
RELEASES_DIR="$PROJECT_DIR/releases"
KEYS_DIR="$PROJECT_DIR/keys"
APPCAST_FILE="$PROJECT_DIR/appcast.xml"

# GitHub configuration
GITHUB_REPO="rckbrcls/converge"  # Update this if your repo is different
GITHUB_ORG="rckbrcls"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v xcodebuild &> /dev/null; then
        log_error "xcodebuild not found. Please install Xcode."
        exit 1
    fi
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not found. Please install it: brew install gh"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI not authenticated. Please run: gh auth login"
        exit 1
    fi
    
    if [ ! -f "$KEYS_DIR/eddsa_private_key.pem" ]; then
        log_warn "EdDSA private key not found at $KEYS_DIR/eddsa_private_key.pem"
        log_warn "DMG will not be signed. Sparkle updates may not work correctly."
        log_warn "To generate keys, run: sparkle/bin/sign_update --generate-keys"
    fi
    
    log_info "All dependencies checked ✓"
}

get_version() {
    # Get version from project.pbxproj
    MARKETING_VERSION=$(grep -A 1 "MARKETING_VERSION" "$PROJECT_DIR/converge.xcodeproj/project.pbxproj" | grep -v "MARKETING_VERSION" | head -1 | sed 's/.*= //;s/;//' | xargs)
    CURRENT_PROJECT_VERSION=$(grep -A 1 "CURRENT_PROJECT_VERSION" "$PROJECT_DIR/converge.xcodeproj/project.pbxproj" | grep -v "CURRENT_PROJECT_VERSION" | head -1 | sed 's/.*= //;s/;//' | xargs)
    
    if [ -z "$MARKETING_VERSION" ]; then
        log_error "Could not determine MARKETING_VERSION from project.pbxproj"
        exit 1
    fi
    
    VERSION="$MARKETING_VERSION"
    BUILD="$CURRENT_PROJECT_VERSION"
    
    log_info "Version: $VERSION (build $BUILD)"
}

build_app() {
    log_info "Building app..."
    
    cd "$PROJECT_DIR"
    
    # Clean build folder
    xcodebuild clean -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME_NAME" -configuration Release
    
    # Build archive
    ARCHIVE_PATH="$RELEASES_DIR/$APP_NAME.xcarchive"
    xcodebuild archive \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -allowProvisioningUpdates
    
    log_info "Archive created at $ARCHIVE_PATH"
    
    # Export app from archive
    EXPORT_PATH="$RELEASES_DIR/export"
    EXPORT_OPTIONS_PLIST="$PROJECT_DIR/scripts/ExportOptions.plist"
    
    # Create ExportOptions.plist if it doesn't exist
    if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
        log_warn "ExportOptions.plist not found. Creating default..."
        create_export_options "$EXPORT_OPTIONS_PLIST"
    fi
    
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath "$EXPORT_PATH" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
        -allowProvisioningUpdates
    
    APP_PATH="$EXPORT_PATH/$APP_NAME.app"
    
    if [ ! -d "$APP_PATH" ]; then
        log_error "App not found at $APP_PATH"
        exit 1
    fi
    
    log_info "App exported to $APP_PATH"
    echo "$APP_PATH"
}

create_export_options() {
    local plist_path="$1"
    cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF
}

create_dmg() {
    local app_path="$1"
    local dmg_name="${APP_NAME}-${VERSION}.dmg"
    local dmg_path="$RELEASES_DIR/$dmg_name"
    
    log_info "Creating DMG: $dmg_name"
    
    # Remove old DMG if exists
    [ -f "$dmg_path" ] && rm "$dmg_path"
    
    # Create temporary directory for DMG contents
    DMG_TEMP_DIR="$RELEASES_DIR/dmg_temp"
    rm -rf "$DMG_TEMP_DIR"
    mkdir -p "$DMG_TEMP_DIR"
    
    # Copy app to temp directory
    cp -R "$app_path" "$DMG_TEMP_DIR/"
    
    # Create Applications symlink
    ln -s /Applications "$DMG_TEMP_DIR/Applications"
    
    # Create DMG
    hdiutil create -volname "$APP_NAME" \
        -srcfolder "$DMG_TEMP_DIR" \
        -ov -format UDZO \
        "$dmg_path"
    
    # Cleanup
    rm -rf "$DMG_TEMP_DIR"
    
    log_info "DMG created at $dmg_path"
    echo "$dmg_path"
}

sign_dmg() {
    local dmg_path="$1"
    
    if [ ! -f "$KEYS_DIR/eddsa_private_key.pem" ]; then
        log_warn "Skipping DMG signing (EdDSA key not found)"
        return
    fi
    
    log_info "Signing DMG with EdDSA..."
    
    # Check if Sparkle signing tool is available
    # Try to find it in common locations
    SIGN_TOOL=""
    
    # Check if Sparkle is available via SPM (in DerivedData)
    SPARKLE_TOOL=$(find ~/Library/Developer/Xcode/DerivedData -name "sign_update" -type f 2>/dev/null | head -1)
    
    if [ -n "$SPARKLE_TOOL" ]; then
        SIGN_TOOL="$SPARKLE_TOOL"
    elif command -v sign_update &> /dev/null; then
        SIGN_TOOL="sign_update"
    else
        log_warn "Sparkle sign_update tool not found. DMG will not be signed."
        log_warn "Install Sparkle tools or ensure Sparkle package is built."
        return
    fi
    
    # Sign the DMG
    if [ -n "$SIGN_TOOL" ]; then
        ED_SIGNATURE=$("$SIGN_TOOL" "$dmg_path" "$KEYS_DIR/eddsa_private_key.pem" 2>/dev/null || echo "")
        if [ -n "$ED_SIGNATURE" ]; then
            log_info "DMG signed successfully"
            echo "$ED_SIGNATURE"
        else
            log_warn "Failed to sign DMG"
        fi
    fi
}

create_github_release() {
    local dmg_path="$1"
    local ed_signature="$2"
    local tag="v${VERSION}"
    local release_notes=""
    
    log_info "Creating GitHub release: $tag"
    
    # Check if tag already exists
    if gh release view "$tag" &> /dev/null; then
        log_warn "Release $tag already exists. Updating..."
        gh release delete "$tag" --yes 2>/dev/null || true
    fi
    
    # Create release notes from CHANGELOG or use default
    if [ -f "$PROJECT_DIR/CHANGELOG.md" ]; then
        release_notes=$(awk "/## \[$VERSION\]/,/## \[/" "$PROJECT_DIR/CHANGELOG.md" | head -n -1)
    fi
    
    if [ -z "$release_notes" ]; then
        release_notes="Release $VERSION

See the [changelog](https://github.com/$GITHUB_REPO/blob/main/CHANGELOG.md) for details."
    fi
    
    # Create draft release
    gh release create "$tag" \
        "$dmg_path" \
        --title "$APP_NAME $VERSION" \
        --notes "$release_notes" \
        --repo "$GITHUB_REPO"
    
    log_info "Release created: https://github.com/$GITHUB_REPO/releases/tag/$tag"
}

update_appcast() {
    local dmg_path="$1"
    local ed_signature="$2"
    local dmg_name=$(basename "$dmg_path")
    local dmg_size=$(stat -f%z "$dmg_path" 2>/dev/null || stat -c%s "$dmg_path" 2>/dev/null)
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v${VERSION}/$dmg_name"
    
    log_info "Updating appcast.xml..."
    
    # Get current date in RFC 822 format
    local pub_date=$(date -u +"%a, %d %b %Y %H:%M:%S +0000")
    
    # Create new item XML
    local new_item=$(cat << EOF
        <item>
            <title>Version ${VERSION}</title>
            <pubDate>${pub_date}</pubDate>
            <sparkle:minimumSystemVersion>11.0</sparkle:minimumSystemVersion>
            <enclosure 
                url="${download_url}"
                sparkle:version="${VERSION}"
                sparkle:shortVersionString="${VERSION}"
                length="${dmg_size}"
                type="application/octet-stream"
                ${ed_signature:+sparkle:edSignature="${ed_signature}"}
            />
            <description><![CDATA[
# ${APP_NAME} v${VERSION}

## Release Notes

See the [changelog](https://github.com/${GITHUB_REPO}/blob/main/CHANGELOG.md) for details.

## Installation

1. Download the DMG file from the [releases page](https://github.com/${GITHUB_REPO}/releases)
2. Open the downloaded DMG file
3. Drag the ${APP_NAME} app to the Applications folder
4. Run the app for the first time

**Note**: If the app shows security warnings, right-click on the app and select "Open".
            ]]></description>
        </item>
EOF
)
    
    # Insert new item at the beginning (after <language>en</language>)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' "/<language>en<\/language>/a\\
${new_item}
" "$APPCAST_FILE"
    else
        # Linux sed
        sed -i "/<language>en<\/language>/a\\${new_item}" "$APPCAST_FILE"
    fi
    
    log_info "Appcast updated"
}

upload_appcast() {
    local tag="v${VERSION}"
    
    log_info "Uploading appcast.xml to release..."
    
    gh release upload "$tag" "$APPCAST_FILE" --repo "$GITHUB_REPO" --clobber
    
    log_info "Appcast uploaded to release"
}

main() {
    log_info "Starting release process for $APP_NAME..."
    
    # Parse arguments
    SKIP_BUILD=false
    SKIP_DMG=false
    SKIP_RELEASE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --skip-dmg)
                SKIP_DMG=true
                shift
                ;;
            --skip-release)
                SKIP_RELEASE=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Usage: $0 [--skip-build] [--skip-dmg] [--skip-release]"
                exit 1
                ;;
        esac
    done
    
    # Check dependencies
    check_dependencies
    
    # Get version
    get_version
    
    # Create releases directory
    mkdir -p "$RELEASES_DIR"
    
    # Build app
    if [ "$SKIP_BUILD" = false ]; then
        APP_PATH=$(build_app)
    else
        APP_PATH="$RELEASES_DIR/export/$APP_NAME.app"
        if [ ! -d "$APP_PATH" ]; then
            log_error "App not found at $APP_PATH. Run without --skip-build first."
            exit 1
        fi
    fi
    
    # Create DMG
    if [ "$SKIP_DMG" = false ]; then
        DMG_PATH=$(create_dmg "$APP_PATH")
        ED_SIGNATURE=$(sign_dmg "$DMG_PATH")
    else
        DMG_PATH="$RELEASES_DIR/${APP_NAME}-${VERSION}.dmg"
        if [ ! -f "$DMG_PATH" ]; then
            log_error "DMG not found at $DMG_PATH. Run without --skip-dmg first."
            exit 1
        fi
        ED_SIGNATURE=$(sign_dmg "$DMG_PATH")
    fi
    
    # Create GitHub release
    if [ "$SKIP_RELEASE" = false ]; then
        create_github_release "$DMG_PATH" "$ED_SIGNATURE"
        update_appcast "$DMG_PATH" "$ED_SIGNATURE"
        upload_appcast
    fi
    
    log_info "Release process completed successfully! 🎉"
    log_info "DMG: $DMG_PATH"
    log_info "Release: https://github.com/$GITHUB_REPO/releases/tag/v${VERSION}"
}

# Run main function
main "$@"
