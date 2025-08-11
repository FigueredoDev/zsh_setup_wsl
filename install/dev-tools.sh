#!/bin/bash
# ============================================================================
# Instalação de Ferramentas de Desenvolvimento
# ============================================================================

# Função para instalar Console Ninja
install_console_ninja() {
    if [[ "${INSTALL_OPTIONAL_TOOLS:-true}" == "true" ]]; then
        if ! command_exists console-ninja; then
            log_info "Instalando Console Ninja..."
            npm install -g console-ninja
            
            # Adicionar ao PATH se não estiver
            if [[ ! -d ~/.console-ninja/.bin ]]; then
                mkdir -p ~/.console-ninja/.bin
            fi
            
            log_info "Console Ninja instalado com sucesso"
        else
            log_info "Console Ninja já está instalado"
        fi
    fi
}

# Função para instalar Gemini CLI
install_gemini_cli() {
    if [[ "${INSTALL_OPTIONAL_TOOLS:-true}" == "true" ]]; then
        if ! command_exists gemini; then
            log_info "Instalando Gemini CLI..."
            
            if command_exists npm; then
                npm install -g @google/gemini-cli
                log_info "Gemini CLI instalado com sucesso"
            else
                log_error "NPM não encontrado. Instale primeiro o Node.js"
            fi
        else
            log_info "Gemini CLI já está instalado"
        fi
    fi
}

# Função para instalar Docker (opcional para desenvolvimento)
install_docker() {
    if [[ "${INSTALL_DOCKER:-false}" == "true" ]]; then
        if ! command_exists docker; then
            log_info "Instalando Docker..."
            
            # Adicionar chave GPG oficial do Docker
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            
            # Adicionar repositório
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # Instalar Docker
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            
            # Adicionar usuário ao grupo docker
            sudo usermod -aG docker $USER
            
            log_info "Docker instalado. Reinicie o terminal para usar sem sudo."
        else
            log_info "Docker já está instalado"
        fi
    fi
}

# Função para instalar VS Code (opcional)
install_vscode() {
    if [[ "${INSTALL_VSCODE:-false}" == "true" ]]; then
        if ! command_exists code; then
            log_info "Instalando Visual Studio Code..."
            
            # Adicionar repositório da Microsoft
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            
            # Instalar
            sudo apt update
            sudo apt install -y code
            
            log_info "Visual Studio Code instalado"
        else
            log_info "Visual Studio Code já está instalado"
        fi
    fi
}

# Função para configurar GPG
configure_gpg() {
    log_info "Configurando GPG..."
    
    # Verificar se já existem chaves
    if ! gpg --list-secret-keys --keyid-format LONG | grep -q "sec"; then
        log_info "Nenhuma chave GPG encontrada. Configure manualmente com:"
        log_info "gpg --full-generate-key"
    else
        log_info "Chaves GPG já configuradas"
    fi
    
    # Configurar GPG_TTY
    export GPG_TTY=$(tty)
}

# Função para instalar utilitários adicionais de desenvolvimento
install_dev_utilities() {
    log_info "Instalando utilitários de desenvolvimento..."
    
    local utilities=(
        bat          # Melhor replacement para cat
        exa          # Melhor replacement para ls
        fd-find      # Melhor replacement para find
        ripgrep      # Melhor replacement para grep
        fzf          # Fuzzy finder
        tldr         # Simplified man pages
        httpie       # HTTP client
        gh           # GitHub CLI
        tig          # Git interface
    )
    
    for utility in "${utilities[@]}"; do
        if ! dpkg -s "$utility" >/dev/null 2>&1; then
            log_info "Instalando $utility..."
            sudo apt install -y "$utility"
        else
            log_info "$utility já está instalado"
        fi
    done
}

# Função para criar aliases úteis para os utilitários
create_utility_aliases() {
    log_info "Configurando aliases para utilitários..."
    
    # Estes aliases serão adicionados ao .zshrc
    cat >> /tmp/utility_aliases.sh << 'EOF'
# Aliases para utilitários modernos
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias catp='bat -p'  # plain output
fi

if command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias ll='exa -l'
    alias la='exa -la'
    alias tree='exa --tree'
fi

if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi

if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
fi

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Outros aliases úteis
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
EOF
}

# Função principal
main() {
    log_info "Iniciando instalação de ferramentas de desenvolvimento..."
    
    # Instalar ferramentas específicas
    install_console_ninja
    install_gemini_cli
    configure_gpg
    
    # Instalar utilitários de desenvolvimento
    install_dev_utilities
    create_utility_aliases
    
    # Instalar ferramentas opcionais (se habilitadas)
    install_docker
    install_vscode
    
    log_info "Ferramentas de desenvolvimento instaladas com sucesso!"
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 