#!/bin/bash
# ============================================================================
# Setup Interativo WSL ZSH Development Environment  
# Interface CLI intuitiva para escolher componentes de instalação
# ============================================================================

set -euo pipefail

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variáveis de seleção
declare -A COMPONENTS
SELECTED_PROFILE=""
CUSTOM_SETUP=false

# Função para desenhar cabeçalho
draw_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║           WSL ZSH Development Environment Setup              ║${NC}"
    echo -e "${PURPLE}║                      Modo Interativo                        ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Função para mostrar menu de perfis
show_profile_menu() {
    draw_header
    echo -e "${CYAN}Escolha um perfil de instalação:${NC}"
    echo ""
    echo -e "${YELLOW}1.${NC} 📦 ${GREEN}Minimal${NC}     - Setup básico (ZSH + Node.js + utilitários básicos)"
    echo -e "   ${BLUE}Tempo: ~5min | Tamanho: ~500MB${NC}"
    echo ""
    echo -e "${YELLOW}2.${NC} 🎨 ${GREEN}Frontend${NC}    - Desenvolvimento web (React, Vue, Angular)"  
    echo -e "   ${BLUE}Tempo: ~7min | Tamanho: ~900MB${NC}"
    echo ""
    echo -e "${YELLOW}3.${NC} ⚙️  ${GREEN}Backend${NC}     - APIs e serviços (Python, Java, Go, Docker)"
    echo -e "   ${BLUE}Tempo: ~11min | Tamanho: ~1.8GB${NC}"
    echo ""
    echo -e "${YELLOW}4.${NC} 🚀 ${GREEN}Full${NC}        - Instalação completa (todas as ferramentas)" 
    echo -e "   ${BLUE}Tempo: ~13min | Tamanho: ~2.5GB${NC}"
    echo ""
    echo -e "${YELLOW}5.${NC} 🔧 ${GREEN}Custom${NC}      - Escolha componentes individuais"
    echo ""
    echo -e "${YELLOW}0.${NC} ❌ ${RED}Sair${NC}"
    echo ""
    echo -n -e "${CYAN}Selecione uma opção (0-5): ${NC}"
}

