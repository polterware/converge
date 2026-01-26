#!/bin/bash
set -e

# Script para fazer upload do DMG para GitHub Releases
# Uso: ./scripts/upload-to-github.sh [DMG_PATH] [--draft] [--prerelease]
# Requer: GitHub CLI (gh) instalado e autenticado

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verificar se GitHub CLI está instalado
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Verificar se está autenticado
if ! gh auth status &> /dev/null; then
    echo "Error: GitHub CLI is not authenticated."
    echo "Run: gh auth login"
    exit 1
fi

# Obter repositório remoto
REPO=$(git remote get-url origin 2>/dev/null | sed -E 's/.*github.com[:/]([^/]+\/[^/]+)(\.git)?$/\1/' || echo "")
if [[ -z "$REPO" ]]; then
    echo "Error: Could not determine GitHub repository."
    echo "Make sure you're in a git repository with a GitHub remote."
    exit 1
fi

# Caminho do DMG (se não fornecido, usa o mais recente)
DMG_PATH="${1:-}"

if [[ -z "$DMG_PATH" ]]; then
    # Encontrar o DMG mais recente
    DMG_PATH=$(ls -t "$PROJECT_ROOT/build"/Pomodoro-*.dmg 2>/dev/null | head -1)
fi

if [[ ! -f "$DMG_PATH" ]]; then
    echo "Error: DMG not found at $DMG_PATH"
    echo "Usage: $0 [DMG_PATH] [--draft] [--prerelease]"
    exit 1
fi

# Extrair versão do nome do arquivo
DMG_NAME=$(basename "$DMG_PATH")
VERSION=$(echo "$DMG_NAME" | sed -E 's/Pomodoro-([0-9]+\.[0-9]+)\.dmg/\1/')

if [[ -z "$VERSION" ]]; then
    echo "Error: Could not extract version from $DMG_NAME"
    exit 1
fi

TAG="v${VERSION}"
DMG_FILENAME=$(basename "$DMG_PATH")

# Parse flags
IS_DRAFT=false
IS_PRERELEASE=false

for arg in "$@"; do
    case $arg in
        --draft)
            IS_DRAFT=true
            ;;
        --prerelease)
            IS_PRERELEASE=true
            ;;
    esac
done

echo "==> Uploading DMG to GitHub Releases..."
echo "==> Repository: $REPO"
echo "==> Tag: $TAG"
echo "==> DMG: $DMG_PATH"

# Verificar se a tag existe
if ! git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Warning: Tag $TAG does not exist locally."
    echo "Creating release will create the tag automatically."
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Verificar se release já existe
if gh release view "$TAG" --repo "$REPO" &>/dev/null; then
    echo "==> Release $TAG already exists. Uploading asset..."
    gh release upload "$TAG" "$DMG_PATH" --repo "$REPO" --clobber
    echo ""
    echo "==> Upload complete!"
    echo "==> Download URL: https://github.com/$REPO/releases/download/$TAG/$DMG_FILENAME"
else
    # Criar novo release
    RELEASE_FLAGS=""
    if [[ "$IS_DRAFT" == true ]]; then
        RELEASE_FLAGS="$RELEASE_FLAGS --draft"
    fi
    if [[ "$IS_PRERELEASE" == true ]]; then
        RELEASE_FLAGS="$RELEASE_FLAGS --prerelease"
    fi
    
    echo "==> Creating release $TAG..."
    gh release create "$TAG" \
        --title "Release $VERSION" \
        --notes "Release $VERSION of Pomodoro app" \
        $RELEASE_FLAGS \
        "$DMG_PATH" \
        --repo "$REPO"
    
    echo ""
    echo "==> Release created and uploaded!"
    echo "==> Release URL: https://github.com/$REPO/releases/tag/$TAG"
    echo "==> Download URL: https://github.com/$REPO/releases/download/$TAG/$DMG_FILENAME"
fi

echo ""
echo "==> Next steps:"
echo "1. Update NEXT_PUBLIC_DMG_DOWNLOAD_URL in web/.env.local:"
echo "   NEXT_PUBLIC_DMG_DOWNLOAD_URL=https://github.com/$REPO/releases/download/$TAG/$DMG_FILENAME"
echo ""
echo "2. If using appcast, update APPCAST_URL_BASE to point to your appcast location"
echo "   (e.g., GitHub Pages: https://$(echo $REPO | cut -d'/' -f1).github.io/$(echo $REPO | cut -d'/' -f2)/releases)"
