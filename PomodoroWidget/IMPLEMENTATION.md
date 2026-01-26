# Implementação do Widget - Resumo

## Arquivos Criados

### 1. WidgetDataManager.swift
Gerencia a leitura/escrita de dados compartilhados via App Group entre o app principal e a extensão do widget.

**Funcionalidades:**
- Salva estado do timer no UserDefaults compartilhado
- Carrega estado do timer do UserDefaults compartilhado
- Calcula tempo restante baseado no timestamp da última atualização

### 2. PomodoroWidgetTimelineProvider.swift
Implementa o `TimelineProvider` que fornece entradas de timeline para o widget.

**Funcionalidades:**
- Fornece snapshot para previews
- Fornece timeline com atualizações inteligentes:
  - Atualiza a cada segundo quando o timer está rodando
  - Atualiza a cada minuto quando o timer está pausado
- Calcula quando o timer terminará e agenda atualização

### 3. PomodoroWidgetView.swift
Contém as views do widget para diferentes tamanhos.

**Tamanhos implementados:**
- **Small**: Tempo restante, ícone da fase, status
- **Medium**: Tempo restante grande, progresso circular, pomodoros completados
- **Large**: Todos os elementos do medium + estatísticas adicionais

**Características:**
- Cores dinâmicas baseadas na fase (work=vermelho, break=azul, idle=cinza)
- Indicador visual de status (running/paused)
- Progresso circular animado
- Suporte a dark/light mode

### 4. PomodoroWidget.swift
Widget principal com configuração.

**Configuração:**
- Nome: "Pomodoro Timer"
- Descrição: "View your Pomodoro timer status and progress."
- Tamanhos suportados: Small, Medium, Large

## Modificações em Arquivos Existentes

### PomodoroTimer.swift
Adicionada sincronização automática com o widget.

**Mudanças:**
- Importado `WidgetKit`
- Adicionadas propriedades para App Group
- Método `syncToWidget()` que:
  - Salva estado atual no UserDefaults compartilhado
  - Recarrega timelines do widget
- Chamadas a `syncToWidget()` em:
  - `init()` - estado inicial
  - `start()` - quando inicia
  - `pause()` - quando pausa
  - `reset()` - quando reseta
  - `tick()` - a cada segundo quando rodando
  - `advanceToNextPhase()` - quando muda de fase

## Fluxo de Dados

```
App Principal (PomodoroTimer)
    ↓ syncToWidget()
UserDefaults (App Group: group.polterware.pomodoro.shared)
    ↓ TimelineProvider lê
Widget Extension (PomodoroWidgetView)
```

## App Group Configuration

**Identifier:** `group.polterware.pomodoro.shared`

Este App Group deve ser configurado em:
1. Target principal `pomodoro` → Signing & Capabilities → App Groups
2. Target `PomodoroWidget` → Signing & Capabilities → App Groups

## Estratégia de Atualização

O widget usa uma estratégia inteligente de atualização:

1. **Timer rodando**: Atualiza a cada segundo (até o timer terminar)
2. **Timer pausado**: Atualiza a cada minuto
3. **Mudança de estado**: Atualização imediata via `WidgetCenter.shared.reloadTimelines()`

Isso balanceia precisão com eficiência de bateria.

## Limitações Conhecidas

1. **Widgets não podem iniciar/pausar timer**: Limitação do WidgetKit no macOS - widgets são somente leitura
2. **Atualizações não são em tempo real perfeito**: Widgets têm limitações de atualização do sistema
3. **Cálculo de tempo**: O widget calcula o tempo restante baseado no timestamp, mas pode haver pequenas diferenças devido a atualizações assíncronas

## Próximos Passos

1. Adicionar o target da extensão no Xcode (ver README.md)
2. Configurar App Groups em ambos os targets
3. Build e testar o widget
4. Verificar sincronização de dados
5. Ajustar frequência de atualização se necessário