# Função para mostrar menu custom
show_custom_menu() {
    local page="${1:-1}"
    local total_pages=3
    
    draw_header
    echo -e "${CYAN}Configuração Personalizada - Página $page/$total_pages${NC}"
    echo ""
    
    case $page in
        1)
            echo -e "${YELLOW}=== COMPONENTES BÁSICOS ===${NC}"
            echo ""
            show_component_option "zsh" "🐚 ZSH + Oh My Zsh" "Shell moderno com framework" true
            show_component_option "git_config" "🔧 Configuração Git" "Aliases e configurações Git" true
            show_component_option "modern_utils" "⚡ Utilitários Modernos" "bat, exa, ripgrep, fzf" false
            echo ""
            echo -e "${YELLOW}=== GERENCIADORES DE VERSÃO ===${NC}"
            echo ""
            show_component_option "nvm" "📦 NVM" "Node Version Manager" false
            show_component_option "pyenv" "🐍 Pyenv" "Python Version Manager" false
            show_component_option "sdkman" "☕ SDKMAN" "Java/Kotlin/Scala Version Manager" false
            show_component_option "asdf" "🔀 ASDF" "Multi-language Version Manager" false
            ;;
        2)
            echo -e "${YELLOW}=== LINGUAGENS DE DESENVOLVIMENTO ===${NC}"
            echo ""
            show_component_option "nodejs" "🟢 Node.js" "JavaScript runtime via NVM" false
            show_component_option "python" "🐍 Python" "Linguagem Python via Pyenv" false
            show_component_option "java" "☕ Java" "OpenJDK via SDKMAN" false
            show_component_option "golang" "🔵 Go" "Linguagem Go (versão mais recente)" false
            show_component_option "bun" "🍞 Bun" "JavaScript runtime alternativo" false
            echo ""
            echo -e "${YELLOW}=== TEMAS E PLUGINS ===${NC}"
            echo ""
            show_component_option "spaceship_theme" "🚀 Spaceship Theme" "Tema ZSH moderno" false
            show_component_option "dracula_theme" "🧛 Dracula Theme" "Tema ZSH dark" false
            ;;
        3)
            echo -e "${YELLOW}=== FERRAMENTAS DE DESENVOLVIMENTO ===${NC}"
            echo ""
            show_component_option "docker" "🐳 Docker" "Containerização" false
            show_component_option "github_cli" "🐙 GitHub CLI" "Ferramenta oficial do GitHub" false
            show_component_option "gemini_cli" "🤖 Gemini CLI" "IA para commits automáticos" false
            show_component_option "console_ninja" "🥷 Console Ninja" "Debug tool" false
            echo ""
            echo -e "${YELLOW}=== EXTRAS ===${NC}"
            echo ""
            show_component_option "dev_directories" "📁 Diretórios Dev" "workspace, projects, git" false
            show_component_option "update_script" "🔄 Script Update" "Ferramenta de atualização" false
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Navegação:${NC}"
    if [[ $page -gt 1 ]]; then
        echo -e "${YELLOW}p${NC} - Página anterior"
    fi
    if [[ $page -lt $total_pages ]]; then
        echo -e "${YELLOW}n${NC} - Próxima página"
    fi
    echo -e "${YELLOW}s${NC} - Resumo e instalação"
    echo -e "${YELLOW}r${NC} - Resetar seleções"
    echo -e "${YELLOW}q${NC} - Voltar ao menu principal"
    echo ""
    echo -n -e "${CYAN}Opção (componente/navegação): ${NC}"
}

# Função para mostrar opção de componente
show_component_option() {
    local key="$1"
    local name="$2"  
    local description="$3"
    local required="${4:-false}"
    
    local status=""
    if [[ "$required" == "true" ]]; then
        status="${GREEN}[OBRIGATÓRIO]${NC}"
        COMPONENTS[$key]="true"
    elif [[ "${COMPONENTS[$key]:-false}" == "true" ]]; then
        status="${GREEN}[SELECIONADO]${NC}"
    else
        status="${RED}[NÃO SELECIONADO]${NC}"
    fi
    
    echo -e "${YELLOW}$key${NC} - $name $status"
    echo -e "      $description"
    echo ""
}

# Função para alternar seleção de componente
toggle_component() {
    local key="$1"
    
    if [[ "${COMPONENTS[$key]:-false}" == "true" ]]; then
        COMPONENTS[$key]="false"
    else  
        COMPONENTS[$key]="true"
    fi
}

# Função para carregar perfil pré-definido
load_profile_components() {
    local profile="$1"
    
    # Resetar seleções
    for key in "${!COMPONENTS[@]}"; do
        COMPONENTS[$key]="false"
    done
    
    # Componentes obrigatórios sempre ativos
    COMPONENTS[zsh]="true"
    COMPONENTS[git_config]="true"
    
    case "$profile" in
        "minimal")
            COMPONENTS[modern_utils]="true"
            COMPONENTS[nvm]="true"
            COMPONENTS[nodejs]="true"
            COMPONENTS[spaceship_theme]="true"
            COMPONENTS[dev_directories]="true"
            ;;
        "frontend")
            COMPONENTS[modern_utils]="true"
            COMPONENTS[nvm]="true"
            COMPONENTS[nodejs]="true"
            COMPONENTS[bun]="true"
            COMPONENTS[spaceship_theme]="true"
            COMPONENTS[dracula_theme]="true"
            COMPONENTS[docker]="true"
            COMPONENTS[github_cli]="true"
            COMPONENTS[gemini_cli]="true"
            COMPONENTS[dev_directories]="true"
            COMPONENTS[update_script]="true"
            ;;
        "backend")
            COMPONENTS[modern_utils]="true"
            COMPONENTS[nvm]="true"
            COMPONENTS[pyenv]="true"
            COMPONENTS[sdkman]="true"
            COMPONENTS[asdf]="true"
            COMPONENTS[nodejs]="true"
            COMPONENTS[python]="true"
            COMPONENTS[java]="true"
            COMPONENTS[golang]="true"
            COMPONENTS[spaceship_theme]="true"
            COMPONENTS[docker]="true"
            COMPONENTS[github_cli]="true"
            COMPONENTS[gemini_cli]="true"
            COMPONENTS[dev_directories]="true"
            COMPONENTS[update_script]="true"
            ;;
        "full")
            for key in "${!COMPONENTS[@]}"; do
                COMPONENTS[$key]="true"
            done
            ;;
    esac
}

