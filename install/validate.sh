#!/bin/bash
# ============================================================================
# Validação da Instalação
# ============================================================================

# Contadores para relatório
total_checks=0
passed_checks=0
failed_checks=0

# Array para armazenar falhas
declare -a failures

# Função para executar teste
run_test() {
    local test_name="$1"
    local test_command="$2"
    local is_critical="${3:-false}"
    
    ((total_checks++))
    
    echo -n "🔍 Testando $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        ((passed_checks++))
        return 0
    else
        if [[ "$is_critical" == "true" ]]; then
            echo -e "${RED}❌ FALHOU (CRÍTICO)${NC}"
        else
            echo -e "${YELLOW}⚠️ FALHOU (OPCIONAL)${NC}"
        fi
        
        failures+=("$test_name")
        ((failed_checks++))
        return 1
    fi
}

# Função para validar dependências básicas
validate_basic_dependencies() {
    log_info "Validando dependências básicas..."
    
    run_test "ZSH instalado" "command -v zsh" true
    run_test "Git instalado" "command -v git" true
    run_test "Curl instalado" "command -v curl" true
    run_test "Build essentials" "dpkg -s build-essential" true
}

# Função para validar Oh My Zsh
validate_oh_my_zsh() {
    log_info "Validando Oh My Zsh..."
    
    run_test "Oh My Zsh instalado" "test -d $HOME/.oh-my-zsh" true
    run_test "Tema Spaceship" "test -d $HOME/.oh-my-zsh/custom/themes/spaceship-prompt" false
    run_test "Tema Dracula" "test -d $HOME/.oh-my-zsh/custom/themes/dracula" false
    run_test "Plugin zsh-autosuggestions" "test -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" true
    run_test "Plugin zsh-syntax-highlighting" "test -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" true
    run_test "Plugin zsh-completions" "test -d $HOME/.oh-my-zsh/custom/plugins/zsh-completions" false
}

# Função para validar gerenciadores de versão
validate_version_managers() {
    log_info "Validando gerenciadores de versão..."
    
    run_test "NVM instalado" "test -d $HOME/.nvm" true
    run_test "Pyenv instalado" "test -d $HOME/.pyenv" true
    run_test "SDKMAN instalado" "test -d $HOME/.sdkman" true
    run_test "ASDF instalado" "test -d $HOME/.asdf" false
    run_test "PHPenv instalado" "test -d $HOME/.phpenv" false
    run_test "Bun instalado" "command -v bun" false
}

# Função para validar linguagens
validate_languages() {
    log_info "Validando linguagens instaladas..."
    
    # Carregar ambientes para teste
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" 2>/dev/null || true
    
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # Testar linguagens
    run_test "Node.js disponível" "command -v node" false
    run_test "NPM disponível" "command -v npm" false
    run_test "Python disponível" "command -v python" false
    run_test "Pip disponível" "command -v pip" false
    run_test "Java disponível" "command -v java" false
    run_test "Go instalado" "test -d /usr/local/go" false
}

# Função para validar ferramentas de desenvolvimento
validate_dev_tools() {
    log_info "Validando ferramentas de desenvolvimento..."
    
    run_test "GPG configurado" "command -v gpg" false
    run_test "Bat instalado" "command -v bat" false
    run_test "Exa instalado" "command -v exa" false
    run_test "Ripgrep instalado" "command -v rg" false
    run_test "FZF instalado" "command -v fzf" false
    run_test "GitHub CLI instalado" "command -v gh" false
}

# Função para validar configurações
validate_configurations() {
    log_info "Validando configurações..."
    
    run_test ".zshrc existe" "test -f $HOME/.zshrc" true
    run_test ".zshrc.local existe" "test -f $HOME/.zshrc.local" false
    run_test "Diretório workspace criado" "test -d $HOME/workspace" false
    run_test "Diretório projects criado" "test -d $HOME/projects" false
    run_test "Script de atualização criado" "test -f $HOME/.local/bin/update-dev-env" false
}

# Função para testar funções customizadas
validate_custom_functions() {
    log_info "Validando funções customizadas..."
    
    # Carregar .zshrc para testar funções
    if [[ -f "$HOME/.zshrc" ]]; then
        source "$HOME/.zshrc" 2>/dev/null || true
        
        run_test "Função ccm disponível" "type ccm" false
        run_test "Função ccmpt disponível" "type ccmpt" false
        run_test "Função cgb disponível" "type cgb" false
    fi
}

