# Guia de Releases e Atualizações

Este documento explica como fazer releases e atualizações do app Pomodoro de forma automatizada.

> **📚 Documentação Completa**: Para entender todo o ciclo de distribuição desde a primeira instalação até atualizações automáticas, veja [DISTRIBUTION.md](DISTRIBUTION.md)

## Visão Geral

O sistema de releases automatiza:
- Incremento de versão (major, minor, patch)
- Build do app em modo Release
- Criação do DMG para distribuição
- Criação de tags Git (opcional)
- Geração de appcast para atualizações automáticas (opcional)

## Scripts Disponíveis

### 1. `get-version.sh` - Ver versão atual

```bash
./scripts/get-version.sh
# Output: 1.0

./scripts/get-version.sh --build
# Output: 1.0
# Build: 1
```

### 2. `increment-version.sh` - Incrementar versão

Incrementa a versão no arquivo `project.pbxproj`:

```bash
# Incremento patch (1.0.0 -> 1.0.1, incrementa build number)
./scripts/increment-version.sh patch

# Incremento minor (1.0.0 -> 1.1.0)
./scripts/increment-version.sh minor

# Incremento major (1.0.0 -> 2.0.0)
./scripts/increment-version.sh major
```

**Nota:** O build number sempre incrementa, independente do tipo.

### 3. `create-dmg.sh` - Criar DMG

Cria o DMG do app (já existente):

```bash
# Usa versão do projeto
./scripts/create-dmg.sh

# Versão customizada
./scripts/create-dmg.sh 2.0
```

### 4. `generate-appcast.sh` - Gerar Appcast

Gera ou atualiza o appcast.xml para atualizações automáticas:

```bash
# Gerar appcast com URL base
./scripts/generate-appcast.sh https://seu-dominio.com/releases

# Especificar DMG específico
./scripts/generate-appcast.sh https://seu-dominio.com/releases build/Pomodoro-1.0.dmg
```

**Nota**: O script tenta usar assinatura EdDSA automaticamente se as chaves estiverem configuradas.

### 5. `generate-keys.sh` - Gerar Chaves EdDSA

Gera par de chaves EdDSA para assinatura de atualizações:

```bash
./scripts/generate-keys.sh
```

Isso cria `keys/eddsa_private_key.pem` e `keys/eddsa_public_key.pem`. A chave pública deve ser adicionada ao Info.plist.

### 6. `sign-dmg.sh` - Assinar DMG

Assina o DMG com chave EdDSA para atualizações Sparkle:

```bash
# Assinar DMG mais recente
./scripts/sign-dmg.sh

# Assinar DMG específico
./scripts/sign-dmg.sh build/Pomodoro-1.0.dmg
```

### 7. `release.sh` - Release completo

Script principal que faz tudo automaticamente:

```bash
# Release patch (recomendado para correções)
./scripts/release.sh patch

# Release minor (novas funcionalidades)
./scripts/release.sh minor

# Release major (mudanças significativas)
./scripts/release.sh major
```

**Opções:**
- `--skip-version`: Não incrementa a versão (usa a atual)
- `--skip-git`: Não faz commit nem cria tag

**Com atualizações automáticas:**

```bash
# Configurar URL do appcast
export APPCAST_URL_BASE=https://seu-dominio.com/releases

# Fazer release (gera appcast automaticamente)
./scripts/release.sh patch
```

**Exemplos:**
```bash
# Release sem incrementar versão
./scripts/release.sh patch --skip-version

# Release sem operações Git
./scripts/release.sh minor --skip-git

# Apenas criar DMG da versão atual
./scripts/release.sh patch --skip-version --skip-git
```

## Fluxo de Release Recomendado

### Release Normal

1. **Desenvolver e testar** as mudanças
2. **Fazer commit** das mudanças de código
3. **Executar release:**
   ```bash
   ./scripts/release.sh patch  # ou minor/major
   ```
4. **Revisar** o DMG gerado em `build/Pomodoro-X.X.dmg`
5. **Push das tags** (se necessário):
   ```bash
   git push origin v1.0
   ```

### Release com Atualizações Automáticas

1. **Configurar URL do appcast:**
   ```bash
   export APPCAST_URL_BASE=https://seu-dominio.com/releases
   ```

2. **Fazer release:**
   ```bash
   ./scripts/release.sh patch
   ```

3. **Fazer upload:**
   - DMG: `build/Pomodoro-X.X.dmg` → servidor
   - Appcast: `releases/appcast.xml` → servidor

4. **Configurar Sparkle no app** (veja `UPDATES.md`)

### Release Rápido (sem Git)

Para testes locais ou builds rápidos:

```bash
./scripts/release.sh patch --skip-git
```

## Estrutura de Versões

O projeto usa duas versões:

- **MARKETING_VERSION** (ex: `1.0`): Versão pública, visível ao usuário
- **CURRENT_PROJECT_VERSION** (ex: `1`): Build number, incrementa a cada build

### Convenção de Versionamento

- **Patch** (`1.0.0 -> 1.0.1`): Correções de bugs, pequenas melhorias
- **Minor** (`1.0.0 -> 1.1.0`): Novas funcionalidades, compatibilidade mantida
- **Major** (`1.0.0 -> 2.0.0`): Mudanças significativas, possíveis breaking changes

## Localização dos Artefatos

Após um release, você encontrará:

- **DMG**: `build/Pomodoro-X.X.dmg`
- **App**: `build/DerivedData/Build/Products/Release/pomodoro.app`
- **Appcast** (se configurado): `releases/appcast.xml`

## Atualizações Automáticas

Para configurar atualizações automáticas usando Sparkle, veja o arquivo **`UPDATES.md`** para instruções completas.

Resumo rápido:
1. Adicionar Sparkle framework ao projeto
2. Configurar `SUFeedURL` no Info.plist
3. Gerar chaves EdDSA para assinatura
4. Fazer upload do appcast e DMGs para servidor
5. Os usuários receberão atualizações automaticamente!

## Integração com CI/CD

Para automatizar releases em CI/CD:

```bash
# Exemplo para GitHub Actions ou similar
export APPCAST_URL_BASE=https://seu-dominio.com/releases
./scripts/release.sh patch --skip-git
# Upload do DMG e appcast como artifacts
```

## Troubleshooting

### Erro: "Device not configured"
Execute os scripts no Terminal do macOS, não no terminal integrado do editor.

### Erro: "App not found"
Certifique-se de que o Xcode está instalado e o projeto compila corretamente.

### Versão não atualiza
Verifique se o arquivo `project.pbxproj` não está bloqueado ou em uso pelo Xcode.

### Appcast não gera
Verifique se `APPCAST_URL_BASE` está configurado e se o DMG existe.

## Próximos Passos

Para distribuição mais avançada, considere:

1. **Sparkle** para atualizações automáticas (veja [UPDATES.md](UPDATES.md))
2. **Assinatura de código** para distribuição fora da App Store
3. **Notarização** do app com Apple
4. **App Store Connect** para distribuição via Mac App Store

## Referências

- [DISTRIBUTION.md](DISTRIBUTION.md): Ciclo completo de distribuição e atualizações
- [DMG.md](DMG.md): Como criar DMG
- [UPDATES.md](UPDATES.md): Configuração do Sparkle
