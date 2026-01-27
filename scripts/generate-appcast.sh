#!/bin/bash

# Script para gerar appcast.xml para Sparkle
# Uso: ./generate-appcast.sh <versão> <dmg_path> <release_notes> [appcast_url]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
KEYS_DIR="$PROJECT_DIR/keys"
PRIVATE_KEY="$KEYS_DIR/eddsa_private_key.pem"

if [ $# -lt 3 ]; then
    echo "Uso: $0 <versão> <dmg_path> <release_notes> [appcast_url]"
    echo ""
    echo "Exemplo:"
    echo "  $0 1.0.1 ./releases/Converge-1.0.1.dmg \"Correções de bugs\""
    exit 1
fi

VERSION="$1"
DMG_PATH="$2"
RELEASE_NOTES="$3"
APPCAST_URL="${4:-https://github.com/rckbrcls/converge/releases/latest/download/appcast.xml}"

# Verificar se o DMG existe
if [ ! -f "$DMG_PATH" ]; then
    echo "❌ Erro: DMG não encontrado em $DMG_PATH"
    exit 1
fi

# Verificar se a chave privada existe (opcional, mas recomendado)
HAS_PRIVATE_KEY=false
if [ -f "$PRIVATE_KEY" ]; then
    HAS_PRIVATE_KEY=true
else
    echo "⚠️  Aviso: Chave privada não encontrada em $PRIVATE_KEY"
    echo "   O appcast será gerado sem assinatura."
    echo "   Para assinar, execute primeiro: ./scripts/generate-keys.sh"
fi

# Verificar se Sparkle está instalado (opcional)
HAS_SPARKLE_TOOLS=false
if command -v generate_appcast &> /dev/null || command -v sign_update &> /dev/null; then
    HAS_SPARKLE_TOOLS=true
else
    echo "⚠️  Aviso: Sparkle tools não encontrado."
    echo "   O appcast será gerado sem assinatura."
    echo "   Para assinar, baixe o Sparkle: https://sparkle-project.org/download/"
fi

# Calcular tamanho do arquivo
FILE_SIZE=$(stat -f%z "$DMG_PATH")

# Obter data atual em formato RFC 822
PUB_DATE=$(date -u +"%a, %d %b %Y %H:%M:%S +0000")

# Criar diretório temporário para o appcast
TEMP_DIR=$(mktemp -d)
APPCAST_FILE="$TEMP_DIR/appcast.xml"

# Assinar o DMG (se possível)
SIGNATURE=""
if [ "$HAS_PRIVATE_KEY" = true ] && [ "$HAS_SPARKLE_TOOLS" = true ]; then
    echo "🔐 Assinando DMG..."
    if command -v sign_update &> /dev/null; then
        SIGNATURE=$(sign_update "$DMG_PATH" -f "$PRIVATE_KEY" 2>/dev/null | tr -d '\n' || echo "")
    fi
    
    # Se sign_update falhou, tentar generate_appcast
    if [ -z "$SIGNATURE" ] && command -v generate_appcast &> /dev/null; then
        echo "Usando generate_appcast para assinar..."
        RELEASES_DIR_TEMP="$TEMP_DIR/releases_temp"
        mkdir -p "$RELEASES_DIR_TEMP"
        cp "$DMG_PATH" "$RELEASES_DIR_TEMP/"
        generate_appcast "$KEYS_DIR" "$RELEASES_DIR_TEMP" > /dev/null 2>&1 || true
        if [ -f "$RELEASES_DIR_TEMP/appcast.xml" ]; then
            SIGNATURE=$(grep -o 'sparkle:edSignature="[^"]*"' "$RELEASES_DIR_TEMP/appcast.xml" | sed 's/sparkle:edSignature="\([^"]*\)"/\1/' | head -1 || echo "")
        fi
        rm -rf "$RELEASES_DIR_TEMP"
    fi
fi

# Gerar appcast.xml
echo "📝 Gerando appcast.xml..."

cat > "$APPCAST_FILE" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>Converge</title>
        <link>https://github.com/rckbrcls/converge</link>
        <description>Converge - Pomodoro Timer for macOS</description>
        <language>en</language>
        <item>
            <title>Version $VERSION</title>
            <pubDate>$PUB_DATE</pubDate>
            <sparkle:minimumSystemVersion>11.0</sparkle:minimumSystemVersion>
            <enclosure 
                url="https://github.com/rckbrcls/converge/releases/download/v$VERSION/Converge-$VERSION.dmg"
                sparkle:version="$VERSION"
                sparkle:shortVersionString="$VERSION"
                length="$FILE_SIZE"
                type="application/octet-stream"
                sparkle:edSignature="$SIGNATURE"
            />
            <description><![CDATA[
$RELEASE_NOTES
            ]]></description>
        </item>
    </channel>
</rss>
EOF

# Adicionar assinatura ao appcast se disponível
if [ -n "$SIGNATURE" ]; then
    # Atualizar appcast com assinatura
    sed -i '' "s/sparkle:edSignature=\"\"/sparkle:edSignature=\"$SIGNATURE\"/" "$APPCAST_FILE" 2>/dev/null || \
    sed -i "s/sparkle:edSignature=\"\"/sparkle:edSignature=\"$SIGNATURE\"/" "$APPCAST_FILE" 2>/dev/null || true
    echo "✅ Assinatura adicionada ao appcast"
else
    echo "⚠️  Aviso: Appcast gerado sem assinatura."
    echo "   Para assinar, instale o Sparkle tools e gere as chaves EdDSA."
fi

# Copiar appcast para o diretório do projeto
OUTPUT_FILE="$PROJECT_DIR/appcast.xml"
cp "$APPCAST_FILE" "$OUTPUT_FILE"

echo ""
echo "✅ Appcast gerado com sucesso!"
echo "   Arquivo: $OUTPUT_FILE"
echo ""
echo "📋 Próximos passos:"
echo "   1. Revise o appcast.xml gerado"
echo "   2. Faça upload do appcast.xml e do DMG para GitHub Releases"
echo "   3. Certifique-se de que a URL no appcast está correta"

# Limpar diretório temporário
rm -rf "$TEMP_DIR"