# Função para mostrar resumo da seleção
show_selection_summary() {
    draw_header
    echo -e "${CYAN}Resumo da Instalação${NC}"
    echo ""
    
    local selected_count=0
    local estimated_time=3  # Tempo base
    local estimated_size=200  # Tamanho base em MB
    
    echo -e "${YELLOW}Componentes Selecionados:${NC}"
    echo ""
    
    for key in "${!COMPONENTS[@]}"; do
        if [[ "${COMPONENTS[$key]}" == "true" ]]; then
            case "$key" in
                "zsh") echo "  🐚 ZSH + Oh My Zsh" ;;
                "git_config") echo "  🔧 Configuração Git" ;;
                "modern_utils") echo "  ⚡ Utilitários Modernos"; ((estimated_time+=1)); ((estimated_size+=100)) ;;
                "nvm") echo "  📦 NVM"; ((estimated_time+=1)) ;;
                "pyenv") echo "  🐍 Pyenv"; ((estimated_time+=2)) ;;
                "sdkman") echo "  ☕ SDKMAN"; ((estimated_time+=1)) ;;
                "asdf") echo "  🔀 ASDF"; ((estimated_time+=1)) ;;
                "nodejs") echo "  🟢 Node.js"; ((estimated_time+=1)); ((estimated_size+=300)) ;;
                "python") echo "  🐍 Python"; ((estimated_time+=2)); ((estimated_size+=200)) ;;
                "java") echo "  ☕ Java"; ((estimated_time+=2)); ((estimated_size+=400)) ;;
                "golang") echo "  🔵 Go"; ((estimated_time+=1)); ((estimated_size+=300)) ;;
                "bun") echo "  🍞 Bun"; ((estimated_time+=1)); ((estimated_size+=100)) ;;
                "spaceship_theme") echo "  🚀 Spaceship Theme" ;;
                "dracula_theme") echo "  🧛 Dracula Theme" ;;
                "docker") echo "  🐳 Docker"; ((estimated_time+=3)); ((estimated_size+=500)) ;;
                "github_cli") echo "  🐙 GitHub CLI"; ((estimated_time+=1)); ((estimated_size+=50)) ;;
                "gemini_cli") echo "  🤖 Gemini CLI" ;;
                "console_ninja") echo "  🥷 Console Ninja" ;;
                "dev_directories") echo "  📁 Diretórios de Desenvolvimento" ;;
                "update_script") echo "  🔄 Script de Atualização" ;;
            esac
            ((selected_count++))
        fi
    done
    
    echo ""
    echo -e "${BLUE}📊 Estimativas:${NC}"
    echo -e "  ⏱️  Tempo estimado: ~${estimated_time} minutos"
    echo -e "  💾 Tamanho estimado: ~${estimated_size}MB"
    echo -e "  📦 Componentes: $selected_count selecionados"
    echo ""
    
    echo -e "${YELLOW}Opções:${NC}"
    echo -e "${GREEN}i${NC} - Iniciar instalação"
    echo -e "${YELLOW}e${NC} - Editar seleção"
    echo -e "${RED}q${NC} - Cancelar"
    echo ""
    echo -n -e "${CYAN}Confirmar instalação? (i/e/q): ${NC}"
}

