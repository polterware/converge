# Configuração do Widget Extension

Este diretório contém os arquivos necessários para o Widget Extension do Pomodoro. Para completar a configuração, você precisa adicionar o target da extensão no Xcode.

## Passos para Adicionar o Widget Extension no Xcode

### 1. Criar o Target da Extensão

1. Abra o projeto no Xcode
2. Vá em **File → New → Target...**
3. Selecione **Widget Extension** (na seção macOS)
4. Clique em **Next**
5. Configure:
   - **Product Name**: `PomodoroWidget`
   - **Organization Identifier**: `polterware` (ou o mesmo do app principal)
   - **Bundle Identifier**: `polterware.pomodoro.PomodoroWidget`
   - **Language**: Swift
   - **Include Configuration Intent**: ❌ (desmarque)
6. Clique em **Finish**
7. Quando perguntado sobre ativar o scheme, clique em **Activate**

### 2. Configurar App Groups

1. Selecione o target **PomodoroWidget** no projeto
2. Vá na aba **Signing & Capabilities**
3. Clique em **+ Capability**
4. Adicione **App Groups**
5. Adicione o grupo: `group.polterware.pomodoro.shared`
6. Certifique-se de que o mesmo App Group está configurado no target principal **pomodoro**

### 3. Configurar Build Settings

No target **PomodoroWidget**, verifique/configure:

- **Deployment Target**: macOS 11.0 ou superior (para suporte a WidgetKit)
- **Product Bundle Identifier**: `polterware.pomodoro.PomodoroWidget`
- **Development Team**: Mesmo do app principal (`VCF3DS6BTV`)

### 4. Adicionar Arquivos ao Target

1. Selecione todos os arquivos em `PomodoroWidget/`:
   - `PomodoroWidget.swift`
   - `PomodoroWidgetTimelineProvider.swift`
   - `PomodoroWidgetView.swift`
   - `WidgetDataManager.swift`

2. No **File Inspector** (painel direito), certifique-se de que todos estão marcados para o target **PomodoroWidget**

### 5. Remover Arquivos Gerados Automaticamente

O Xcode pode ter criado alguns arquivos automaticamente. Remova ou substitua:
- Se houver um `PomodoroWidgetBundle.swift` gerado automaticamente, você pode removê-lo (o `@main` está em `PomodoroWidget.swift`)

### 6. Verificar Configurações

Certifique-se de que:
- ✅ App Groups está configurado em ambos os targets (app principal e widget)
- ✅ O mesmo App Group identifier é usado: `group.polterware.pomodoro.shared`
- ✅ O deployment target do widget é macOS 11.0+
- ✅ Todos os arquivos Swift estão incluídos no target correto

### 7. Build e Teste

1. Selecione o scheme **PomodoroWidget** no Xcode
2. Build o projeto (⌘B)
3. Execute o widget (⌘R) - isso abrirá o widget no simulador/desktop
4. Para testar no desktop real:
   - Build e execute o app principal primeiro
   - Depois adicione o widget ao desktop (clique com botão direito no desktop → Edit Widgets)

## Estrutura de Arquivos

```
PomodoroWidget/
├── PomodoroWidget.swift              # Widget principal com @main
├── PomodoroWidgetTimelineProvider.swift  # Provider de timeline
├── PomodoroWidgetView.swift          # Views do widget (small, medium, large)
├── WidgetDataManager.swift           # Gerenciador de dados compartilhados
└── README.md                         # Este arquivo
```

## Notas Importantes

- O widget usa App Groups para compartilhar dados com o app principal
- O `PomodoroTimer` no app principal sincroniza automaticamente com o widget
- O widget atualiza a cada segundo quando o timer está rodando
- O widget não pode iniciar/pausar o timer diretamente (limitação do WidgetKit no macOS)

## Troubleshooting

### Widget não aparece
- Verifique se o App Group está configurado corretamente
- Certifique-se de que o deployment target é macOS 11.0+
- Verifique se todos os arquivos estão no target correto

### Widget não atualiza
- Verifique se o `PomodoroTimer` está chamando `syncToWidget()`
- Verifique se o App Group identifier está correto em ambos os targets
- Verifique os logs do console para erros de sincronização

### Erro de compilação
- Certifique-se de que WidgetKit está importado
- Verifique se o deployment target é compatível
- Limpe o build folder (⌘⇧K) e tente novamente
