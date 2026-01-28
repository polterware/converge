# Comparação dos Scripts de Release

## Resumo das Diferenças

| Característica | `release/release.sh` | `scripts/release.sh` |
|----------------|---------------------|---------------------|
| **Formato de distribuição** | DMG | ZIP |
| **Sistema de atualização** | Sparkle (appcast.xml) | Homebrew Cask |
| **Assinatura** | EdDSA para Sparkle | Não necessária |
| **Publicação GitHub** | Manual (instruções) | Automática (gh CLI) |
| **Estrutura** | Múltiplos comandos | Processo único automatizado |
| **Release notes** | Básicas | Completas com SHA256 |
| **SHA256** | Não calcula | Calcula automaticamente |

## `release/release.sh` (Script Antigo/Legado)

### Características:
- **Foco**: Distribuição via DMG + Sparkle
- **Comandos disponíveis**:
  - `keys` - Gerar chaves EdDSA
  - `appcast` - Gerar appcast.xml
  - `release` - Build completo + DMG + appcast
  - `fix-security` - Remover quarentena

### Fluxo:
1. Build do app
2. Cria DMG
3. Assina DMG com EdDSA (se chaves disponíveis)
4. Gera appcast.xml
5. **Não publica automaticamente** - apenas gera arquivos

### Uso:
```bash
./release/release.sh release 1.0.0 release-notes.md
```

### Quando usar:
- Se você ainda quer usar Sparkle para updates
- Se precisa de controle manual sobre cada etapa
- Se não quer publicar automaticamente no GitHub

---

## `scripts/release.sh` (Script Novo - Homebrew)

### Características:
- **Foco**: Distribuição via ZIP + Homebrew Cask
- **Processo**: Automatizado completo
- **Flags disponíveis**:
  - `--skip-build` - Pular build
  - `--skip-zip` - Pular criação do ZIP
  - `--skip-release` - Pular publicação no GitHub

### Fluxo:
1. Build do app (universal: arm64 + x86_64)
2. Cria ZIP com o app
3. Calcula SHA256 automaticamente
4. Publica automaticamente no GitHub Release
5. Gera release notes completas

### Uso:
```bash
./scripts/release.sh
```

### Quando usar:
- ✅ **Recomendado para distribuição via Homebrew**
- Se você quer processo automatizado completo
- Se não precisa de Sparkle/notarização
- Se quer publicar automaticamente no GitHub

---

## Diferenças Técnicas Detalhadas

### 1. Formato de Distribuição

**release/release.sh:**
```bash
# Cria DMG
hdiutil create -volname "Converge" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"
```

**scripts/release.sh:**
```bash
# Cria ZIP
zip -r "$zip_path" "$(basename "$app_path")" > /dev/null
```

### 2. Assinatura

**release/release.sh:**
- Requer chaves EdDSA
- Assina DMG para Sparkle
- Gera appcast.xml com assinatura

**scripts/release.sh:**
- Não precisa de assinatura
- Sem Sparkle/notarização
- Focado em Homebrew (que gerencia isso)

### 3. Publicação GitHub

**release/release.sh:**
- Não publica automaticamente
- Apenas instrui como fazer manualmente:
  ```bash
  gh release create v$VERSION $DMG_PATH appcast.xml ...
  ```

**scripts/release.sh:**
- Publica automaticamente via `gh release create`
- Cria release notes completas
- Inclui SHA256 nas release notes

### 4. Release Notes

**release/release.sh:**
- Release notes básicas ou de arquivo externo
- Não inclui SHA256

**scripts/release.sh:**
- Release notes completas com:
  - Instruções Homebrew
  - Instruções manuais
  - SHA256 para atualizar Cask
  - Links e recursos

### 5. Estrutura de Comandos

**release/release.sh:**
```bash
# Múltiplos comandos separados
./release/release.sh keys
./release/release.sh appcast 1.0.0 dmg_path notes
./release/release.sh release 1.0.0
```

**scripts/release.sh:**
```bash
# Um comando faz tudo
./scripts/release.sh

# Ou com flags para pular etapas
./scripts/release.sh --skip-build
```

---

## Recomendação

**Use `scripts/release.sh`** para:
- ✅ Distribuição moderna via Homebrew Cask
- ✅ Processo automatizado completo
- ✅ Sem necessidade de notarização/Sparkle
- ✅ Publicação automática no GitHub

**Mantenha `release/release.sh`** apenas se:
- Você ainda precisa de Sparkle para updates
- Quer controle manual sobre cada etapa
- Precisa gerar DMG para distribuição tradicional

---

## Migração

Se você estava usando `release/release.sh`, migre para `scripts/release.sh`:

1. **Remova dependências de Sparkle** (se não precisar mais)
2. **Use o novo script**:
   ```bash
   ./scripts/release.sh
   ```
3. **Atualize o Cask** com o SHA256 exibido
4. **Teste a instalação**:
   ```bash
   brew install --cask ./Casks/converge.rb
   ```
