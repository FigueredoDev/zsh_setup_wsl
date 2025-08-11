#!/bin/bash
# ============================================================================
# Instalação de Linguagens de Desenvolvimento
# ============================================================================

# Função para instalar Node.js via NVM
install_nodejs() {
    local node_version="${DEFAULT_NODE_VERSION:-lts}"
    
    if command_exists nvm; then
        log_info "Instalando Node.js $node_version via NVM..."
        
        # Carregar NVM no shell atual
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Instalar versão LTS se não especificada
        if [[ "$node_version" == "lts" || "$node_version" == "latest" ]]; then
            nvm install --lts
            nvm use --lts
            nvm alias default node
        else
            nvm install "$node_version"
            nvm use "$node_version"
            nvm alias default "$node_version"
        fi
        
        log_info "Node.js $(node --version) instalado com sucesso"
        log_info "NPM $(npm --version) disponível"
    else
        log_error "NVM não encontrado. Instalando Node.js via apt..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
}

# Função para instalar Python via Pyenv
install_python() {
    local python_version="$DEFAULT_PYTHON_VERSION"
    
    if command_exists pyenv; then
        # Configurar variáveis
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        
        # Se não há versão definida, buscar a mais recente estável (não dev/rc)
        if [[ -z "$python_version" ]]; then
            log_info "Buscando versão Python mais recente estável..."
            python_version=$(pyenv install --list | grep -E "^  [0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
            log_info "Versão encontrada: $python_version"
        fi
        
        log_info "Instalando Python $python_version via Pyenv..."
        
        # Instalar Python se não estiver instalado
        if ! pyenv versions | grep -q "$python_version"; then
            pyenv install "$python_version"
        fi
        
        # Definir como versão global
        pyenv global "$python_version"
        
        log_info "Python $(python --version) instalado com sucesso"
        log_info "Pip $(pip --version) disponível"
        
        # Atualizar pip e instalar ferramentas essenciais
        pip install --upgrade pip setuptools wheel
        pip install virtualenv pipenv poetry
    else
        log_error "Pyenv não encontrado. Usando Python do sistema..."
    fi
}

# Função para instalar Java via SDKMAN
install_java() {
    local java_version="$DEFAULT_JAVA_VERSION"
    
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
        # Carregar SDKMAN
        export SDKMAN_DIR="$HOME/.sdkman"
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        
        # Se não há versão definida, buscar a versão LTS mais recente
        if [[ -z "$java_version" ]]; then
            log_info "Buscando versão Java LTS mais recente..."
            # Buscar a versão LTS mais recente (geralmente Amazon Corretto ou Temurin)
            java_version=$(sdk list java | grep -E "(tem|amzn)" | grep -v "rc\|ea\|preview" | head -1 | awk '{print $6}')
            if [[ -z "$java_version" ]]; then
                # Fallback para qualquer versão estável
                java_version=$(sdk list java | grep -v "rc\|ea\|preview" | head -1 | awk '{print $6}')
            fi
            log_info "Versão encontrada: $java_version"
        fi
        
        log_info "Instalando Java $java_version via SDKMAN..."
        
        # Instalar Java
        sdk install java "$java_version"
        sdk default java "$java_version"
        
        # Instalar ferramentas adicionais do ecossistema Java
        sdk install gradle
        sdk install maven
        sdk install kotlin
        sdk install scala
        
        log_info "Java $(java -version 2>&1 | head -n1) instalado com sucesso"
    else
        log_error "SDKMAN não encontrado. Instalando OpenJDK via apt..."
        sudo apt install -y default-jdk
    fi
}

# Função para configurar ferramentas adicionais via ASDF
install_asdf_tools() {
    if command_exists asdf; then
        log_info "Configurando ferramentas via ASDF..."
        
        # Carregar ASDF
        . "$HOME/.asdf/asdf.sh"
        
        # Adicionar plugins úteis
        asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git 2>/dev/null || true
        asdf plugin add rust https://github.com/code-lever/asdf-rust.git 2>/dev/null || true
        asdf plugin add deno https://github.com/asdf-community/asdf-deno.git 2>/dev/null || true
        
        # Instalar versões mais recentes (opcional)
        # asdf install ruby latest
        # asdf install rust latest
        # asdf install deno latest
        
        log_info "Plugins ASDF configurados (instalação manual das versões)"
    else
        log_error "ASDF não encontrado"
    fi
}

# Função para instalar ferramentas globais do Node.js
install_node_global_packages() {
    if command_exists npm; then
        log_info "Instalando pacotes globais do Node.js..."
        
        local packages=(
            "typescript"
            "ts-node"
            "@types/node"
            "nodemon"
            "pm2"
            "yarn"
            "pnpm"
            "nx"
            "vite"
            "eslint"
            "prettier"
            "jest"
            "cypress"
        )
        
        for package in "${packages[@]}"; do
            if ! npm list -g "$package" >/dev/null 2>&1; then
                log_info "Instalando $package..."
                npm install -g "$package"
            else
                log_info "$package já está instalado"
            fi
        done
    fi
}

# Função principal
main() {
    log_info "Iniciando instalação de linguagens de desenvolvimento..."
    
    # Instalar linguagens principais
    install_nodejs
    install_python
    install_java
    
    # Configurar ferramentas via ASDF
    install_asdf_tools
    
    # Instalar ferramentas globais
    install_node_global_packages
    
    log_info "Linguagens de desenvolvimento configuradas com sucesso!"
    log_info "Execute 'source ~/.zshrc' para carregar todas as configurações."
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 