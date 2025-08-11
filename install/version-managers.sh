#!/bin/bash
# ============================================================================
# Instalação de Gerenciadores de Versão
# ============================================================================

# Função para instalar NVM (Node Version Manager)
install_nvm() {
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_info "Instalando NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # Carregar NVM no shell atual
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    else
        log_info "NVM já está instalado"
    fi
}

# Função para instalar Pyenv
install_pyenv() {
    if [[ ! -d "$HOME/.pyenv" ]]; then
        log_info "Instalando Pyenv..."
        curl https://pyenv.run | bash
        
        # Configurar variáveis de ambiente
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    else
        log_info "Pyenv já está instalado"
        
        # Atualizar pyenv
        log_info "Atualizando Pyenv..."
        cd "$HOME/.pyenv" && git pull
    fi
}

# Função para instalar SDKMAN
install_sdkman() {
    if [[ ! -d "$HOME/.sdkman" ]]; then
        log_info "Instalando SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        
        # Carregar SDKMAN no shell atual
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        log_info "SDKMAN já está instalado"
    fi
}

# Função para instalar ASDF
install_asdf() {
    if [[ ! -d "$HOME/.asdf" ]]; then
        log_info "Instalando ASDF..."
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
        
        # Carregar ASDF no shell atual
        . "$HOME/.asdf/asdf.sh"
        . "$HOME/.asdf/completions/asdf.bash"
    else
        log_info "ASDF já está instalado"
        
        # Atualizar ASDF
        log_info "Atualizando ASDF..."
        cd "$HOME/.asdf" && git fetch && git checkout "$(git describe --tags --abbrev=0)"
    fi
}

# Função para instalar PHPenv
install_phpenv() {
    if [[ ! -d "$HOME/.phpenv" ]]; then
        log_info "Instalando PHPenv..."
        curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash
        
        # Configurar variáveis de ambiente
        export PATH="$HOME/.phpenv/bin:$PATH"
        eval "$(phpenv init -)"
    else
        log_info "PHPenv já está instalado"
    fi
}

# Função para instalar Bun
install_bun() {
    if ! command_exists bun; then
        log_info "Instalando Bun..."
        curl -fsSL https://bun.sh/install | bash
        
        # Configurar PATH
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    else
        log_info "Bun já está instalado"
        
        # Atualizar Bun
        log_info "Atualizando Bun..."
        bun upgrade
    fi
}

# Função para instalar Golang manualmente (versão mais recente)
install_golang() {
    local go_version="$DEFAULT_GO_VERSION"
    local go_install_dir="/usr/local/go"
    
    # Se não há versão definida, buscar a mais recente
    if [[ -z "$go_version" ]]; then
        log_info "Buscando versão Go mais recente..."
        go_version=$(curl -s https://go.dev/VERSION?m=text | sed 's/go//')
        if [[ -z "$go_version" ]]; then
            # Fallback caso a API não funcione
            go_version="1.22.0"
            log_warning "Não foi possível buscar versão mais recente, usando fallback: $go_version"
        else
            log_info "Versão encontrada: $go_version"
        fi
    fi
    
    if [[ ! -d "$go_install_dir" ]] || [[ ! $(go version 2>/dev/null) =~ $go_version ]]; then
        log_info "Instalando Go $go_version..."
        
        # Remover instalação anterior se existir
        sudo rm -rf "$go_install_dir"
        
        # Download e instalação
        local go_tar="go${go_version}.linux-amd64.tar.gz"
        wget -O "/tmp/$go_tar" "https://golang.org/dl/$go_tar"
        sudo tar -C /usr/local -xzf "/tmp/$go_tar"
        rm "/tmp/$go_tar"
        
        # Configurar variáveis de ambiente
        export GOROOT="$go_install_dir"
        export GOPATH="$HOME/go"
        export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
        
        # Criar diretório GOPATH
        mkdir -p "$GOPATH"
    else
        log_info "Go já está instalado"
    fi
}

# Função principal
main() {
    log_info "Iniciando instalação de gerenciadores de versão..."
    
    # Instalar gerenciadores
    install_nvm
    install_pyenv
    install_sdkman
    install_asdf
    install_phpenv
    install_bun
    install_golang
    
    log_info "Gerenciadores de versão instalados com sucesso!"
    log_info "Reinicie o terminal para que todas as variáveis de ambiente sejam carregadas."
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 