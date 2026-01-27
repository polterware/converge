#!/bin/bash

# Script completo para gerar release do Converge
# Uso: ./generate-release.sh <versão> [release_notes_file]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RELEASES_DIR="$PROJECT_DIR/releases"
KEYS_DIR="$PROJECT_DIR/keys"

if [ $# -lt 1 ]; then
    echo "Uso: $0 <versão> [release_notes_file]"
    echo ""
    echo "Exemplo:"
    echo "  $0 1.0.1"
    echo "  $0 1.0.1 release-notes.md"
    exit 1
fi

VERSION="$1"
RELEASE_NOTES_FILE="${2:-}"

# Verificar se estamos no diretório correto
if [ ! -f "$PROJECT_DIR/converge.xcodeproj/project.pbxproj" ]; then
    echo "❌ Erro: Execute este script do diretório raiz do projeto"
    exit 1
fi

echo "🚀 Iniciando processo de release v$VERSION..."
echo ""

# 1. Verificar se Xcode está disponível
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Erro: xcodebuild não encontrado. Certifique-se de que o Xcode está instalado."
    exit 1
fi

# 2. Verificar se a chave privada existe
if [ ! -f "$KEYS_DIR/eddsa_private_key.pem" ]; then
    echo "❌ Erro: Chave privada não encontrada."
    echo "Execute primeiro: ./scripts/generate-keys.sh"
    exit 1
fi

# 3. Criar diretório de releases
mkdir -p "$RELEASES_DIR"

# 4. Build do app
echo "📦 Construindo aplicativo..."
SCHEME="converge"
CONFIGURATION="Release"
ARCHIVE_PATH="$RELEASES_DIR/Converge.xcarchive"
APP_PATH="$ARCHIVE_PATH/Products/Applications/Converge.app"
DMG_NAME="Converge-$VERSION.dmg"
DMG_PATH="$RELEASES_DIR/$DMG_NAME"

# Limpar build anterior
xcodebuild clean -project converge.xcodeproj -scheme "$SCHEME" -configuration "$CONFIGURATION" || true

# Archive
echo "📦 Criando archive..."
xcodebuild archive \
    -project converge.xcodeproj \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$RELEASES_DIR/DerivedData" \
    CODE_SIGN_IDENTITY="Apple Development" \
    DEVELOPMENT_TEAM="VCF3DS6BTV"

# Verificar se o app foi criado
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Erro: App não encontrado em $APP_PATH"
    exit 1
fi

# 5. Criar DMG
echo "💿 Criando DMG..."
DMG_TEMP_DIR="$RELEASES_DIR/dmg_temp"
rm -rf "$DMG_TEMP_DIR"
mkdir -p "$DMG_TEMP_DIR"

# Copiar app para o diretório temporário
cp -R "$APP_PATH" "$DMG_TEMP_DIR/"

# Criar link simbólico para Applications
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# Criar DMG
hdiutil create -volname "Converge" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# Limpar diretório temporário
rm -rf "$DMG_TEMP_DIR"

echo "✅ DMG criado: $DMG_PATH"

# 6. Assinar DMG (opcional, mas recomendado)
if command -v codesign &> /dev/null; then
    echo "🔐 Assinando DMG..."
    codesign --force --deep --sign "Apple Development" "$DMG_PATH" || echo "⚠️  Aviso: Falha ao assinar DMG (pode ser normal em desenvolvimento)"
fi

# 7. Gerar appcast
echo "📝 Gerando appcast.xml..."

# Ler release notes se fornecido
RELEASE_NOTES=""
if [ -n "$RELEASE_NOTES_FILE" ] && [ -f "$RELEASE_NOTES_FILE" ]; then
    RELEASE_NOTES=$(cat "$RELEASE_NOTES_FILE")
else
    RELEASE_NOTES="Release v$VERSION"
fi

# Gerar appcast
"$SCRIPT_DIR/generate-appcast.sh" "$VERSION" "$DMG_PATH" "$RELEASE_NOTES"

# 8. Resumo
echo ""
echo "✅ Release gerado com sucesso!"
echo ""
echo "📦 Arquivos gerados:"
echo "   - DMG: $DMG_PATH"
echo "   - Appcast: $PROJECT_DIR/appcast.xml"
echo ""
echo "📋 Próximos passos:"
echo "   1. Teste o DMG instalando o app"
echo "   2. Crie uma release no GitHub:"
echo "      gh release create v$VERSION $DMG_PATH appcast.xml --title \"v$VERSION\" --notes \"$RELEASE_NOTES\""
echo ""
echo "   Ou faça upload manualmente:"
echo "   - Acesse: https://github.com/rckbrcls/converge/releases/new"
echo "   - Tag: v$VERSION"
echo "   - Título: v$VERSION"
echo "   - Anexe: $DMG_PATH"
echo "   - Anexe: $PROJECT_DIR/appcast.xml"
echo "   - Adicione as release notes"
