#!/bin/bash
# ============================================================================
# Setup ZSH e Oh My Zsh
# ============================================================================

# Função para instalar Oh My Zsh
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_info "Oh My Zsh já está instalado"
        
        if [[ "${SKIP_OH_MY_ZSH_UPDATE:-false}" == "false" ]]; then
            log_info "Atualizando Oh My Zsh..."
            cd "$HOME/.oh-my-zsh" && git pull origin master
        fi
    fi
}

# Função para configurar ZSH como shell padrão
set_zsh_default() {
    log_info "Configurando ZSH como shell padrão..."
    
    # Verificar se ZSH já é o shell padrão
    if [[ "$SHELL" != */zsh ]]; then
        # Adicionar ZSH aos shells válidos se não estiver
        if ! grep -q "$(which zsh)" /etc/shells; then
            echo "$(which zsh)" | sudo tee -a /etc/shells
        fi
        
        # Mudar shell padrão
        chsh -s "$(which zsh)"
        log_info "ZSH configurado como shell padrão. Reinicie o terminal para aplicar."
    else
        log_info "ZSH já é o shell padrão"
    fi
}

# Função para fazer backup do .zshrc existente
backup_zshrc() {
    if [[ -f "$HOME/.zshrc" ]]; then
        backup_file "$HOME/.zshrc"
    fi
}

# Função principal
main() {
    log_info "Iniciando configuração do ZSH..."
    
    # Fazer backup do .zshrc existente
    backup_zshrc
    
    # Instalar Oh My Zsh
    install_oh_my_zsh
    
    # Configurar ZSH como padrão
    set_zsh_default
    
    log_info "Configuração básica do ZSH concluída!"
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 