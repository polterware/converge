# Homebrew Cask for Converge

Este diretório contém a Cask formula do Homebrew para instalar o Converge.

## Opções de Distribuição

### Opção 1: Repositório Homebrew Próprio (Recomendado)

Crie um repositório GitHub chamado `homebrew-converge` e adicione este arquivo:

```bash
# Criar o repositório no GitHub
gh repo create homebrew-converge --public --clone

# Copiar o Cask
cp Casks/converge.rb ~/homebrew-converge/Casks/

# Commit e push
cd ~/homebrew-converge
git add Casks/converge.rb
git commit -m "Add Converge cask"
git push origin main
```

Os usuários instalam com:
```bash
brew tap rckbrcls/converge
brew install --cask converge
```

### Opção 2: Submeter para Homebrew Cask Oficial

1. Fork o repositório [homebrew-cask](https://github.com/Homebrew/homebrew-cask)
2. Adicione o arquivo `converge.rb` em `Casks/`
3. Abra um Pull Request

## Atualizando o Cask

Após cada release:

1. Atualize a `version` no arquivo `converge.rb`
2. Execute o release script para obter o SHA256:
   ```bash
   ./release/release.sh
   ```
3. Atualize o `sha256` no arquivo `converge.rb` com o valor exibido no final do script
4. Commit e push das mudanças

## Estrutura do Cask

- `version`: Versão do app (deve corresponder à tag do GitHub Release)
- `sha256`: Hash SHA256 do arquivo ZIP (calculado automaticamente pelo script de release)
- `url`: URL do GitHub Release
- `app`: Nome do bundle do app
- `zap`: Arquivos de dados do usuário que devem ser removidos ao desinstalar

## Testando Localmente

Para testar o Cask localmente antes de publicar:

```bash
# Instalar do arquivo local
brew install --cask ./Casks/converge.rb

# Verificar informações
brew info --cask converge

# Desinstalar
brew uninstall --cask converge
```
