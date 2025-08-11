#!/bin/bash
# ============================================================================
# Sistema de Backup e Rollback
# Gerencia backups e permite rollback completo ou por componente
# ============================================================================

set -euo pipefail

# Configurações
BACKUP_BASE_DIR="$HOME/.zsh_setup_backups"
CURRENT_BACKUP_DIR=""
BACKUP_MANIFEST=""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Função de logging
log_backup() {
    echo -e "${GREEN}[BACKUP $(date +'%H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR $(date +'%H:%M:%S')]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING $(date +'%H:%M:%S')]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO $(date +'%H:%M:%S')]${NC} $1"
}

# Função para criar diretório de backup com timestamp
create_backup_session() {
    local session_name="${1:-setup_$(date +%Y%m%d_%H%M%S)}"
    CURRENT_BACKUP_DIR="$BACKUP_BASE_DIR/$session_name"
    BACKUP_MANIFEST="$CURRENT_BACKUP_DIR/manifest.json"
    
    mkdir -p "$CURRENT_BACKUP_DIR"
    
    # Criar manifest inicial
    cat > "$BACKUP_MANIFEST" << EOF
{
  "session": "$session_name",
  "timestamp": "$(date -Iseconds)",
  "components": {},
  "files_backed_up": [],
  "directories_backed_up": []
}
EOF
    
    log_backup "Sessão de backup criada: $session_name"
    echo "$CURRENT_BACKUP_DIR"
}

# Função para fazer backup de um arquivo
backup_file() {
    local file_path="$1"
    local component="$2"
    
    if [[ -f "$file_path" ]]; then
        local backup_file_path="$CURRENT_BACKUP_DIR/$(basename "$file_path")"
        cp "$file_path" "$backup_file_path"
        
        # Atualizar manifest
        update_manifest "files" "$file_path" "$backup_file_path" "$component"
        
        log_info "Backup: $file_path → $backup_file_path"
        return 0
    fi
    return 1
}

# Função para fazer backup de um diretório
backup_directory() {
    local dir_path="$1" 
    local component="$2"
    
    if [[ -d "$dir_path" ]]; then
        local backup_dir_path="$CURRENT_BACKUP_DIR/$(basename "$dir_path")"
        cp -r "$dir_path" "$backup_dir_path"
        
        # Atualizar manifest
        update_manifest "directories" "$dir_path" "$backup_dir_path" "$component"
        
        log_info "Backup: $dir_path → $backup_dir_path"
        return 0
    fi
    return 1
}

