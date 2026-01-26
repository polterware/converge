#!/bin/bash
set -e

# Script para gerar par de chaves EdDSA para assinatura de atualizações Sparkle
# Uso: ./scripts/generate-keys.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYS_DIR="$PROJECT_ROOT/keys"

echo "==> Generating EdDSA keys for Sparkle updates..."

# Criar diretório de chaves se não existir
mkdir -p "$KEYS_DIR"

PRIVATE_KEY="$KEYS_DIR/eddsa_private_key.pem"
PUBLIC_KEY="$KEYS_DIR/eddsa_public_key.pem"

# Verificar se as chaves já existem
if [[ -f "$PRIVATE_KEY" ]] || [[ -f "$PUBLIC_KEY" ]]; then
    echo "Warning: Keys already exist!"
    echo "Private key: $PRIVATE_KEY"
    echo "Public key: $PUBLIC_KEY"
    echo ""
    read -p "Do you want to overwrite them? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    rm -f "$PRIVATE_KEY" "$PUBLIC_KEY"
fi

# Gerar chave privada EdDSA usando OpenSSL
echo "==> Generating private key..."
openssl genpkey -algorithm Ed25519 -out "$PRIVATE_KEY"

# Gerar chave pública a partir da privada
echo "==> Generating public key..."
openssl pkey -in "$PRIVATE_KEY" -pubout -out "$PUBLIC_KEY"

# Obter a chave pública no formato que o Sparkle espera (base64, sem headers)
PUBLIC_KEY_CONTENT=$(openssl pkey -in "$PRIVATE_KEY" -pubout -outform DER | base64)

echo ""
echo "==> Keys generated successfully!"
echo ""
echo "Private key: $PRIVATE_KEY"
echo "Public key: $PUBLIC_KEY"
echo ""
echo "⚠️  IMPORTANT: Keep the private key SECRET! Never commit it to git!"
echo ""
echo "Add the following to your Info.plist:"
echo ""
echo "  <key>SUPublicEDKey</key>"
echo "  <string>$PUBLIC_KEY_CONTENT</string>"
echo ""
echo "The public key content (for Info.plist):"
echo "$PUBLIC_KEY_CONTENT"
echo ""

# Adicionar ao .gitignore se não estiver lá
GITIGNORE="$PROJECT_ROOT/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
    if ! grep -q "keys/eddsa_private_key.pem" "$GITIGNORE"; then
        echo "" >> "$GITIGNORE"
        echo "# Sparkle EdDSA keys" >> "$GITIGNORE"
        echo "keys/eddsa_private_key.pem" >> "$GITIGNORE"
        echo "==> Added private key to .gitignore"
    fi
else
    echo "keys/eddsa_private_key.pem" > "$GITIGNORE"
    echo "==> Created .gitignore and added private key"
fi
