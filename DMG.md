# Como gerar o DMG do Pomodoro

O DMG é a imagem de disco usada para distribuir o app no macOS.

## Pré-requisitos

- Xcode instalado
- **Execute o script no Terminal do macOS** (Terminal.app ou iTerm), **não** no terminal integrado do Cursor/IDE. O `xcodebuild` e o `hdiutil` podem falhar no sandbox do editor (ex.: "Device not configured" ao criar o DMG).

## Gerar o DMG

```bash
./scripts/create-dmg.sh
```

O DMG será criado em:

```
build/Pomodoro-1.0.dmg
```

### Versão customizada

Passe a versão como argumento:

```bash
./scripts/create-dmg.sh 2.0
```

Resultado: `build/Pomodoro-2.0.dmg`

## O que o script faz

1. Faz **build Release** do app (sem assinatura de código)
2. Cria uma pasta temporária com o `pomodoro.app` e um atalho para **Aplicativos**
3. Gera o DMG com `hdiutil` (formato UDZO, compactado)

## Distribuição com assinatura (opcional)

Para distribuir fora da App Store com assinatura e notarização:

1. No Xcode: **Product → Archive**
2. Em **Organizer**, selecione o archive → **Distribute App** → **Copy App**
3. Use ferramentas como [create-dmg](https://github.com/create-dmg/create-dmg) ou um script próprio para montar o DMG a partir do `.app` exportado.

O script atual gera um DMG **não assinado**, útil para uso local ou testes. Em Macs com Gatekeeper ativo, o usuário pode precisar clicar com botão direito → **Abrir** na primeira execução.