# Função para atualizar o manifest
update_manifest() {
    local type="$1"      # "files" ou "directories"
    local original="$2"
    local backup="$3"
    local component="$4"
    
    # Usar jq se disponível, senão usar método simples
    if command -v jq >/dev/null 2>&1; then
        local temp_manifest=$(mktemp)
        jq --arg type "$type" --arg orig "$original" --arg back "$backup" --arg comp "$component" \
           '.components[$comp] = (.components[$comp] // {}) | 
            .components[$comp][$type] = (.components[$comp][$type] // []) |
            .components[$comp][$type] += [{"original": $orig, "backup": $back}] |
            .[$type + "_backed_up"] += [$orig]' \
           "$BACKUP_MANIFEST" > "$temp_manifest"
        mv "$temp_manifest" "$BACKUP_MANIFEST"
    else
        # Método simples sem jq
        echo "  $component: $original → $backup" >> "$CURRENT_BACKUP_DIR/backup_log.txt"
    fi
}

# Função para fazer backup dos componentes principais antes da instalação
backup_system_state() {
    local session_name="$1"
    create_backup_session "$session_name"
    
    log_backup "Fazendo backup do estado atual do sistema..."
    
    # Backup de arquivos de configuração
    backup_file "$HOME/.zshrc" "zsh" || log_info ".zshrc não encontrado, criando novo"
    backup_file "$HOME/.zshrc.local" "zsh" || log_info ".zshrc.local não encontrado"
    backup_file "$HOME/.gitconfig" "git" || log_info ".gitconfig será criado"
    backup_file "$HOME/.bashrc" "bash" || log_info ".bashrc não encontrado"
    
    # Backup de diretórios de gerenciadores de versão (se existirem)
    backup_directory "$HOME/.nvm" "nvm" || log_info "NVM não instalado"
    backup_directory "$HOME/.pyenv" "pyenv" || log_info "Pyenv não instalado"  
    backup_directory "$HOME/.sdkman" "sdkman" || log_info "SDKMAN não instalado"
    backup_directory "$HOME/.asdf" "asdf" || log_info "ASDF não instalado"
    backup_directory "$HOME/.phpenv" "phpenv" || log_info "PHPenv não instalado"
    backup_directory "$HOME/.bun" "bun" || log_info "Bun não instalado"
    backup_directory "$HOME/.oh-my-zsh" "oh-my-zsh" || log_info "Oh My Zsh não instalado"
    
    # Salvar lista de pacotes instalados
    if command -v apt >/dev/null 2>&1; then
        apt list --installed > "$CURRENT_BACKUP_DIR/installed_packages.txt" 2>/dev/null || true
    fi
    
    # Salvar versões das linguagens instaladas
    cat > "$CURRENT_BACKUP_DIR/language_versions.txt" << EOF
# Versões das linguagens antes do setup
Node.js: $(node --version 2>/dev/null || echo "não instalado")
Python: $(python3 --version 2>/dev/null || echo "não instalado") 
Java: $(java -version 2>&1 | head -n1 || echo "não instalado")
Go: $(go version 2>/dev/null || echo "não instalado")
Bun: $(bun --version 2>/dev/null || echo "não instalado")
EOF
    
    log_backup "Backup do sistema concluído em: $CURRENT_BACKUP_DIR"
}

# Função para listar backups disponíveis
list_backups() {
    echo -e "${PURPLE}==================== BACKUPS DISPONÍVEIS ====================${NC}"
    echo ""
    
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        echo "Nenhum backup encontrado."
        return 0
    fi
    
    local count=0
    for backup_dir in "$BACKUP_BASE_DIR"/*; do
        if [[ -d "$backup_dir" ]]; then
            local session_name=$(basename "$backup_dir")
            local manifest_file="$backup_dir/manifest.json"
            
            echo -e "${YELLOW}📦 $session_name${NC}"
            
            if [[ -f "$manifest_file" ]] && command -v jq >/dev/null 2>&1; then
                local timestamp=$(jq -r '.timestamp // "unknown"' "$manifest_file" 2>/dev/null || echo "unknown")
                local components=$(jq -r '.components | keys | join(", ")' "$manifest_file" 2>/dev/null || echo "unknown")
                echo "   📅 Data: $timestamp"
                echo "   🔧 Componentes: $components"
            else
                echo "   📅 Data: $(date -r "$backup_dir" 2>/dev/null || echo "unknown")"
                echo "   📁 Local: $backup_dir"
            fi
            echo ""
            ((count++))
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        echo "Nenhum backup encontrado."
    else
        echo -e "${BLUE}Total de backups: $count${NC}"
        echo ""
        echo -e "${YELLOW}Uso:${NC}"
        echo "  ./tools/backup-system.sh --restore SESSION_NAME"
        echo "  ./tools/backup-system.sh --restore-component SESSION_NAME COMPONENT"
    fi
}

# Função para restaurar backup completo
restore_backup() {
    local session_name="$1"
    local backup_dir="$BACKUP_BASE_DIR/$session_name"
    local manifest_file="$backup_dir/manifest.json"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup '$session_name' não encontrado"
        return 1
    fi
    
    echo -e "${RED}⚠️  ATENÇÃO: Restaurar backup irá sobrescrever configurações atuais!${NC}"
    echo -e "${YELLOW}Backup a ser restaurado: $session_name${NC}"
    echo ""
    read -p "Tem certeza que deseja continuar? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Operação cancelada pelo usuário"
        return 0
    fi
    
    log_backup "Restaurando backup: $session_name"
    
    # Restaurar arquivos
    for file in "$backup_dir"/*.{zshrc,gitconfig,bashrc}; do
        if [[ -f "$file" ]]; then
            local target_file="$HOME/.$(basename "$file")"
            cp "$file" "$target_file" 2>/dev/null || true
            log_info "Restaurado: $target_file"
        fi
    done
    
    # Restaurar diretórios (cuidado com isso!)
    local restore_dirs=(".nvm" ".pyenv" ".sdkman" ".asdf" ".phpenv" ".bun" ".oh-my-zsh")
    
    for dir_name in "${restore_dirs[@]}"; do
        local backup_path="$backup_dir/$dir_name"
        local target_path="$HOME/$dir_name"
        
        if [[ -d "$backup_path" ]]; then
            echo "Restaurar $target_path? (y/N): "
            read -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "$target_path" 2>/dev/null || true
                cp -r "$backup_path" "$target_path"
                log_info "Restaurado: $target_path"
            fi
        fi
    done
    
    log_backup "Restauração concluída! Reinicie o terminal."
}

# Função para restaurar componente específico  
restore_component() {
    local session_name="$1"
    local component="$2"
    local backup_dir="$BACKUP_BASE_DIR/$session_name"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup '$session_name' não encontrado"
        return 1
    fi
    
    case "$component" in
        "zsh")
            [[ -f "$backup_dir/.zshrc" ]] && cp "$backup_dir/.zshrc" "$HOME/.zshrc"
            [[ -f "$backup_dir/.zshrc.local" ]] && cp "$backup_dir/.zshrc.local" "$HOME/.zshrc.local"
            ;;
        "git")
            [[ -f "$backup_dir/.gitconfig" ]] && cp "$backup_dir/.gitconfig" "$HOME/.gitconfig"
            ;;
        "oh-my-zsh")
            if [[ -d "$backup_dir/.oh-my-zsh" ]]; then
                rm -rf "$HOME/.oh-my-zsh"
                cp -r "$backup_dir/.oh-my-zsh" "$HOME/.oh-my-zsh"
            fi
            ;;
        *)
            # Tentar restaurar diretório do gerenciador de versão
            if [[ -d "$backup_dir/.$component" ]]; then
                rm -rf "$HOME/.$component"
                cp -r "$backup_dir/.$component" "$HOME/.$component"
            else
                log_error "Componente '$component' não encontrado no backup"
                return 1
            fi
            ;;
    esac
    
    log_backup "Componente '$component' restaurado do backup '$session_name'"
}

# Função principal
main() {
    case "${1:-}" in
        --create)
            backup_system_state "${2:-setup_$(date +%Y%m%d_%H%M%S)}"
            ;;
        --list)
            list_backups
            ;;
        --restore)
            if [[ -n "${2:-}" ]]; then
                restore_backup "$2"
            else
                log_error "Nome da sessão de backup é necessário"
                exit 1
            fi
            ;;
        --restore-component)
            if [[ -n "${2:-}" && -n "${3:-}" ]]; then
                restore_component "$2" "$3"
            else
                log_error "Nome da sessão e componente são necessários"
                exit 1
            fi
            ;;
        --help|-h)
            echo "Sistema de Backup e Rollback"
            echo ""
            echo "Uso:"
            echo "  $0 --create [SESSION_NAME]              Criar backup do estado atual"
            echo "  $0 --list                               Listar backups disponíveis"
            echo "  $0 --restore SESSION_NAME               Restaurar backup completo"
            echo "  $0 --restore-component SESSION COMP     Restaurar componente específico"
            echo "  $0 --help                               Mostrar esta ajuda"
            echo ""
            echo "Componentes disponíveis: zsh, git, oh-my-zsh, nvm, pyenv, sdkman, asdf, bun"
            ;;
        *)
            log_error "Comando inválido. Use --help para ver as opções disponíveis."
            exit 1
            ;;
    esac
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 