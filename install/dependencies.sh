#!/bin/bash
# ============================================================================
# Instalação de Dependências do Sistema
# ============================================================================

# Função para atualizar sistema
update_system() {
    log_info "Atualizando sistema..."
    sudo apt update && sudo apt upgrade -y
}

# Função para instalar dependências básicas
install_basic_dependencies() {
    log_info "Instalando dependências básicas..."
    
    local packages=(
        curl
        wget
        git
        zsh
        build-essential
        software-properties-common
        apt-transport-https
        ca-certificates
        gnupg
        lsb-release
        unzip
        zip
        tree
        htop
        neofetch
        jq
        vim
        nano
        # Dependências para compilação
        libssl-dev
        libbz2-dev
        libreadline-dev
        libsqlite3-dev
        libncurses5-dev
        libncursesw5-dev
        xz-utils
        tk-dev
        libffi-dev
        liblzma-dev
        # Dependências do Python
        python3-dev
        python3-pip
        # Dependências XML para PHP
        libxml2-dev
        libxml2-utils
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -s "$package" >/dev/null 2>&1; then
            log_info "Instalando $package..."
            sudo apt install -y "$package"
        else
            log_info "$package já está instalado"
        fi
    done
}

# Função para configurar Git global (se variáveis estiverem definidas)
configure_git() {
    if [[ -n "${GIT_USER_NAME:-}" && -n "${GIT_USER_EMAIL:-}" ]]; then
        log_info "Configurando Git globalmente..."
        git config --global user.name "$GIT_USER_NAME"
        git config --global user.email "$GIT_USER_EMAIL"
        git config --global init.defaultBranch main
        git config --global pull.rebase false
    else
        log_warning "Variáveis GIT_USER_NAME e GIT_USER_EMAIL não definidas. Configure manualmente depois."
    fi
}

# Função principal
main() {
    log_info "Iniciando instalação de dependências do sistema..."
    
    update_system
    install_basic_dependencies
    configure_git
    
    log_info "Dependências do sistema instaladas com sucesso!"
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 