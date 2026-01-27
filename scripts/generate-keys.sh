#!/bin/bash

# Script para gerar par de chaves EdDSA para assinatura de atualizações Sparkle
# Execute este script uma vez para gerar as chaves necessárias

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
KEYS_DIR="$PROJECT_DIR/keys"

echo "🔑 Gerando chaves EdDSA para Sparkle..."

# Criar diretório de chaves se não existir
mkdir -p "$KEYS_DIR"

# Verificar se Sparkle está instalado
if ! command -v generate_keys &> /dev/null; then
    echo "❌ Sparkle tools não encontrado."
    echo ""
    echo "Para instalar o Sparkle tools:"
    echo "1. Baixe o Sparkle: https://sparkle-project.org/download/"
    echo "2. Extraia e copie o binário 'generate_keys' para /usr/local/bin/"
    echo "   ou adicione ao PATH"
    echo ""
    echo "Alternativamente, você pode usar o script Python fornecido."
    exit 1
fi

# Gerar chaves
PRIVATE_KEY="$KEYS_DIR/eddsa_private_key.pem"
PUBLIC_KEY="$KEYS_DIR/eddsa_public_key.pem"

if [ -f "$PRIVATE_KEY" ]; then
    echo "⚠️  Chave privada já existe em $PRIVATE_KEY"
    read -p "Deseja sobrescrever? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Operação cancelada."
        exit 0
    fi
fi

echo "Gerando chaves..."
generate_keys "$KEYS_DIR"

# Verificar se as chaves foram geradas
if [ ! -f "$PRIVATE_KEY" ]; then
    echo "❌ Erro ao gerar chaves. Verifique se o Sparkle tools está instalado corretamente."
    exit 1
fi

# Extrair chave pública para Info.plist
echo ""
echo "✅ Chaves geradas com sucesso!"
echo ""
echo "📋 Chave pública (adicione ao Info.plist como SUPublicEDKey):"
echo "---"
cat "$PUBLIC_KEY" | grep -v "BEGIN" | grep -v "END" | tr -d '\n'
echo ""
echo "---"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Chave privada: $PRIVATE_KEY (NUNCA commitar no git!)"
echo "   - Chave pública: $PUBLIC_KEY (pode ser commitada)"
echo ""
echo "A chave privada já está no .gitignore e não será commitada."
