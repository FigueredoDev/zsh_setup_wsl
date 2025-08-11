#!/bin/bash
# ============================================================================
# Customização ZSH - Temas e Plugins
# ============================================================================

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Função para instalar tema Spaceship
install_spaceship_theme() {
    local theme_dir="$ZSH_CUSTOM/themes/spaceship-prompt"
    
    if [[ ! -d "$theme_dir" ]]; then
        log_info "Instalando tema Spaceship..."
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$theme_dir" --depth=1
        ln -sf "$theme_dir/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    else
        log_info "Tema Spaceship já está instalado"
        log_info "Atualizando tema Spaceship..."
        cd "$theme_dir" && git pull
    fi
}

# Função para instalar tema Dracula
install_dracula_theme() {
    local theme_dir="$ZSH_CUSTOM/themes/dracula"
    
    if [[ ! -d "$theme_dir" ]]; then
        log_info "Instalando tema Dracula..."
        git clone https://github.com/dracula/zsh.git "$theme_dir"
        ln -sf "$theme_dir/dracula.zsh-theme" "$ZSH_CUSTOM/themes/dracula.zsh-theme"
    else
        log_info "Tema Dracula já está instalado"
        log_info "Atualizando tema Dracula..."
        cd "$theme_dir" && git pull
    fi
}

# Função para instalar Dracula syntax highlighting
install_dracula_syntax_highlighting() {
    local syntax_dir="$ZSH_CUSTOM/themes/dracula-zsh-syntax-highlighting"
    
    if [[ ! -d "$syntax_dir" ]]; then
        log_info "Instalando Dracula syntax highlighting..."
        git clone https://github.com/dracula/zsh-syntax-highlighting.git "$syntax_dir"
    else
        log_info "Dracula syntax highlighting já está instalado"
        log_info "Atualizando Dracula syntax highlighting..."
        cd "$syntax_dir" && git pull
    fi
}

# Função para instalar plugins essenciais
install_zsh_plugins() {
    local plugins_dir="$ZSH_CUSTOM/plugins"
    
    # zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        log_info "Instalando plugin zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    else
        log_info "Plugin zsh-autosuggestions já está instalado"
        cd "$plugins_dir/zsh-autosuggestions" && git pull
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        log_info "Instalando plugin zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    else
        log_info "Plugin zsh-syntax-highlighting já está instalado"
        cd "$plugins_dir/zsh-syntax-highlighting" && git pull
    fi
    
    # zsh-completions
    if [[ ! -d "$plugins_dir/zsh-completions" ]]; then
        log_info "Instalando plugin zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions "$plugins_dir/zsh-completions"
    else
        log_info "Plugin zsh-completions já está instalado"
        cd "$plugins_dir/zsh-completions" && git pull
    fi
    
    # fast-syntax-highlighting (alternativa mais rápida)
    if [[ ! -d "$plugins_dir/fast-syntax-highlighting" ]]; then
        log_info "Instalando plugin fast-syntax-highlighting..."
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$plugins_dir/fast-syntax-highlighting"
    else
        log_info "Plugin fast-syntax-highlighting já está instalado"
        cd "$plugins_dir/fast-syntax-highlighting" && git pull
    fi
    
    # zsh-history-substring-search
    if [[ ! -d "$plugins_dir/zsh-history-substring-search" ]]; then
        log_info "Instalando plugin zsh-history-substring-search..."
        git clone https://github.com/zsh-users/zsh-history-substring-search "$plugins_dir/zsh-history-substring-search"
    else
        log_info "Plugin zsh-history-substring-search já está instalado"
        cd "$plugins_dir/zsh-history-substring-search" && git pull
    fi
}

# Função principal
main() {
    log_info "Iniciando instalação de temas e plugins..."
    
    # Criar diretório custom se não existir
    mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"
    
    # Instalar temas
    install_spaceship_theme
    install_dracula_theme
    install_dracula_syntax_highlighting
    
    # Instalar plugins
    install_zsh_plugins
    
    log_info "Temas e plugins instalados com sucesso!"
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 