# Página Web de Download

Esta pasta contém a página web de download do Converge que pode ser hospedada no Vercel ou qualquer outro serviço de hospedagem.

## Arquivos

- `download.html` - Página de download completa com busca automática da última release via GitHub API

## Como Usar

### Opção 1: Vercel

1. Faça deploy da pasta `web/` no Vercel:
   ```bash
   cd web
   vercel deploy
   ```

2. Ou conecte o repositório GitHub ao Vercel e configure o diretório raiz como `web/`

### Opção 2: GitHub Pages

1. Copie `download.html` para a raiz do repositório ou para a branch `gh-pages`
2. Configure GitHub Pages nas configurações do repositório

### Opção 3: Servidor Próprio

1. Faça upload do arquivo `download.html` para seu servidor web
2. Configure o servidor para servir o arquivo como `index.html`

## Funcionalidades

- ✅ Busca automática da última release via GitHub API
- ✅ Download direto do DMG mais recente
- ✅ Exibição da versão atual disponível
- ✅ Tratamento de erros com fallback para GitHub Releases
- ✅ Interface moderna e responsiva
- ✅ Lista de features do app

## Personalização

A página busca automaticamente releases do repositório `rckbrcls/converge`. Para alterar:

1. Edite a constante `GITHUB_REPO` no JavaScript:
   ```javascript
   const GITHUB_REPO = 'seu-usuario/seu-repositorio';
   ```

2. A página procura por assets que terminam com `.dmg` e contêm "Converge" no nome

## Requisitos

- Nenhum! A página é HTML puro com JavaScript vanilla
- Funciona em qualquer navegador moderno
- Não requer build ou compilação
