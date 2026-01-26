#!/bin/bash
set -e

# Script para fazer upload do DMG e appcast para Supabase Storage
# Uso: ./scripts/upload-to-supabase.sh [DMG_PATH] [APPCAST_PATH]
# Requer: Variáveis de ambiente SUPABASE_URL e SUPABASE_SERVICE_KEY

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verificar variáveis de ambiente
if [[ -z "$SUPABASE_URL" ]]; then
    echo "Error: SUPABASE_URL environment variable is not set."
    echo "Set it with: export SUPABASE_URL=https://your-project.supabase.co"
    exit 1
fi

if [[ -z "$SUPABASE_SERVICE_KEY" ]]; then
    echo "Error: SUPABASE_SERVICE_KEY environment variable is not set."
    echo "Get it from your Supabase project settings (Project Settings > API > service_role key)"
    exit 1
fi

BUCKET_NAME="${SUPABASE_BUCKET_NAME:-releases}"

# Caminho do DMG (se não fornecido, usa o mais recente)
DMG_PATH="${1:-}"

if [[ -z "$DMG_PATH" ]]; then
    DMG_PATH=$(ls -t "$PROJECT_ROOT/build"/Pomodoro-*.dmg 2>/dev/null | head -1)
fi

if [[ ! -f "$DMG_PATH" ]]; then
    echo "Error: DMG not found at $DMG_PATH"
    echo "Usage: $0 [DMG_PATH] [APPCAST_PATH]"
    exit 1
fi

# Caminho do appcast (se não fornecido, usa o padrão)
APPCAST_PATH="${2:-$PROJECT_ROOT/releases/appcast.xml}"

if [[ ! -f "$APPCAST_PATH" ]]; then
    echo "Warning: Appcast not found at $APPCAST_PATH"
    echo "Skipping appcast upload. Generate it first with: ./scripts/generate-appcast.sh"
    APPCAST_PATH=""
fi

DMG_NAME=$(basename "$DMG_PATH")
APPCAST_NAME=$(basename "$APPCAST_PATH" 2>/dev/null || echo "")

echo "==> Uploading to Supabase Storage..."
echo "==> Project: $SUPABASE_URL"
echo "==> Bucket: $BUCKET_NAME"
echo "==> DMG: $DMG_NAME"

# Função para fazer upload de arquivo
upload_file() {
    local file_path="$1"
    local file_name="$2"
    local content_type="$3"
    
    if [[ ! -f "$file_path" ]]; then
        return 1
    fi
    
    echo "==> Uploading $file_name..."
    
    # Fazer upload usando curl
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST \
        "${SUPABASE_URL}/storage/v1/object/${BUCKET_NAME}/${file_name}" \
        -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
        -H "Content-Type: ${content_type}" \
        --data-binary "@${file_path}")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]]; then
        echo "==> ✓ Uploaded successfully: $file_name"
        return 0
    else
        # Tentar criar bucket se não existir
        if echo "$BODY" | grep -q "Bucket not found" || [[ "$HTTP_CODE" -eq 404 ]]; then
            echo "==> Bucket not found. Creating bucket..."
            CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" \
                -X POST \
                "${SUPABASE_URL}/storage/v1/bucket" \
                -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
                -H "Content-Type: application/json" \
                -d "{\"name\":\"${BUCKET_NAME}\",\"public\":true}")
            
            CREATE_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)
            
            if [[ "$CREATE_CODE" -ge 200 && "$CREATE_CODE" -lt 300 ]]; then
                echo "==> ✓ Bucket created. Retrying upload..."
                # Tentar novamente
                RESPONSE=$(curl -s -w "\n%{http_code}" \
                    -X POST \
                    "${SUPABASE_URL}/storage/v1/object/${BUCKET_NAME}/${file_name}" \
                    -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
                    -H "Content-Type: ${content_type}" \
                    --data-binary "@${file_path}")
                
                HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
                BODY=$(echo "$RESPONSE" | sed '$d')
            fi
        fi
        
        if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]]; then
            echo "==> ✓ Uploaded successfully: $file_name"
            return 0
        else
            echo "Error: Failed to upload $file_name"
            echo "HTTP Code: $HTTP_CODE"
            echo "Response: $BODY"
            return 1
        fi
    fi
}

# Upload do DMG
if ! upload_file "$DMG_PATH" "$DMG_NAME" "application/octet-stream"; then
    echo "Error: Failed to upload DMG"
    exit 1
fi

DMG_URL="${SUPABASE_URL}/storage/v1/object/public/${BUCKET_NAME}/${DMG_NAME}"

# Upload do appcast (se fornecido)
APPCAST_URL=""
if [[ -n "$APPCAST_PATH" && -f "$APPCAST_PATH" ]]; then
    if upload_file "$APPCAST_PATH" "$APPCAST_NAME" "application/xml"; then
        APPCAST_URL="${SUPABASE_URL}/storage/v1/object/public/${BUCKET_NAME}/${APPCAST_NAME}"
    else
        echo "Warning: Failed to upload appcast, but continuing..."
    fi
fi

echo ""
echo "==> Upload complete!"
echo "==> DMG URL: $DMG_URL"
if [[ -n "$APPCAST_URL" ]]; then
    echo "==> Appcast URL: $APPCAST_URL"
fi

echo ""
echo "==> Next steps:"
echo "1. Update NEXT_PUBLIC_DMG_DOWNLOAD_URL in web/.env.local:"
echo "   NEXT_PUBLIC_DMG_DOWNLOAD_URL=$DMG_URL"
echo ""
if [[ -n "$APPCAST_URL" ]]; then
    echo "2. Update APPCAST_URL_BASE for future releases:"
    echo "   export APPCAST_URL_BASE=${SUPABASE_URL}/storage/v1/object/public/${BUCKET_NAME}"
    echo ""
    echo "3. Configure SUFeedURL in Info.plist:"
    echo "   <key>SUFeedURL</key>"
    echo "   <string>$APPCAST_URL</string>"
fi
