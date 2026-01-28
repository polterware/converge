# Release Scripts

Scripts automatizados para criar e publicar releases do Converge no GitHub.

## Pré-requisitos

1. **Xcode** instalado e configurado
2. **GitHub CLI (gh)** instalado e autenticado:
   ```bash
   brew install gh
   gh auth login
   ```
3. **Chave EdDSA privada** para assinar atualizações Sparkle:
   - Deve estar em `keys/eddsa_private_key.pem`
   - Para gerar novas chaves, use as ferramentas do Sparkle

## Uso

### Release Completo

Para fazer um release completo (build + DMG + GitHub):

```bash
./scripts/release.sh
```

### Opções

O script suporta as seguintes opções:

- `--skip-build`: Pula o build (usa app já existente em `releases/export/`)
- `--skip-dmg`: Pula a criação do DMG (usa DMG já existente)
- `--skip-release`: Pula a criação do release no GitHub (útil para testar)

### Exemplos

```bash
# Apenas criar DMG sem publicar
./scripts/release.sh --skip-release

# Publicar release usando DMG existente
./scripts/release.sh --skip-build --skip-dmg

# Rebuild e republicar
./scripts/release.sh --skip-dmg
```

## O que o script faz

1. **Verifica dependências**: Xcode, GitHub CLI, chaves EdDSA
2. **Obtém versão**: Lê versão do `project.pbxproj`
3. **Build**: Compila o app usando `xcodebuild archive`
4. **Exporta**: Exporta o app do archive
5. **Cria DMG**: Gera arquivo DMG para distribuição
6. **Assina**: Assina o DMG com EdDSA (se chave disponível)
7. **Cria Release**: Cria release no GitHub via `gh release create`
8. **Atualiza Appcast**: Atualiza `appcast.xml` com nova versão
9. **Upload Appcast**: Faz upload do `appcast.xml` para o release

## Configuração

### Repositório GitHub

O script está configurado para usar `rckbrcls/converge`. Se seu repositório for diferente, edite a variável `GITHUB_REPO` no script:

```bash
GITHUB_REPO="seu-usuario/seu-repositorio"
```

### Chaves EdDSA

Para gerar novas chaves EdDSA para assinar atualizações:

1. Baixe o Sparkle framework
2. Use a ferramenta `sign_update`:
   ```bash
   sparkle/bin/sign_update --generate-keys
   ```
3. Salve a chave privada em `keys/eddsa_private_key.pem`
4. Adicione a chave pública ao `Info.plist` do projeto (`INFOPLIST_KEY_SUPublicEDKey`)

## Estrutura de Arquivos

```
scripts/
├── release.sh           # Script principal de release
├── ExportOptions.plist  # Configuração de exportação do Xcode
└── README.md           # Este arquivo

releases/
├── Converge.xcarchive  # Archive do build
├── export/             # App exportado
└── Converge-X.X.X.dmg # DMG final

keys/
└── eddsa_private_key.pem # Chave privada EdDSA (não commitada)
```

## Troubleshooting

### Erro: "xcodebuild not found"
- Instale o Xcode Command Line Tools: `xcode-select --install`

### Erro: "GitHub CLI not authenticated"
- Execute: `gh auth login`

### Erro: "EdDSA private key not found"
- O script continuará, mas o DMG não será assinado
- Sparkle updates podem não funcionar corretamente sem assinatura

### Erro: "sign_update tool not found"
- O Sparkle precisa estar disponível via SPM ou instalado localmente
- O script tentará encontrar automaticamente

### Release já existe
- O script deleta e recria releases existentes com a mesma tag
- Certifique-se de que não há releases importantes antes de executar

## Notas

- O script usa `xcodebuild` com `-allowProvisioningUpdates` para atualizar automaticamente os perfis de provisionamento
- O DMG é criado com formato UDZO (compressão)
- O appcast.xml é atualizado automaticamente com a nova versão
- Releases são criados como drafts por padrão (pode ser alterado no script)