# Função para gerar arquivo de perfil temporário
generate_temp_profile() {
    local temp_profile="/tmp/custom_setup_$(date +%s).env"
    
    cat > "$temp_profile" << EOF
# Perfil personalizado gerado pelo setup interativo
PROFILE_NAME="Custom"
PROFILE_DESCRIPTION="Configuração personalizada via setup interativo"

# Componentes selecionados
INSTALL_NODEJS=${COMPONENTS[nodejs]:-false}
INSTALL_PYTHON=${COMPONENTS[python]:-false}
INSTALL_JAVA=${COMPONENTS[java]:-false}
INSTALL_GOLANG=${COMPONENTS[golang]:-false}

INSTALL_NVM=${COMPONENTS[nvm]:-false}
INSTALL_PYENV=${COMPONENTS[pyenv]:-false}
INSTALL_SDKMAN=${COMPONENTS[sdkman]:-false}
INSTALL_ASDF=${COMPONENTS[asdf]:-false}
INSTALL_PHPENV=false
INSTALL_BUN=${COMPONENTS[bun]:-false}

INSTALL_OPTIONAL_TOOLS=${COMPONENTS[gemini_cli]:-false}
INSTALL_DOCKER=${COMPONENTS[docker]:-false}
INSTALL_VSCODE=false

INSTALL_MODERN_UTILS=${COMPONENTS[modern_utils]:-false}

INSTALL_SPACESHIP_THEME=${COMPONENTS[spaceship_theme]:-false}
INSTALL_DRACULA_THEME=${COMPONENTS[dracula_theme]:-false}
INSTALL_EXTRA_PLUGINS=false
EOF

    echo "$temp_profile"
}

# Função para executar instalação
run_installation() {
    local profile_to_use="$1"
    
    draw_header
    echo -e "${GREEN}🚀 Iniciando Instalação...${NC}"
    echo ""
    
    # Criar backup antes da instalação
    echo -e "${BLUE}📦 Criando backup do estado atual...${NC}"
    "$PROJECT_DIR/tools/backup-system.sh" --create "interactive_$(date +%Y%m%d_%H%M%S)"
    
    echo ""
    echo -e "${BLUE}⚙️  Executando setup com perfil: $profile_to_use${NC}"
    echo ""
    
    # Executar setup
    if [[ "$profile_to_use" == "custom" ]]; then
        local temp_profile=$(generate_temp_profile)
        echo "Usando perfil temporário: $temp_profile"
        
        # Executar setup customizado (seria necessário modificar o setup.sh para aceitar perfil customizado)
        echo -e "${YELLOW}⚠️  Instalação customizada ainda não implementada no setup principal${NC}"
        echo -e "${BLUE}💡 Por enquanto, use os perfis pré-definidos${NC}"
        
        # Limpar arquivo temporário
        rm -f "$temp_profile"
    else
        "$PROJECT_DIR/setup.sh" --profile "$profile_to_use"
    fi
}

