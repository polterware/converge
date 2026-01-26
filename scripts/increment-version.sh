#!/bin/bash
set -e

# Script para incrementar a versão do app automaticamente
# Uso: ./scripts/increment-version.sh [patch|minor|major]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_FILE="$PROJECT_ROOT/pomodoro.xcodeproj/project.pbxproj"

# Tipo de incremento: patch (1.0.0 -> 1.0.1), minor (1.0.0 -> 1.1.0), major (1.0.0 -> 2.0.0)
INCREMENT_TYPE="${1:-patch}"

if [[ ! "$INCREMENT_TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo "Error: Invalid increment type. Use: patch, minor, or major"
    exit 1
fi

# Função para extrair versão atual
get_current_version() {
    grep -A 1 "MARKETING_VERSION" "$PROJECT_FILE" | grep -o '[0-9]\+\.[0-9]\+' | head -1
}

# Função para extrair build number atual
get_current_build() {
    grep -A 1 "CURRENT_PROJECT_VERSION" "$PROJECT_FILE" | grep -o '[0-9]\+' | head -1
}

# Função para incrementar versão
increment_version() {
    local version="$1"
    local type="$2"
    IFS='.' read -ra PARTS <<< "$version"
    local major="${PARTS[0]}"
    local minor="${PARTS[1]:-0}"
    
    case "$type" in
        major)
            major=$((major + 1))
            minor=0
            ;;
        minor)
            minor=$((minor + 1))
            ;;
        patch)
            # Para patch, incrementamos o build number em vez da versão
            echo "$version"
            return
            ;;
    esac
    
    echo "$major.$minor"
}

# Função para atualizar versão no project.pbxproj
update_version() {
    local new_version="$1"
    local new_build="$2"
    
    # Atualizar MARKETING_VERSION
    sed -i '' "s/MARKETING_VERSION = [0-9]\+\.[0-9]\+;/MARKETING_VERSION = $new_version;/g" "$PROJECT_FILE"
    
    # Atualizar CURRENT_PROJECT_VERSION (build number)
    sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]\+;/CURRENT_PROJECT_VERSION = $new_build;/g" "$PROJECT_FILE"
    
    echo "Version updated to $new_version (build $new_build)"
}

# Obter versões atuais
CURRENT_VERSION=$(get_current_version)
CURRENT_BUILD=$(get_current_build)

# Incrementar
if [[ "$INCREMENT_TYPE" == "patch" ]]; then
    NEW_VERSION="$CURRENT_VERSION"
    NEW_BUILD=$((CURRENT_BUILD + 1))
else
    NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$INCREMENT_TYPE")
    NEW_BUILD=$((CURRENT_BUILD + 1))
fi

# Atualizar
update_version "$NEW_VERSION" "$NEW_BUILD"

echo "Current version: $CURRENT_VERSION (build $CURRENT_BUILD)"
echo "New version: $NEW_VERSION (build $NEW_BUILD)"
