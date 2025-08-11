#!/bin/bash

# ============================================================================
# WSL ZSH Development Environment Setup
# Autor: HyperX 
# Descrição: Script automatizado para configurar ambiente de desenvolvimento
# Sistema: WSL2 (Debian/Ubuntu)
# Uso: ./setup.sh [--profile PROFILE_NAME] [--list-profiles] [--help]
# ============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/setup.log"
CONFIG_DIR="$SCRIPT_DIR/config"
INSTALL_DIR="$SCRIPT_DIR/install"
PROFILES_DIR="$CONFIG_DIR/profiles"

# Variáveis de perfil
SELECTED_PROFILE=""
PROFILE_FILE=""

# Função de logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para fazer backup de arquivos existentes
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Fazendo backup de $file para $backup_file"
        cp "$file" "$backup_file"
    fi
}

# Função para listar perfis disponíveis
list_profiles() {
    echo -e "${PURPLE}==================== PERFIS DISPONÍVEIS ====================${NC}"
    echo ""
    
    for profile_file in "$PROFILES_DIR"/*.env; do
        if [[ -f "$profile_file" ]]; then
            local profile_name=$(basename "$profile_file" .env)
            local description=""
            
            # Extrair descrição do arquivo
            if grep -q "PROFILE_DESCRIPTION=" "$profile_file"; then
                description=$(grep "PROFILE_DESCRIPTION=" "$profile_file" | cut -d'=' -f2 | sed 's/"//g')
            fi
            
            echo -e "${YELLOW}📦 $profile_name${NC}"
            [[ -n "$description" ]] && echo -e "   $description"
            echo ""
        fi
    done
    
    echo -e "${BLUE}Uso: ./setup.sh --profile NOME_DO_PERFIL${NC}"
    echo -e "${BLUE}Exemplo: ./setup.sh --profile frontend${NC}"
    echo ""
}

# Função para carregar perfil
load_profile() {
    local profile_name="$1"
    PROFILE_FILE="$PROFILES_DIR/${profile_name}.env"
    
    if [[ ! -f "$PROFILE_FILE" ]]; then
        log_error "Perfil '$profile_name' não encontrado em $PROFILE_FILE"
        echo ""
        echo "Perfis disponíveis:"
        list_profiles
        exit 1
    fi
    
    log_info "Carregando perfil: $profile_name"
    source "$PROFILE_FILE"
    SELECTED_PROFILE="$profile_name"
    
    # Mostrar informações do perfil
    if [[ -n "${PROFILE_DESCRIPTION:-}" ]]; then
        log_info "Descrição: $PROFILE_DESCRIPTION"
    fi
}

# Função para mostrar ajuda
show_help() {
    echo -e "${PURPLE}WSL ZSH Development Environment Setup${NC}"
    echo ""
    echo -e "${YELLOW}Uso:${NC}"
    echo "  ./setup.sh                    Instalação padrão (perfil full)"
    echo "  ./setup.sh --profile NOME     Usar perfil específico"
    echo "  ./setup.sh --list-profiles    Listar perfis disponíveis"
    echo "  ./setup.sh --help             Mostrar esta ajuda"
    echo ""
    echo -e "${YELLOW}Exemplos:${NC}"
    echo "  ./setup.sh --profile minimal     Setup mínimo (ZSH + Node.js)"
    echo "  ./setup.sh --profile frontend    Setup para desenvolvimento frontend"
    echo "  ./setup.sh --profile backend     Setup para desenvolvimento backend"
    echo "  ./setup.sh --profile full        Setup completo (padrão)"
    echo ""
}

# Função para processar argumentos
process_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                if [[ -n "${2:-}" ]]; then
                    load_profile "$2"
                    shift 2
                else
                    log_error "Argumento --profile requer um nome de perfil"
                    exit 1
                fi
                ;;
            --list-profiles)
                list_profiles
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Argumento desconhecido: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Se nenhum perfil foi especificado, usar o full por padrão
    if [[ -z "$SELECTED_PROFILE" ]]; then
        log_info "Nenhum perfil especificado, usando perfil 'full' por padrão"
        load_profile "full"
    fi
}

# Função principal
main() {
    # Processar argumentos primeiro (pode sair do script para --help, --list-profiles)
    process_arguments "$@"
    
    log "🚀 Iniciando setup do ambiente de desenvolvimento WSL"
    log "📁 Diretório do script: $SCRIPT_DIR"
    
    # Mostrar perfil selecionado
    if [[ -n "$SELECTED_PROFILE" ]]; then
        log "🎯 Perfil selecionado: $SELECTED_PROFILE"
        [[ -n "${PROFILE_DESCRIPTION:-}" ]] && log_info "$PROFILE_DESCRIPTION"
    fi
    
    # Verificar se é WSL
    if ! grep -q Microsoft /proc/version 2>/dev/null; then
        log_warning "Este script foi otimizado para WSL. Continuando mesmo assim..."
    fi
    
    # Verificar se é Debian/Ubuntu
    if ! command_exists apt; then
        log_error "Este script requer um sistema baseado em Debian/Ubuntu"
        exit 1
    fi
    
    # Carregar variáveis de ambiente se existirem
    if [[ -f "$SCRIPT_DIR/.env" ]]; then
        log_info "Carregando variáveis de ambiente"
        set -o allexport
        source "$SCRIPT_DIR/.env"
        set +o allexport
    else
        log_info "Arquivo .env não encontrado. Você pode criar um baseado no .env.example"
    fi
    
    # Executar fases do setup
    log "📦 Fase 1: Instalando dependências do sistema..."
    source "$INSTALL_DIR/dependencies.sh"
    
    log "⚙️ Fase 2: Configurando ZSH e Oh My Zsh..."
    source "$INSTALL_DIR/zsh-setup.sh"
    
    log "🎨 Fase 3: Instalando temas e plugins..."
    source "$INSTALL_DIR/zsh-customization.sh"
    
    log "🔧 Fase 4: Instalando gerenciadores de versão..."
    source "$INSTALL_DIR/version-managers.sh"
    
    log "💻 Fase 5: Configurando linguagens de desenvolvimento..."
    source "$INSTALL_DIR/languages.sh"
    
    log "🛠️ Fase 6: Instalando ferramentas de desenvolvimento..."
    source "$INSTALL_DIR/dev-tools.sh"
    
    log "📝 Fase 7: Aplicando configurações finais..."
    source "$INSTALL_DIR/final-config.sh"
    
    log "✅ Fase 8: Validando instalação..."
    source "$INSTALL_DIR/validate.sh"
    
    echo ""
    log "🎉 Setup concluído com sucesso!"
    log "🔄 Reinicie seu terminal ou execute: source ~/.zshrc"
    log "📋 Log completo salvo em: $LOG_FILE"
    
    # Mostrar próximos passos
    show_next_steps
}

show_next_steps() {
    echo ""
    echo -e "${PURPLE}==================== PRÓXIMOS PASSOS ====================${NC}"
    echo -e "${YELLOW}1.${NC} Reinicie seu terminal ou execute: ${GREEN}source ~/.zshrc${NC}"
    echo -e "${YELLOW}2.${NC} Configure suas variáveis sensíveis em ${GREEN}.env${NC}"
    echo -e "${YELLOW}3.${NC} Instale versões específicas das linguagens:"
    echo -e "   ${BLUE}•${NC} Node.js: ${GREEN}nvm install --lts${NC}"
    echo -e "   ${BLUE}•${NC} Python: ${GREEN}pyenv install 3.11.0${NC}"
    echo -e "   ${BLUE}•${NC} Java: ${GREEN}sdk install java 17.0.8-amzn${NC}"
    echo -e "${YELLOW}4.${NC} Execute o teste de validação: ${GREEN}$INSTALL_DIR/validate.sh${NC}"
    echo -e "${PURPLE}=======================================================${NC}"
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 