#!/bin/bash
set -e

# Script completo de release
# Uso: ./scripts/release.sh [patch|minor|major] [--skip-version] [--skip-git]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INCREMENT_TYPE="${1:-patch}"
SKIP_VERSION=false
SKIP_GIT=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --skip-version)
            SKIP_VERSION=true
            ;;
        --skip-git)
            SKIP_GIT=true
            ;;
    esac
done

echo "==> Starting release process..."

# 1. Incrementar versão (se não pular)
if [[ "$SKIP_VERSION" == false ]]; then
    echo "==> Incrementing version ($INCREMENT_TYPE)..."
    "$SCRIPT_DIR/increment-version.sh" "$INCREMENT_TYPE"
else
    echo "==> Skipping version increment"
fi

# 2. Obter versão atual
CURRENT_VERSION=$(grep -A 1 "MARKETING_VERSION" "$PROJECT_ROOT/pomodoro.xcodeproj/project.pbxproj" | grep -o '[0-9]\+\.[0-9]\+' | head -1)
CURRENT_BUILD=$(grep -A 1 "CURRENT_PROJECT_VERSION" "$PROJECT_ROOT/pomodoro.xcodeproj/project.pbxproj" | grep -o '[0-9]\+' | head -1)

echo "==> Building version $CURRENT_VERSION (build $CURRENT_BUILD)..."

# 3. Criar DMG
echo "==> Creating DMG..."
"$SCRIPT_DIR/create-dmg.sh" "$CURRENT_VERSION"

DMG_PATH="$PROJECT_ROOT/build/Pomodoro-${CURRENT_VERSION}.dmg"

if [[ ! -f "$DMG_PATH" ]]; then
    echo "Error: DMG not created at $DMG_PATH"
    exit 1
fi

echo "==> DMG created: $DMG_PATH"

# 3.5. Gerar appcast (se URL_BASE estiver configurada)
if [[ -n "$APPCAST_URL_BASE" ]]; then
    echo "==> Generating appcast..."
    "$SCRIPT_DIR/generate-appcast.sh" "$APPCAST_URL_BASE" "$DMG_PATH"
    echo "==> Appcast generated in releases/appcast.xml"
    echo "==> Don't forget to upload the DMG and appcast.xml to your server!"
else
    echo "==> To generate appcast, set APPCAST_URL_BASE environment variable:"
    echo "    export APPCAST_URL_BASE=https://seu-dominio.com/releases"
    echo "    $0 $INCREMENT_TYPE"
fi

# 4. Git operations (se não pular e se git estiver disponível)
if [[ "$SKIP_GIT" == false ]] && command -v git &> /dev/null; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "==> Git operations..."
        
        # Verificar se há mudanças não commitadas
        if [[ -n $(git status --porcelain) ]]; then
            echo "==> Staging changes..."
            git add pomodoro.xcodeproj/project.pbxproj
            git commit -m "Bump version to $CURRENT_VERSION (build $CURRENT_BUILD)"
        fi
        
        # Criar tag
        TAG="v${CURRENT_VERSION}"
        if git rev-parse "$TAG" >/dev/null 2>&1; then
            echo "Warning: Tag $TAG already exists. Skipping tag creation."
        else
            echo "==> Creating tag $TAG..."
            git tag -a "$TAG" -m "Release $CURRENT_VERSION (build $CURRENT_BUILD)"
            echo "==> Tag created: $TAG"
            echo "==> To push tags: git push origin $TAG"
        fi
    else
        echo "==> Not a git repository, skipping git operations"
    fi
else
    echo "==> Skipping git operations"
fi

echo ""
echo "==> Release complete!"
echo "==> DMG: $DMG_PATH"
echo "==> Version: $CURRENT_VERSION (build $CURRENT_BUILD)"