# Função principal do menu interativo
interactive_main() {
    # Inicializar componentes
    COMPONENTS[zsh]="true"
    COMPONENTS[git_config]="true"
    COMPONENTS[modern_utils]="false"
    COMPONENTS[nvm]="false"
    COMPONENTS[pyenv]="false"
    COMPONENTS[sdkman]="false"
    COMPONENTS[asdf]="false"
    COMPONENTS[nodejs]="false"
    COMPONENTS[python]="false"
    COMPONENTS[java]="false"
    COMPONENTS[golang]="false"
    COMPONENTS[bun]="false"
    COMPONENTS[spaceship_theme]="false"
    COMPONENTS[dracula_theme]="false"
    COMPONENTS[docker]="false"
    COMPONENTS[github_cli]="false"
    COMPONENTS[gemini_cli]="false"
    COMPONENTS[console_ninja]="false"
    COMPONENTS[dev_directories]="false"
    COMPONENTS[update_script]="false"
    
    while true; do
        show_profile_menu
        read -r choice
        
        case $choice in
            1)
                SELECTED_PROFILE="minimal"
                load_profile_components "minimal"
                show_selection_summary
                read -r confirm
                case $confirm in
                    i|I) run_installation "minimal"; return 0 ;;
                    e|E) CUSTOM_SETUP=true; break ;;
                    q|Q) return 0 ;;
                esac
                ;;
            2)
                SELECTED_PROFILE="frontend"
                load_profile_components "frontend"
                show_selection_summary
                read -r confirm
                case $confirm in
                    i|I) run_installation "frontend"; return 0 ;;
                    e|E) CUSTOM_SETUP=true; break ;;
                    q|Q) return 0 ;;
                esac
                ;;
            3)
                SELECTED_PROFILE="backend"
                load_profile_components "backend"
                show_selection_summary
                read -r confirm
                case $confirm in
                    i|I) run_installation "backend"; return 0 ;;
                    e|E) CUSTOM_SETUP=true; break ;;
                    q|Q) return 0 ;;
                esac
                ;;
            4)
                SELECTED_PROFILE="full"
                load_profile_components "full"
                show_selection_summary
                read -r confirm
                case $confirm in
                    i|I) run_installation "full"; return 0 ;;
                    e|E) CUSTOM_SETUP=true; break ;;
                    q|Q) return 0 ;;
                esac
                ;;
            5)
                CUSTOM_SETUP=true
                break
                ;;
            0)
                echo ""
                echo -e "${YELLOW}👋 Setup cancelado. Até logo!${NC}"
                return 0
                ;;
            *)
                echo ""
                echo -e "${RED}❌ Opção inválida. Pressione Enter para continuar.${NC}"
                read -r
                ;;
        esac
    done
    
    # Menu customizado
    if [[ "$CUSTOM_SETUP" == "true" ]]; then
        local current_page=1
        
        while true; do
            show_custom_menu $current_page
            read -r choice
            
            case $choice in
                # Navegação
                n|N) 
                    if [[ $current_page -lt 3 ]]; then
                        ((current_page++))
                    fi
                    ;;
                p|P)
                    if [[ $current_page -gt 1 ]]; then
                        ((current_page--))
                    fi
                    ;;
                s|S)
                    show_selection_summary
                    read -r confirm
                    case $confirm in
                        i|I) run_installation "custom"; return 0 ;;
                        e|E) continue ;;
                        q|Q) return 0 ;;
                    esac
                    ;;
                r|R)
                    for key in "${!COMPONENTS[@]}"; do
                        if [[ "$key" != "zsh" && "$key" != "git_config" ]]; then
                            COMPONENTS[$key]="false"
                        fi
                    done
                    ;;
                q|Q)
                    break
                    ;;
                *)
                    # Tentar alternar componente
                    if [[ -n "${COMPONENTS[$choice]:-}" && "$choice" != "zsh" && "$choice" != "git_config" ]]; then
                        toggle_component "$choice"
                    else
                        echo ""
                        echo -e "${RED}❌ Opção inválida. Pressione Enter para continuar.${NC}"
                        read -r
                    fi
                    ;;
            esac
        done
    fi
}

# Função principal
main() {
    case "${1:-}" in
        --help|-h)
            echo "Setup Interativo WSL ZSH Development Environment"
            echo ""
            echo "Uso:"
            echo "  $0                Iniciar modo interativo"
            echo "  $0 --help         Mostrar esta ajuda"
            echo ""
            return 0
            ;;
        *)
            interactive_main
            ;;
    esac
}

# Executar apenas se o script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 