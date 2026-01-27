# Guia de Release do Converge

Este documento descreve o processo completo para criar e publicar uma nova release do Converge.

## Pré-requisitos

1. **Chaves EdDSA configuradas**
   - Execute `./scripts/generate-keys.sh` ou `python3 scripts/generate-keys-python.py`
   - Adicione a chave pública ao `project.pbxproj` como `INFOPLIST_KEY_SUPublicEDKey`

2. **Sparkle Tools instalado** (opcional, mas recomendado)
   - Baixe: https://sparkle-project.org/download/
   - Extraia e adicione ao PATH ou use o script Python alternativo

3. **GitHub CLI instalado** (opcional, para automação)
   - Instale: `brew install gh`
   - Autentique: `gh auth login`

## Processo de Release

### 1. Preparar a Release

```bash
# Certifique-se de estar na branch correta (geralmente main ou develop)
git checkout main
git pull origin main

# Atualize a versão no Xcode:
# - MARKETING_VERSION no project.pbxproj
# - Ou use o Xcode: Target → General → Version
```

### 2. Gerar a Release

```bash
# Execute o script de release
./scripts/generate-release.sh <versão> [release_notes_file]

# Exemplo:
./scripts/generate-release.sh 1.0.1 release-notes-1.0.1.md
```

O script irá:
1. Fazer build do app
2. Criar o DMG
3. Assinar o DMG (se possível)
4. Gerar o `appcast.xml`
5. Preparar tudo para upload

### 3. Testar o DMG

Antes de publicar, teste o DMG:
1. Abra o DMG gerado em `releases/Converge-<versão>.dmg`
2. Instale o app
3. Verifique se funciona corretamente
4. Teste a verificação de atualizações

### 4. Publicar no GitHub

#### Opção A: Usando GitHub CLI (recomendado)

```bash
# Criar release com DMG e appcast
gh release create v<versão> \
  releases/Converge-<versão>.dmg \
  appcast.xml \
  --title "v<versão>" \
  --notes-file release-notes.md
```

#### Opção B: Manualmente

1. Acesse: https://github.com/rckbrcls/converge/releases/new
2. Preencha:
   - **Tag**: `v<versão>` (ex: `v1.0.1`)
   - **Title**: `v<versão>`
   - **Description**: Cole as release notes
3. Anexe arquivos:
   - `releases/Converge-<versão>.dmg`
   - `appcast.xml`
4. Clique em "Publish release"

### 5. Verificar Atualizações

Após publicar:
1. O appcast.xml será acessível em: `https://github.com/rckbrcls/converge/releases/latest/download/appcast.xml`
2. Apps instalados verificarão automaticamente atualizações
3. Teste manualmente: Abra o app → Settings → Updates → "Check for Updates"

## Estrutura de Arquivos

```
converge-desktop/
├── scripts/
│   ├── generate-keys.sh          # Gerar chaves EdDSA
│   ├── generate-keys-python.py   # Alternativa Python
│   ├── generate-appcast.sh       # Gerar appcast.xml
│   └── generate-release.sh       # Script completo de release
├── keys/
│   ├── eddsa_private_key.pem     # NUNCA commitar!
│   └── eddsa_public_key.pem      # Pode commitar
├── releases/
│   └── Converge-<versão>.dmg    # DMGs gerados
└── appcast.xml                   # Appcast gerado
```

## Configuração do Sparkle

O Sparkle está configurado no `project.pbxproj`:

- `INFOPLIST_KEY_SUFeedURL`: URL do appcast.xml
- `INFOPLIST_KEY_SUPublicEDKey`: Chave pública EdDSA (adicionar após gerar chaves)

## Troubleshooting

### Erro: "Chave privada não encontrada"
- Execute `./scripts/generate-keys.sh` primeiro

### Erro: "Sparkle tools não encontrado"
- Instale o Sparkle tools ou use `python3 scripts/generate-keys-python.py`

### Erro: "xcodebuild não encontrado"
- Certifique-se de que o Xcode está instalado e no PATH

### Atualizações não funcionam
- Verifique se o `appcast.xml` está acessível publicamente
- Verifique se a chave pública está correta no Info.plist
- Verifique se o DMG está assinado corretamente

### DMG não assina
- Isso é normal em desenvolvimento
- Para produção, use um certificado de desenvolvedor válido
- Configure o código de assinatura no Xcode

## Notas Importantes

1. **Nunca commite a chave privada** (`keys/eddsa_private_key.pem`)
2. **Sempre teste o DMG** antes de publicar
3. **Mantenha o appcast.xml atualizado** com cada release
4. **Use tags semânticas** para versões (v1.0.1, v1.1.0, v2.0.0)
5. **Documente mudanças** nas release notes

## Exemplo de Release Notes

```markdown
## v1.0.1

### Correções
- Corrigido bug no timer que causava crash
- Melhorada performance das notificações

### Melhorias
- Adicionado suporte para temas personalizados
- Interface mais responsiva

### Agradecimentos
Obrigado a todos os contribuidores!
```
