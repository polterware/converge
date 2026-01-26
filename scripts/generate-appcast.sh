#!/bin/bash
set -e

# Script para gerar o appcast.xml (feed de atualizações do Sparkle)
# Uso: ./scripts/generate-appcast.sh [URL_BASE] [DMG_PATH]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"

# URL base onde os arquivos serão hospedados (ex: https://example.com/releases)
URL_BASE="${1:-https://example.com/releases}"

# Caminho do DMG (se não fornecido, usa o mais recente)
DMG_PATH="${2:-}"

if [[ -z "$DMG_PATH" ]]; then
    # Encontrar o DMG mais recente
    DMG_PATH=$(ls -t "$BUILD_DIR"/Pomodoro-*.dmg 2>/dev/null | head -1)
fi

if [[ ! -f "$DMG_PATH" ]]; then
    echo "Error: DMG not found at $DMG_PATH"
    echo "Usage: $0 [URL_BASE] [DMG_PATH]"
    exit 1
fi

# Extrair versão do nome do arquivo
DMG_NAME=$(basename "$DMG_PATH")
VERSION=$(echo "$DMG_NAME" | sed -E 's/Pomodoro-([0-9]+\.[0-9]+)\.dmg/\1/')

if [[ -z "$VERSION" ]]; then
    echo "Error: Could not extract version from $DMG_NAME"
    exit 1
fi

# Obter build number do projeto
BUILD=$(grep -A 1 "CURRENT_PROJECT_VERSION" "$PROJECT_ROOT/pomodoro.xcodeproj/project.pbxproj" | grep -o '[0-9]\+' | head -1)

# Calcular tamanho do arquivo
FILE_SIZE=$(stat -f%z "$DMG_PATH")

# Tentar obter assinatura EdDSA se o DMG foi assinado
# Verificar se existe chave privada e tentar assinar se necessário
KEYS_DIR="$PROJECT_ROOT/keys"
PRIVATE_KEY="$KEYS_DIR/eddsa_private_key.pem"
DMG_HASH=""

if [[ -f "$PRIVATE_KEY" ]]; then
    # Tentar usar sign_update do Sparkle se disponível
    SPARKLE_SIGN_TOOL=""
    POSSIBLE_PATHS=(
        "$PROJECT_ROOT/.build/checkouts/Sparkle/bin/sign_update"
        "$PROJECT_ROOT/.build/checkouts/sparkle/bin/sign_update"
        "$PROJECT_ROOT/Sparkle/bin/sign_update"
        "$HOME/Library/Developer/Xcode/DerivedData/*/SourcePackages/checkouts/Sparkle/bin/sign_update"
        "/usr/local/bin/sign_update"
        "sign_update"
    )
    
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [[ "$path" == *"*"* ]]; then
            EXPANDED=$(ls -d $path 2>/dev/null | head -1)
            if [[ -f "$EXPANDED" ]] && [[ -x "$EXPANDED" ]]; then
                SPARKLE_SIGN_TOOL="$EXPANDED"
                break
            fi
        elif command -v "$path" &> /dev/null; then
            SPARKLE_SIGN_TOOL="$path"
            break
        elif [[ -f "$path" ]] && [[ -x "$path" ]]; then
            SPARKLE_SIGN_TOOL="$path"
            break
        fi
    done
    
    if [[ -n "$SPARKLE_SIGN_TOOL" ]]; then
        echo "==> Signing DMG with EdDSA key..."
        SIGN_OUTPUT=$("$SPARKLE_SIGN_TOOL" "$DMG_PATH" --ed-key-file "$PRIVATE_KEY" 2>&1)
        if [[ $? -eq 0 ]]; then
            # Extrair assinatura da saída XML
            DMG_HASH=$(echo "$SIGN_OUTPUT" | grep -o 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)
            if [[ -n "$DMG_HASH" ]]; then
                echo "==> Using EdDSA signature"
            fi
        fi
    fi
fi

# Se não conseguiu obter assinatura EdDSA, usar SHA256 como fallback
if [[ -z "$DMG_HASH" ]]; then
    echo "==> Calculating SHA256 hash (EdDSA signature not available)"
    echo "Warning: Using SHA256 hash as placeholder. For production, use EdDSA signature."
    echo "Run: ./scripts/sign-dmg.sh $DMG_PATH"
    DMG_HASH=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
fi

# Nome do arquivo DMG
DMG_FILENAME=$(basename "$DMG_PATH")
DMG_URL="${URL_BASE}/${DMG_FILENAME}"

# Data de publicação (RFC 822 format)
PUB_DATE=$(date -u +"%a, %d %b %Y %H:%M:%S +0000")

# Diretório de releases
RELEASES_DIR="$PROJECT_ROOT/releases"
mkdir -p "$RELEASES_DIR"

# Arquivo appcast
APPCAST_FILE="$RELEASES_DIR/appcast.xml"

# Se o appcast já existe, adicionar nova entrada
if [[ -f "$APPCAST_FILE" ]]; then
    echo "==> Adding new version to existing appcast..."
    
    # Criar entrada XML para nova versão
    NEW_ITEM=$(cat <<EOF
    <item>
        <title>Version $VERSION</title>
        <pubDate>$PUB_DATE</pubDate>
        <sparkle:minimumSystemVersion>26.2</sparkle:minimumSystemVersion>
        <enclosure
            url="$DMG_URL"
            sparkle:version="$BUILD"
            sparkle:shortVersionString="$VERSION"
            length="$FILE_SIZE"
            type="application/octet-stream"
            sparkle:edSignature="$DMG_HASH"
        />
        <description><![CDATA[
            <h2>Version $VERSION</h2>
            <p>Release notes for version $VERSION</p>
        ]]></description>
    </item>
EOF
)
    
    # Inserir após a tag <channel>
    # Usar uma abordagem mais simples: recriar o arquivo
    TEMP_FILE=$(mktemp)
    
    # Ler o conteúdo existente e inserir o novo item
    awk -v newitem="$NEW_ITEM" '
    /<channel>/ {
        print
        getline
        print newitem
    }
    { print }
    ' "$APPCAST_FILE" > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$APPCAST_FILE"
else
    echo "==> Creating new appcast..."
    
    # Criar novo appcast
    cat > "$APPCAST_FILE" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>Pomodoro App Updates</title>
        <link>$URL_BASE</link>
        <description>Automatic update feed for Pomodoro app</description>
        <language>en</language>
        <item>
            <title>Version $VERSION</title>
            <pubDate>$PUB_DATE</pubDate>
            <sparkle:minimumSystemVersion>26.2</sparkle:minimumSystemVersion>
            <enclosure
                url="$DMG_URL"
                sparkle:version="$BUILD"
                sparkle:shortVersionString="$VERSION"
                length="$FILE_SIZE"
                type="application/octet-stream"
                sparkle:edSignature="$DMG_HASH"
            />
            <description><![CDATA[
                <h2>Version $VERSION</h2>
                <p>Release notes for version $VERSION</p>
            ]]></description>
        </item>
    </channel>
</rss>
EOF
fi

echo "==> Appcast generated: $APPCAST_FILE"
echo "==> Version: $VERSION (build $BUILD)"
echo "==> DMG URL: $DMG_URL"
echo ""
echo "Next steps:"
echo "1. Upload $DMG_PATH to your server at: $URL_BASE/"
echo "2. Upload $APPCAST_FILE to your server"
echo "3. Configure SUFeedURL in Info.plist to point to your appcast URL"
