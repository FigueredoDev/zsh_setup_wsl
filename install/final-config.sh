#!/bin/bash
# ============================================================================
# Configurações Finais
# ============================================================================

# Função para aplicar o template do .zshrc
apply_zshrc_template() {
    local template_file="$CONFIG_DIR/zshrc.template"
    local zshrc_file="$HOME/.zshrc"
    
    if [[ -f "$template_file" ]]; then
        log_info "Aplicando template do .zshrc..."
        
        # Fazer backup do arquivo existente
        backup_file "$zshrc_file"
        
        # Aplicar template
        cp "$template_file" "$zshrc_file"
        
        log_info "Template do .zshrc aplicado com sucesso"
    else
        log_error "Template do .zshrc não encontrado em $template_file"
    fi
}

# Função para criar arquivo de configurações locais
create_local_config() {
    local local_config="$HOME/.zshrc.local"
    
    if [[ ! -f "$local_config" ]]; then
        log_info "Criando arquivo de configurações locais..."
        
        cat > "$local_config" << 'EOF'
# ============================================================================
# Configurações Locais - ~/.zshrc.local
# Este arquivo é carregado no final do .zshrc
# Use-o para personalizar configurações específicas desta máquina
# ============================================================================

# Exemplo de configurações locais:

# Aliases específicos
# alias projeto="cd ~/meus-projetos"

# Variáveis de ambiente específicas
# export CUSTOM_VAR="valor"

# Configurações do tema Spaceship (se usar)
# SPACESHIP_PROMPT_ORDER=(
#   user          # Username section
#   dir           # Current directory section
#   host          # Hostname section
#   git           # Git section (git_branch + git_status)
#   hg            # Mercurial section (hg_branch  + hg_status)
#   package       # Package version
#   node          # Node.js section
#   ruby          # Ruby section
#   python        # Python section
#   golang        # Go section
#   php           # PHP section
#   rust          # Rust section
#   haskell       # Haskell Stack section
#   julia         # Julia section
#   docker        # Docker section
#   aws           # Amazon Web Services section
#   gcloud        # Google Cloud Platform section
#   venv          # virtualenv section
#   conda         # conda virtualenv section
#   pyenv         # Pyenv section
#   dotnet        # .NET section
#   ember         # Ember.js section
#   kubectl       # Kubectl context section
#   terraform     # Terraform workspace section
#   exec_time     # Execution time
#   line_sep      # Line break
#   battery       # Battery level and status
#   vi_mode       # Vi-mode indicator
#   jobs          # Background jobs indicator
#   exit_code     # Exit code section
#   char          # Prompt character
# )

# Configurações específicas do projeto
# export PROJECT_ROOT="$HOME/workspace"

# Funcões customizadas
# minha_funcao() {
#     echo "Olá do arquivo local!"
# }
EOF
        
        log_info "Arquivo ~/.zshrc.local criado"
    else
        log_info "Arquivo ~/.zshrc.local já existe"
    fi
}

# Função para configurar permissões corretas
set_correct_permissions() {
    log_info "Configurando permissões corretas..."
    
    # Arquivos de configuração do ZSH
    chmod 644 "$HOME/.zshrc" 2>/dev/null || true
    chmod 644 "$HOME/.zshrc.local" 2>/dev/null || true
    
    # Diretórios de gerenciadores de versão
    chmod 755 "$HOME/.nvm" 2>/dev/null || true
    chmod 755 "$HOME/.pyenv" 2>/dev/null || true
    chmod 755 "$HOME/.sdkman" 2>/dev/null || true
    chmod 755 "$HOME/.asdf" 2>/dev/null || true
    chmod 755 "$HOME/.phpenv" 2>/dev/null || true
    chmod 755 "$HOME/.bun" 2>/dev/null || true
    
    # SSH keys (se existirem)
    if [[ -d "$HOME/.ssh" ]]; then
        chmod 700 "$HOME/.ssh"
        chmod 600 "$HOME/.ssh/id_"* 2>/dev/null || true
        chmod 644 "$HOME/.ssh/id_"*.pub 2>/dev/null || true
    fi
}

# Função para criar diretórios de desenvolvimento
create_dev_directories() {
    log_info "Criando diretórios de desenvolvimento..."
    
    local dev_dirs=(
        "$HOME/workspace"
        "$HOME/projects"
        "$HOME/git"
        "$HOME/go/src"
        "$HOME/go/bin"
        "$HOME/go/pkg"
        "$HOME/.local/bin"
    )
    
    for dir in "${dev_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Diretório criado: $dir"
        fi
    done
}