# Função para gerar relatório final
generate_report() {
    echo ""
    echo "======================================================================"
    echo -e "${BLUE}                    RELATÓRIO DE VALIDAÇÃO${NC}"
    echo "======================================================================"
    echo ""
    echo -e "${GREEN}✅ Testes aprovados:${NC} $passed_checks"
    echo -e "${RED}❌ Testes falharam:${NC} $failed_checks"
    echo -e "${BLUE}📊 Total de testes:${NC} $total_checks"
    
    if [[ $failed_checks -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}⚠️  Itens que falharam:${NC}"
        for failure in "${failures[@]}"; do
            echo "   • $failure"
        done
    fi
    
    echo ""
    if [[ $failed_checks -eq 0 ]]; then
        echo -e "${GREEN}🎉 Todos os testes passaram! Seu ambiente está pronto.${NC}"
        echo -e "${GREEN}🔄 Execute 'source ~/.zshrc' ou reinicie o terminal.${NC}"
    elif [[ $passed_checks -gt $((total_checks / 2)) ]]; then
        echo -e "${YELLOW}⚠️  A maioria dos componentes está funcionando.${NC}"
        echo -e "${YELLOW}🔧 Revise os itens que falharam e execute novamente se necessário.${NC}"
    else
        echo -e "${RED}❌ Muitos componentes falharam.${NC}"
        echo -e "${RED}🔄 Considere executar o setup novamente.${NC}"
    fi
    
    echo "======================================================================"
}

# Validar recursos da versão 1.2
validate_v12_features() {
    log_info "Validando recursos v1.2..."
    
    # Validar sistema de backup
    run_test "Sistema de backup disponível" "test -f '$SCRIPT_DIR/tools/backup-system.sh'"
    run_test "Sistema de backup executável" "test -x '$SCRIPT_DIR/tools/backup-system.sh'"
    
    # Validar health check
    run_test "Health check disponível" "test -f '$SCRIPT_DIR/bin/health-check'"
    run_test "Health check executável" "test -x '$SCRIPT_DIR/bin/health-check'"
    
    # Validar setup interativo
    run_test "Setup interativo disponível" "test -f '$SCRIPT_DIR/tools/interactive-setup.sh'"
    run_test "Setup interativo executável" "test -x '$SCRIPT_DIR/tools/interactive-setup.sh'"
    
    # Validar integração com setup principal
    run_test "Setup suporta --interactive" "grep -q '\\-\\-interactive' '$SCRIPT_DIR/setup.sh'"
    run_test "Setup suporta --backup" "grep -q '\\-\\-backup' '$SCRIPT_DIR/setup.sh'"
    run_test "Setup suporta --rollback" "grep -q '\\-\\-rollback' '$SCRIPT_DIR/setup.sh'"
    run_test "Setup suporta --health-check" "grep -q '\\-\\-health-check' '$SCRIPT_DIR/setup.sh'"
    
    # Testar funcionalidade básica dos novos scripts (sem executar)
    run_test "Backup system help" "$SCRIPT_DIR/tools/backup-system.sh --help >/dev/null 2>&1"
    run_test "Health check help" "$SCRIPT_DIR/bin/health-check --help >/dev/null 2>&1"
    run_test "Interactive setup help" "$SCRIPT_DIR/tools/interactive-setup.sh --help >/dev/null 2>&1"
}

# Função principal
main() {
    log_info "Iniciando validação da instalação..."
    
    # Executar validações
    validate_basic_dependencies
    validate_oh_my_zsh
    validate_version_managers
    validate_languages
    validate_dev_tools
    validate_configurations
    validate_custom_functions
    validate_v12_features
    
    # Gerar relatório
    generate_report
    
    # Código de saída baseado nos resultados
    if [[ $failed_checks -eq 0 ]]; then
        return 0
    elif [[ $passed_checks -gt $((total_checks / 2)) ]]; then
        return 1
    else
        return 2
    fi
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Definir cores se não estiverem definidas
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
    
    # Função de logging simples se não estiver definida
    if ! declare -f log_info >/dev/null 2>&1; then
        log_info() {
            echo -e "${BLUE}[INFO]${NC} $1"
        }
    fi
    
    main "$@"
fi 