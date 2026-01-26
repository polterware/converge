#!/bin/bash
set -e

# Script para assinar DMG com chave EdDSA para Sparkle
# Uso: ./scripts/sign-dmg.sh [DMG_PATH] [PRIVATE_KEY_PATH]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYS_DIR="$PROJECT_ROOT/keys"

# Caminho do DMG (se não fornecido, usa o mais recente)
DMG_PATH="${1:-}"

# Caminho da chave privada (padrão: keys/eddsa_private_key.pem)
PRIVATE_KEY_PATH="${2:-$KEYS_DIR/eddsa_private_key.pem}"

# Se DMG não fornecido, encontrar o mais recente
if [[ -z "$DMG_PATH" ]]; then
    BUILD_DIR="$PROJECT_ROOT/build"
    DMG_PATH=$(ls -t "$BUILD_DIR"/Pomodoro-*.dmg 2>/dev/null | head -1)
fi

if [[ ! -f "$DMG_PATH" ]]; then
    echo "Error: DMG not found at $DMG_PATH"
    echo "Usage: $0 [DMG_PATH] [PRIVATE_KEY_PATH]"
    exit 1
fi

if [[ ! -f "$PRIVATE_KEY_PATH" ]]; then
    echo "Error: Private key not found at $PRIVATE_KEY_PATH"
    echo "Generate keys first with: ./scripts/generate-keys.sh"
    exit 1
fi

echo "==> Signing DMG with EdDSA key..."
echo "DMG: $DMG_PATH"
echo "Key: $PRIVATE_KEY_PATH"

# Verificar se Sparkle sign_update está disponível
# Sparkle pode estar instalado via SPM ou manualmente
SPARKLE_SIGN_TOOL=""

# Tentar encontrar sign_update em vários locais
POSSIBLE_PATHS=(
    "$PROJECT_ROOT/.build/checkouts/Sparkle/bin/sign_update"
    "$PROJECT_ROOT/.build/checkouts/sparkle/bin/sign_update"
    "$PROJECT_ROOT/Sparkle/bin/sign_update"
    "$HOME/Library/Developer/Xcode/DerivedData/*/SourcePackages/checkouts/Sparkle/bin/sign_update"
    "/usr/local/bin/sign_update"
    "sign_update"  # Se estiver no PATH
)

for path in "${POSSIBLE_PATHS[@]}"; do
    # Expandir glob patterns
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

if [[ -z "$SPARKLE_SIGN_TOOL" ]]; then
    echo ""
    echo "Warning: Sparkle sign_update tool not found."
    echo "The DMG will not be signed with EdDSA."
    echo ""
    echo "To sign DMGs, you need Sparkle installed:"
    echo "1. Add Sparkle via Swift Package Manager in Xcode"
    echo "2. Or download from: https://sparkle-project.org/download/"
    echo ""
    echo "After installing Sparkle, the sign_update tool will be available."
    echo ""
    echo "For now, you can manually sign using:"
    echo "  ./bin/sign_update $DMG_PATH --ed-key-file $PRIVATE_KEY_PATH"
    echo ""
    exit 0
fi

# Assinar o DMG
echo "==> Using Sparkle sign_update tool: $SPARKLE_SIGN_TOOL"
echo ""

# Executar sign_update e capturar a saída
SIGNATURE_OUTPUT=$("$SPARKLE_SIGN_TOOL" "$DMG_PATH" --ed-key-file "$PRIVATE_KEY_PATH" 2>&1)

if [[ $? -eq 0 ]]; then
    echo "==> DMG signed successfully!"
    echo ""
    echo "Signature information:"
    echo "$SIGNATURE_OUTPUT"
    echo ""
    echo "Add this signature to your appcast.xml in the sparkle:edSignature attribute."
    echo ""
    
    # Extrair apenas a assinatura (se a saída contiver XML, extrair o valor)
    if echo "$SIGNATURE_OUTPUT" | grep -q "sparkle:edSignature"; then
        ED_SIGNATURE=$(echo "$SIGNATURE_OUTPUT" | grep -o 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)
        echo "EdDSA Signature: $ED_SIGNATURE"
    fi
else
    echo "Error: Failed to sign DMG"
    echo "$SIGNATURE_OUTPUT"
    exit 1
fi
