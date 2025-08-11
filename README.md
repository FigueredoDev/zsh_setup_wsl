# 🚀 WSL ZSH Development Environment Setup

Um projeto completo para configurar rapidamente um ambiente de desenvolvimento WSL com ZSH, ferramentas modernas e configurações otimizadas.

## 📋 Índice

- [Recursos](#-recursos)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação Rápida](#-instalação-rápida)
- [Configuração](#-configuração)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Sistema de Versões Inteligente](#-sistema-de-versões-inteligente)
- [Perfis de Instalação](#-perfis-de-instalação)
- [Ferramentas Incluídas](#-ferramentas-incluídas)
- [Aliases Git Configurados](#-aliases-git-configurados)
- [Funções Customizadas](#-funções-customizadas)
- [Manutenção](#-manutenção)
- [Problemas Conhecidos](#-problemas-conhecidos)
- [Contribuição](#-contribuição)

## ✨ Recursos

- **🎯 Perfis Inteligentes**: 4 perfis otimizados (Minimal, Frontend, Backend, Full)
- **⚡ Setup Automatizado**: Instalação completa com um único comando
- **🔄 Versões LTS Automáticas**: Sempre instala as versões mais estáveis por padrão
- **🌟 Ambiente Moderno**: ZSH + Oh My Zsh + temas e plugins otimizados
- **🔧 Gerenciadores de Versão**: NVM, Pyenv, SDKMAN, ASDF, PHPenv, Bun
- **🛠️ Ferramentas Avançadas**: Bat, Exa, Ripgrep, FZF, GitHub CLI
- **🔒 Configurações Seguras**: Variáveis sensíveis via `.env`
- **🤖 Funções IA**: Geração automática de commits e branches com Gemini
- **✅ Validação Completa**: Testes automatizados da instalação
- **📈 Script de Atualização**: Mantenha tudo sempre atualizado

## 🔧 Pré-requisitos

- **Sistema**: WSL2 com Debian/Ubuntu
- **Privilégios**: Acesso sudo
- **Conectividade**: Internet para downloads
- **Espaço**: ~2GB livres

## ⚡ Instalação Rápida

### Instalação Padrão (Completa)
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/zsh-setup.git
cd zsh-setup

# Torne o script executável
chmod +x setup.sh

# Execute o setup completo
./setup.sh
```

### Instalação por Perfil
```bash
# Listar perfis disponíveis
./setup.sh --list-profiles

# Usar perfil específico
./setup.sh --profile frontend    # Para desenvolvimento web
./setup.sh --profile backend     # Para APIs e serviços
./setup.sh --profile minimal     # Setup básico
./setup.sh --profile full        # Instalação completa (padrão)

# Ver todas as opções
./setup.sh --help
```

## ⚙️ Configuração

### 1. Variáveis de Ambiente

Copie o arquivo de exemplo e configure suas variáveis:

```bash
cp .env.example .env
nano .env
```

**Variáveis importantes:**
```env
# Sourcegraph Cody (para funções de commit automático)
SRC_ACCESS_TOKEN=seu_token_aqui

# Git
GIT_USER_NAME="Seu Nome"
GIT_USER_EMAIL="seu.email@exemplo.com"

# Versões específicas (opcional - por padrão usa LTS/mais recente)
# DEFAULT_NODE_VERSION=18              # Se não definido, usa LTS
# DEFAULT_PYTHON_VERSION=3.11.0        # Se não definido, usa a mais recente estável
# DEFAULT_JAVA_VERSION=17.0.8-amzn     # Se não definido, usa LTS
# DEFAULT_GO_VERSION=1.21.0            # Se não definido, usa a mais recente

# Configurações opcionais
INSTALL_DOCKER=true
```

**Notas importantes:**
- **Versões LTS por Padrão**: O sistema instala automaticamente as versões LTS/mais recentes estáveis
- **Controle Opcional**: Defina versões específicas apenas se necessário para compatibilidade
- **Gemini CLI**: Usa sua própria configuração de API key (consulte documentação oficial)
- **VS Code**: Use o VS Code instalado no Windows com a extensão Remote-WSL para melhor performance

### 2. Personalização Local

Use o arquivo `~/.zshrc.local` para configurações específicas:

```bash
# Exemplo de configurações locais
alias projeto="cd ~/meus-projetos"
export CUSTOM_VAR="valor"
```

## 📁 Estrutura do Projeto

```
zsh_setup/
├── setup.sh                 # Script principal
├── .env.example             # Template de variáveis
├── README.md               # Esta documentação
├── config/
│   └── zshrc.template      # Template do .zshrc
├── install/
│   ├── dependencies.sh     # Dependências do sistema
│   ├── zsh-setup.sh       # Configuração ZSH
│   ├── zsh-customization.sh # Temas e plugins
│   ├── version-managers.sh  # Gerenciadores de versão
│   ├── languages.sh        # Linguagens de desenvolvimento
│   ├── dev-tools.sh        # Ferramentas de desenvolvimento
│   ├── final-config.sh     # Configurações finais
│   └── validate.sh         # Validação da instalação
└── test/                   # Testes (futuros)
```

## 🔄 Sistema de Versões Inteligente

O setup instala automaticamente as **versões mais estáveis e recentes** por padrão:

- **Node.js**: Sempre a versão LTS mais recente
- **Python**: Última versão estável (sem dev/rc)  
- **Java**: Versão LTS mais recente (Corretto/Temurin)
- **Go**: Última versão stable oficial

**Controle Manual**: Configure versões específicas no `.env` apenas se necessário para compatibilidade com projetos existentes.

## 🎯 Perfis de Instalação

O setup oferece diferentes perfis otimizados para tipos específicos de desenvolvimento:

### 📦 **Minimal**
- **Ideal para**: Desenvolvimento geral, usuários iniciantes
- **Inclui**: ZSH + Oh My Zsh, Node.js LTS, Git, utilitários básicos
- **Tempo**: ~5 minutos
- **Tamanho**: ~500MB

### 🎨 **Frontend**  
- **Ideal para**: React, Vue, Angular, desenvolvimento web
- **Inclui**: Node.js LTS, Bun, Vite, ferramentas frontend, Docker
- **Extras**: Pacotes NPM específicos, tema Dracula
- **Tempo**: ~7 minutos
- **Tamanho**: ~900MB

### ⚙️ **Backend**
- **Ideal para**: APIs, microservices, desenvolvimento servidor
- **Inclui**: Python, Java, Go, Node.js, Docker, PostgreSQL tools
- **Extras**: HTTPie, ferramentas DevOps, utilitários CLI
- **Tempo**: ~11 minutos
- **Tamanho**: ~1.8GB

### 🚀 **Full**
- **Ideal para**: Desenvolvimento fullstack, usuários avançados
- **Inclui**: Todas as linguagens, ferramentas e utilitários CLI
- **Extras**: Tudo disponível no projeto (apenas ferramentas CLI)
- **Tempo**: ~13 minutos
- **Tamanho**: ~2.5GB

## 🛠️ Ferramentas Incluídas

### Linguagens e Gerenciadores
- **Node.js** (via NVM)
- **Python** (via Pyenv)  
- **Java** (via SDKMAN)
- **Go** (instalação direta)
- **PHP** (via PHPenv)
- **Bun** (runtime JavaScript)

### Ferramentas de Desenvolvimento
- **Git** com aliases úteis (veja seção detalhada abaixo)
- **GitHub CLI** (gh)  
- **Docker** (opcional)
- **Ferramentas CLI** otimizadas para desenvolvimento remoto

### Utilitários Modernos
- **bat**: melhor `cat`
- **exa**: melhor `ls`
- **ripgrep**: melhor `grep`
- **fd**: melhor `find`
- **fzf**: fuzzy finder
- **httpie**: cliente HTTP
- **tig**: interface Git

### ZSH e Oh My Zsh
- **Tema Spaceship**: prompt moderno
- **Tema Dracula**: cores elegantes
- **Plugins**: autosuggestions, syntax highlighting, completions

## 🤖 Funções Customizadas

### Geração de Commits com IA
```bash
# Commit em inglês
ccm

# Commit em português
ccmpt
```

### Criação de Branches
```bash
# Gera nome da branch baseado no diff
cgb
```

### Atualizações
```bash
# Atualiza todo o ambiente
update-dev-env
```

## ⚡ Aliases Git Configurados

O setup configura automaticamente aliases úteis para Git, organizados por categoria:

### Aliases Básicos e Rápidos
```bash
git s          # git status -s (status resumido)
git st         # git status (status completo)  
git c "msg"    # git commit -m "msg" (commit rápido)
git ci         # git commit (commit interativo)
```

### Aliases de Navegação
```bash
git co branch  # git checkout branch (trocar branch)
git cb branch  # git checkout -b branch (criar e trocar)
git br         # git branch (listar branches)
```

### Aliases de Histórico
```bash
git l          # Log colorido e formatado
git lg         # Log gráfico com branches
git last       # Último commit
```

### Aliases de Stash e Limpeza
```bash
git sts        # git stash (salvar mudanças)
git unstage    # git reset HEAD -- (desfazer staging)
```

**💡 Dica**: Todos esses aliases são configurados globalmente e ficam disponíveis em qualquer repositório!

### Configuração de GPG (Opcional)
Se você quiser assinar commits com GPG:
```bash
# Configurar assinatura GPG
git config --global commit.gpgsign true
git config --global user.signingkey SUA_CHAVE_GPG

# Listar chaves disponíveis
gpg --list-secret-keys --keyid-format LONG
```

## 💻 Uso com VS Code

Este setup é otimizado para **uso CLI no WSL**. Para usar VS Code, recomendamos:

### Método Recomendado: VS Code no Windows + Remote-WSL
1. **Instale VS Code no Windows** (não no WSL)
2. **Instale a extensão Remote-WSL** no VS Code
3. **Conecte ao WSL** via Command Palette (`Ctrl+Shift+P` > "Remote-WSL: New Window")

### Vantagens desta Abordagem:
- ✅ **Performance superior** - UI no Windows, processamento no WSL
- ✅ **Integração nativa** - acesso completo ao sistema de arquivos WSL
- ✅ **Extensões funcionam** - todas as extensões funcionam normalmente
- ✅ **Terminal integrado** - usa o ZSH configurado automaticamente
- ✅ **Sem duplicação** - uma única instalação do VS Code

### Configuração Rápida:
```bash
# No WSL, configure o Git editor para VS Code (opcional)
git config --global core.editor "code --wait"

# Abrir projeto atual no VS Code
code .
```

## 🔄 Manutenção

### Validação do Ambiente
```bash
# Execute o script de validação
./install/validate.sh
```

### Atualização Completa
```bash
# Use o script de atualização
update-dev-env
```

### Reinstalação
```bash
# Execute novamente o setup
./setup.sh
```

## 🐛 Problemas Conhecidos

### Erro de Permissão SSH
```bash
# Corrigir permissões SSH
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
```

### ZSH não é o Shell Padrão
```bash
# Configurar manualmente
chsh -s $(which zsh)
```

### Gemini CLI não Funciona
1. Teste: `gemini --help`
2. Se falhar, reinstale: `npm install -g @google/gemini-cli`
3. Configure a API key seguindo a documentação oficial do Gemini CLI

### Versões de Linguagens
```bash
# Instalar versões específicas após o setup (se necessário)

# Node.js - versão específica
nvm install 16.20.0
nvm use 16.20.0

# Python - versão específica
pyenv install 3.9.0
pyenv global 3.9.0

# Java - versão específica
sdk install java 11.0.20-amzn
sdk default java 11.0.20-amzn

# Listar versões disponíveis
nvm list-remote          # Node.js
pyenv install --list     # Python
sdk list java            # Java
```

## 📈 Melhorias Sugeridas

Com base na análise do seu ambiente atual, aqui estão algumas **sugestões de melhorias**:

### 🔒 Segurança
- **Separação de tokens**: Seus tokens sensíveis agora ficam no `.env`
- **GPG**: Setup automático para assinatura de commits (opcional)
- **SSH**: Configuração de permissões corretas

### ⚡ Performance
- **Fast Syntax Highlighting**: Alternativa mais rápida ao plugin padrão
- **Lazy Loading**: Gerenciadores de versão carregados sob demanda
- **Otimização de História**: Configurações melhoradas do histórico ZSH

### 🛠️ Produtividade
- **Utilitários Modernos**: `bat`, `exa`, `ripgrep` com aliases automáticos
- **Git Aliases**: Comandos Git mais rápidos (`gs`, `ga`, `gc`, etc.)
- **Script de Atualização**: Mantenha tudo atualizado facilmente
- **Validação Automática**: Teste se tudo está funcionando

### 🎨 Experiência
- **Configuração Local**: `.zshrc.local` para personalizações
- **Documentação**: README completo com troubleshooting
- **Logging**: Output colorido e logs detalhados durante setup

## 🤝 Contribuição

1. Fork o projeto
2. Crie sua feature branch: `git checkout -b feat/nova-feature`
3. Commit suas mudanças: `git commit -m 'feat: adiciona nova feature'`
4. Push para a branch: `git push origin feat/nova-feature`
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🙏 Agradecimentos

- [Oh My Zsh](https://ohmyz.sh/)
- [Spaceship Prompt](https://spaceship-prompt.sh/)
- [Dracula Theme](https://draculatheme.com/)
- Comunidade ZSH e todos os contribuidores das ferramentas incluídas

---

**💡 Dica**: Após a instalação, reinicie seu terminal e execute `source ~/.zshrc` para carregar todas as configurações! 