#!/bin/bash

set -euo pipefail

SPARKLE_TOOLS_VERSION="${SPARKLE_TOOLS_VERSION:-2.8.1}"
TOOLS_DIR="${TOOLS_DIR:-.sparkle-tools}"
KEYS_DIR="keys"
PRIVATE_KEY_PATH="$KEYS_DIR/eddsa_private_key.pem"
PUBLIC_KEY_PATH="$KEYS_DIR/eddsa_public_key.pem"
SPARKLE_ACCOUNT="${SPARKLE_ACCOUNT:-ed25519}"
GENERATE_KEYS_BIN=""

log() {
  printf "[sparkle] %s\n" "$1"
}

download_tools() {
  local tarball="Sparkle-${SPARKLE_TOOLS_VERSION}.tar.xz"
  local url="https://github.com/sparkle-project/Sparkle/releases/download/${SPARKLE_TOOLS_VERSION}/${tarball}"
  local tmp_tar
  tmp_tar="$(mktemp -t sparkle-tools.XXXXXX)"

  log "Downloading Sparkle tools ${SPARKLE_TOOLS_VERSION}..."
  curl -fsSL "$url" -o "$tmp_tar"

  rm -rf "$TOOLS_DIR"
  mkdir -p "$TOOLS_DIR"
  tar -xJf "$tmp_tar" -C "$TOOLS_DIR" --strip-components=1
  rm -f "$tmp_tar"
}

resolve_generate_keys() {
  local candidates=(
    ".build/artifacts/sparkle/Sparkle/bin/generate_keys"
    ".build/checkouts/Sparkle/generate_keys"
  )

  for candidate in "${candidates[@]}"; do
    if [ -x "$candidate" ]; then
      GENERATE_KEYS_BIN="$candidate"
      return 0
    fi
  done

  if [ -d ".build" ]; then
    local found=""
    local found_fallback=""
    while IFS= read -r -d '' path; do
      if [ -x "$path" ]; then
        if [[ "$path" == *"/artifacts/"* ]] && [ -z "$found" ]; then
          found="$path"
        elif [ -z "$found_fallback" ]; then
          found_fallback="$path"
        fi
      fi
    done < <(find .build -type f -name generate_keys -print0 2>/dev/null || true)

    if [ -n "$found" ]; then
      GENERATE_KEYS_BIN="$found"
      return 0
    fi
    if [ -n "$found_fallback" ]; then
      GENERATE_KEYS_BIN="$found_fallback"
      return 0
    fi
  fi

  if [ -x "$TOOLS_DIR/bin/generate_keys" ]; then
    GENERATE_KEYS_BIN="$TOOLS_DIR/bin/generate_keys"
    return 0
  fi

  return 1
}

mkdir -p "$KEYS_DIR"

if ! resolve_generate_keys; then
  download_tools
  resolve_generate_keys
fi

if [ -z "$GENERATE_KEYS_BIN" ]; then
  log "generate_keys not found after download."
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ABS_GENERATE_KEYS_BIN="$(cd "$(dirname "$GENERATE_KEYS_BIN")" && pwd)/$(basename "$GENERATE_KEYS_BIN")"

log "Generating EdDSA keys using Sparkle tools..."
log "Using: $ABS_GENERATE_KEYS_BIN"
(
  cd "$TMP_DIR"
  "$ABS_GENERATE_KEYS_BIN" --account "$SPARKLE_ACCOUNT" > "$TMP_DIR/output.txt"
)

PUBLIC_KEY="$(grep -Eo '[A-Za-z0-9+/]{43}=' "$TMP_DIR/output.txt" | head -1 || true)"
if [ -z "$PUBLIC_KEY" ]; then
  log "Could not auto-detect public key. Full output:"
  cat "$TMP_DIR/output.txt"
  exit 1
fi

log "Exporting private key from Keychain..."
"$ABS_GENERATE_KEYS_BIN" --account "$SPARKLE_ACCOUNT" -x "$PRIVATE_KEY_PATH" > /dev/null

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  log "Private key export failed. You can try manually:"
  log "$ABS_GENERATE_KEYS_BIN --account \"$SPARKLE_ACCOUNT\" -x \"$PRIVATE_KEY_PATH\""
  exit 1
fi

chmod 600 "$PRIVATE_KEY_PATH"
printf "%s" "$PUBLIC_KEY" > "$PUBLIC_KEY_PATH"

log "Private key saved to: $PRIVATE_KEY_PATH"
log "Public key saved to:  $PUBLIC_KEY_PATH"
printf "\nSUPublicEDKey:\n%s\n" "$PUBLIC_KEY"