# Função para configurar Git globalmente (melhorias)
enhance_git_config() {
    log_info "Melhorando configuração global do Git..."
    
    # Configurações de push e pull
    git config --global push.default simple
    git config --global pull.rebase false
    git config --global init.defaultBranch main
    
    # Configurações de merge e rebase
    git config --global merge.tool vimdiff
    git config --global rebase.autoStash true
    
    # Configurações de commit (GPG desabilitado por padrão)
    git config --global commit.gpgsign false  # Configure manualmente se usar GPG
    
    # Aliases úteis do Git
    
    # Aliases básicos e rápidos
    git config --global alias.s 'status -s'                    # Status resumido
    git config --global alias.st 'status'                      # Status completo
    git config --global alias.c 'commit -m'                    # Commit rápido com mensagem
    git config --global alias.ci 'commit'                      # Commit interativo
    
    # Aliases de navegação
    git config --global alias.co 'checkout'                    # Trocar branch
    git config --global alias.cb 'checkout -b'                 # Criar e trocar branch
    git config --global alias.br 'branch'                      # Listar/criar branches
    
    # Aliases de histórico
    git config --global alias.l "log --pretty=format:'%C(blue)%h%C(red)%d %C(white)%s - %C(cyan)%cn, %C(green)%cr'"
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.last 'log -1 HEAD'               # Último commit
    
    # Aliases de stash e limpeza
    git config --global alias.sts 'stash'                      # Stash rápido
    git config --global alias.unstage 'reset HEAD --'          # Desfazer staging
    
    # Aliases extras
    # git config --global alias.visual '!gitk'               # Interface gráfica (desabilitado para WSL)
    
    # Configurações de core
    git config --global core.autocrlf false  # Para WSL
    git config --global core.fileMode false  # Para WSL
    git config --global core.editor "vim"    # Editor CLI padrão (ou configure com "code --wait" se usar VS Code no Windows)
}

# Função para criar script de atualização
create_update_script() {
    local update_script="$HOME/.local/bin/update-dev-env"
    
    log_info "Criando script de atualização do ambiente..."
    
    cat > "$update_script" << 'EOF'
#!/bin/bash
# Script para atualizar ambiente de desenvolvimento

echo "🔄 Atualizando ambiente de desenvolvimento..."

# Atualizar sistema
echo "📦 Atualizando pacotes do sistema..."
sudo apt update && sudo apt upgrade -y

# Atualizar Oh My Zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "⚙️ Atualizando Oh My Zsh..."
    cd "$HOME/.oh-my-zsh" && git pull origin master
fi

# Atualizar plugins do ZSH
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin_dir in "$ZSH_CUSTOM/plugins"/*; do
    if [[ -d "$plugin_dir/.git" ]]; then
        echo "🔧 Atualizando plugin $(basename "$plugin_dir")..."
        cd "$plugin_dir" && git pull
    fi
done

# Atualizar temas
for theme_dir in "$ZSH_CUSTOM/themes"/*; do
    if [[ -d "$theme_dir/.git" ]]; then
        echo "🎨 Atualizando tema $(basename "$theme_dir")..."
        cd "$theme_dir" && git pull
    fi
done

# Atualizar gerenciadores de versão
echo "🔧 Atualizando gerenciadores de versão..."

# Pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    cd "$HOME/.pyenv" && git pull
fi

# ASDF
if [[ -d "$HOME/.asdf" ]]; then
    cd "$HOME/.asdf" && git pull
fi

# Bun
if command -v bun >/dev/null 2>&1; then
    bun upgrade
fi

# Atualizar pacotes globais do Node.js
if command -v npm >/dev/null 2>&1; then
    echo "📦 Atualizando pacotes globais do Node.js..."
    npm update -g
fi

echo "✅ Atualização concluída!"
echo "🔄 Reinicie o terminal para aplicar todas as mudanças."
EOF
    
    chmod +x "$update_script"
    log_info "Script de atualização criado em $update_script"
}

# Função principal
main() {
    log_info "Aplicando configurações finais..."
    
    # Aplicar configurações
    apply_zshrc_template
    create_local_config
    set_correct_permissions
    create_dev_directories
    enhance_git_config
    create_update_script
    
    log_info "Configurações finais aplicadas com sucesso!"
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 