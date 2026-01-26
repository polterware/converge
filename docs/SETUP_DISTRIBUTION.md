# Setup de Distribuição e Atualizações

Este guia explica como configurar a distribuição do DMG e o sistema de atualizações automáticas usando GitHub Releases ou Supabase Storage.

## Índice

- [Opção 1: GitHub Releases](#opção-1-github-releases)
- [Opção 2: Supabase Storage](#opção-2-supabase-storage)
- [Configuração do Site Web](#configuração-do-site-web)
- [Fluxo Completo de Release](#fluxo-completo-de-release)

## Opção 1: GitHub Releases

### Pré-requisitos

1. **GitHub CLI instalado:**
   ```bash
   brew install gh
   ```

2. **Autenticar GitHub CLI:**
   ```bash
   gh auth login
   ```

### Configuração Inicial

1. **Verificar repositório remoto:**
   ```bash
   git remote get-url origin
   # Deve retornar algo como: git@github.com:usuario/repo.git
   ```

2. **Configurar variável de ambiente (opcional):**
   ```bash
   export GITHUB_REPO=usuario/repo  # Formato: usuario/repo
   ```

### Fazer um Release

```bash
# 1. Fazer release completo (incrementa versão, cria DMG, gera appcast)
cd desktop
./scripts/release.sh patch  # ou minor, major

# 2. Upload para GitHub Releases
./scripts/upload-to-github.sh

# Ou especificar DMG específico:
./scripts/upload-to-github.sh build/Pomodoro-1.0.dmg
```

### Opções do Script

```bash
# Criar release como draft (não publicado)
./scripts/upload-to-github.sh --draft

# Marcar como pré-release
./scripts/upload-to-github.sh --prerelease
```

### Hospedar Appcast

O appcast precisa ser hospedado separadamente. Opções:

#### Opção A: GitHub Pages

1. Criar branch `gh-pages`:
   ```bash
   git checkout -b gh-pages
   git push -u origin gh-pages
   ```

2. Habilitar GitHub Pages no repositório (Settings > Pages)

3. Fazer upload do appcast:
   ```bash
   # Após gerar appcast com APPCAST_URL_BASE
   export APPCAST_URL_BASE=https://usuario.github.io/repo/releases
   ./scripts/release.sh patch
   
   # Fazer commit e push do appcast
   git add releases/appcast.xml
   git commit -m "Update appcast"
   git push origin gh-pages
   ```

#### Opção B: Vercel/Netlify

1. Fazer deploy do diretório `releases/` como arquivos estáticos
2. Configurar `APPCAST_URL_BASE` para apontar para o deploy

#### Opção C: Supabase Storage (apenas appcast)

Veja seção [Supabase Storage](#opção-2-supabase-storage) abaixo.

### URLs Geradas

- **DMG**: `https://github.com/usuario/repo/releases/download/v1.0/Pomodoro-1.0.dmg`
- **Appcast** (se GitHub Pages): `https://usuario.github.io/repo/releases/appcast.xml`

## Opção 2: Supabase Storage

### Pré-requisitos

1. **Conta no Supabase:**
   - Criar projeto em [supabase.com](https://supabase.com)

2. **Obter credenciais:**
   - Project Settings > API
   - Anotar: `Project URL` e `service_role` key (não a `anon` key!)

### Configuração Inicial

1. **Criar bucket `releases`:**
   - Storage > Create bucket
   - Nome: `releases`
   - Público: ✅ Sim (para downloads públicos)

2. **Configurar variáveis de ambiente:**
   ```bash
   export SUPABASE_URL=https://seu-projeto.supabase.co
   export SUPABASE_SERVICE_KEY=sua-service-role-key-aqui
   export SUPABASE_BUCKET_NAME=releases  # opcional, padrão é "releases"
   ```

   **⚠️ IMPORTANTE:** Use a `service_role` key, não a `anon` key!

### Fazer um Release

```bash
# 1. Fazer release completo
cd desktop
export APPCAST_URL_BASE=https://seu-projeto.supabase.co/storage/v1/object/public/releases
./scripts/release.sh patch

# 2. Upload para Supabase Storage
./scripts/upload-to-supabase.sh

# Ou especificar arquivos:
./scripts/upload-to-supabase.sh build/Pomodoro-1.0.dmg releases/appcast.xml
```

### URLs Geradas

- **DMG**: `https://seu-projeto.supabase.co/storage/v1/object/public/releases/Pomodoro-1.0.dmg`
- **Appcast**: `https://seu-projeto.supabase.co/storage/v1/object/public/releases/appcast.xml`

### Limites do Plano Gratuito

- **Storage**: 1GB
- **Bandwidth**: 2GB/mês
- **File size limit**: 50MB por arquivo

Para apps maiores ou muitos downloads, considere upgrade ou GitHub Releases.

## Configuração do Site Web

### Variáveis de Ambiente

Crie/edite `web/.env.local`:

#### Para GitHub Releases:

```env
# URL direta do DMG (opcional - se não usar, a API buscará automaticamente)
NEXT_PUBLIC_DMG_DOWNLOAD_URL=https://github.com/usuario/repo/releases/download/v1.0/Pomodoro-1.0.dmg

# Para API buscar automaticamente do GitHub
GITHUB_REPO=usuario/repo
GITHUB_TOKEN=ghp_...  # opcional, para rate limit maior
```

#### Para Supabase Storage:

```env
# URL direta do DMG (opcional)
NEXT_PUBLIC_DMG_DOWNLOAD_URL=https://projeto.supabase.co/storage/v1/object/public/releases/Pomodoro-1.0.dmg

# Para API buscar automaticamente do Supabase
SUPABASE_URL=https://projeto.supabase.co
SUPABASE_ANON_KEY=sua-anon-key-aqui
SUPABASE_BUCKET_NAME=releases
```

### Como Funciona

1. **Prioridade de busca:**
   - Se `NEXT_PUBLIC_DMG_DOWNLOAD_URL` estiver configurada, usa ela
   - Senão, tenta buscar do Supabase Storage (se configurado)
   - Senão, tenta buscar do GitHub Releases (se `GITHUB_REPO` configurado)
   - Se nenhum funcionar, mostra "Download coming soon"

2. **API Route:**
   - `GET /api/releases?type=latest` - Retorna URL da versão mais recente
   - `GET /api/releases?type=appcast` - Retorna appcast.xml (apenas Supabase)

## Fluxo Completo de Release

### Com GitHub Releases:

```bash
# 1. Configurar appcast URL
export APPCAST_URL_BASE=https://usuario.github.io/repo/releases

# 2. Fazer release
cd desktop
./scripts/release.sh patch

# 3. Upload DMG para GitHub
./scripts/upload-to-github.sh

# 4. Fazer commit e push do appcast (se usando GitHub Pages)
git add releases/appcast.xml
git commit -m "Update appcast for v1.0"
git push origin gh-pages

# 5. Atualizar variável de ambiente no site (opcional se usar API)
# Editar web/.env.local:
# NEXT_PUBLIC_DMG_DOWNLOAD_URL=https://github.com/usuario/repo/releases/download/v1.0/Pomodoro-1.0.dmg
```

### Com Supabase Storage:

```bash
# 1. Configurar variáveis
export SUPABASE_URL=https://projeto.supabase.co
export SUPABASE_SERVICE_KEY=sua-service-role-key
export APPCAST_URL_BASE=https://projeto.supabase.co/storage/v1/object/public/releases

# 2. Fazer release
cd desktop
./scripts/release.sh patch

# 3. Upload para Supabase (DMG e appcast juntos)
./scripts/upload-to-supabase.sh

# 4. Atualizar variável de ambiente no site (opcional se usar API)
# Editar web/.env.local:
# NEXT_PUBLIC_DMG_DOWNLOAD_URL=https://projeto.supabase.co/storage/v1/object/public/releases/Pomodoro-1.0.dmg
```

## Integração com release.sh

Os scripts de upload podem ser integrados ao `release.sh` para automatizar tudo. Veja [RELEASES.md](RELEASES.md) para mais detalhes.

## Troubleshooting

### GitHub CLI não autenticado

```bash
gh auth login
```

### Supabase: "Bucket not found"

O script tenta criar automaticamente, mas se falhar:
1. Vá em Storage > Create bucket
2. Nome: `releases`
3. Público: ✅ Sim

### Supabase: "Permission denied"

- Certifique-se de usar a `service_role` key, não a `anon` key
- Verifique se o bucket está configurado como público

### API não encontra releases

1. Verifique variáveis de ambiente no `web/.env.local`
2. Verifique se o bucket/repositório tem arquivos
3. Verifique logs do servidor Next.js

### Download não funciona no site

1. Verifique se `NEXT_PUBLIC_DMG_DOWNLOAD_URL` está correta
2. Teste a API: `curl http://localhost:3000/api/releases?type=latest`
3. Verifique console do navegador para erros

## Próximos Passos

1. Configurar Sparkle no app (veja [UPDATES.md](UPDATES.md))
2. Configurar `SUFeedURL` no Info.plist
3. Gerar chaves EdDSA para assinatura
4. Testar atualizações automáticas

## Referências

- [DISTRIBUTION.md](DISTRIBUTION.md) - Ciclo completo de distribuição
- [UPDATES.md](UPDATES.md) - Sistema de atualizações automáticas
- [RELEASES.md](RELEASES.md) - Processo de releases
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
