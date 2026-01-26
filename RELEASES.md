# Guia de Releases e Atualizações

Este documento explica como fazer releases e atualizações do app Pomodoro de forma automatizada.

## Visão Geral

O sistema de releases automatiza:
- Incremento de versão (major, minor, patch)
- Build do app em modo Release
- Criação do DMG para distribuição
- Criação de tags Git (opcional)

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

### 4. `release.sh` - Release completo

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

## Integração com CI/CD

Para automatizar releases em CI/CD:

```bash
# Exemplo para GitHub Actions ou similar
./scripts/release.sh patch --skip-git
# Upload do DMG como artifact
```

## Troubleshooting

### Erro: "Device not configured"
Execute os scripts no Terminal do macOS, não no terminal integrado do editor.

### Erro: "App not found"
Certifique-se de que o Xcode está instalado e o projeto compila corretamente.

### Versão não atualiza
Verifique se o arquivo `project.pbxproj` não está bloqueado ou em uso pelo Xcode.

## Próximos Passos

Para distribuição mais avançada, considere:

1. **Assinatura de código** para distribuição fora da App Store
2. **Notarização** do app com Apple
3. **Sparkle** para atualizações automáticas
4. **App Store Connect** para distribuição via Mac App Store
