#!/bin/bash

###############################################################################
#                   INFRAESTRUTURA COMO CÓDIGO (IaC)                         #
#              Provisionamento Automático de Ambiente Linux                    #
#                                                                             #
#  Este script cria automaticamente:                                          #
#    - Grupos de usuários                                                     #
#    - Usuários com senhas e shells configurados                              #
#    - Estrutura de diretórios                                                #
#    - Permissões de acesso                                                   #
#                                                                             #
#  Uso: sudo ./iac_setup.sh                                                   #
###############################################################################

# ========================== CORES PARA OUTPUT ================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ========================== FUNÇÕES AUXILIARES ===============================

print_header() {
    echo ""
    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}============================================================${NC}"
    echo ""
}

print_success() {
    echo -e "  ${GREEN}[✔] $1${NC}"
}

print_warning() {
    echo -e "  ${YELLOW}[!] $1${NC}"
}

print_error() {
    echo -e "  ${RED}[✘] $1${NC}"
}

print_info() {
    echo -e "  ${BLUE}[i] $1${NC}"
}

# ========================== VERIFICAÇÃO DE ROOT ==============================

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_error "Este script precisa ser executado como root (sudo)!"
        echo ""
        echo "  Uso correto: sudo ./iac_setup.sh"
        echo ""
        exit 1
    fi
}

# ========================== CRIAÇÃO DE GRUPOS ================================

create_groups() {
    print_header "FASE 1: CRIANDO GRUPOS DE USUÁRIOS"

    local GROUPS=("GRP_ADM" "GRP_VEN" "GRP_SEC")

    for group in "${GROUPS[@]}"; do
        if getent group "$group" > /dev/null 2>&1; then
            print_warning "Grupo '$group' já existe. Pulando..."
        else
            groupadd "$group"
            if [ $? -eq 0 ]; then
                print_success "Grupo '$group' criado com sucesso!"
            else
                print_error "Falha ao criar grupo '$group'!"
            fi
        fi
    done
}

# ========================== CRIAÇÃO DE USUÁRIOS ==============================

create_user() {
    local username=$1
    local group=$2
    local full_name=$3
    local default_password="Senha123"

    if id "$username" > /dev/null 2>&1; then
        print_warning "Usuário '$username' já existe. Pulando..."
    else
        # Cria o usuário com:
        #   -m           → cria o diretório home
        #   -s           → define o shell padrão (bash)
        #   -G           → grupo suplementar
        #   -c           → comentário (nome completo)
        #   -p           → senha criptografada
        local encrypted_password=$(openssl passwd -6 "$default_password")

        useradd -m \
                -s /bin/bash \
                -G "$group" \
                -c "$full_name" \
                -p "$encrypted_password" \
                "$username"

        # Força troca de senha no primeiro login
        passwd -e "$username" > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            print_success "Usuário '$username' criado → Grupo: $group"
        else
            print_error "Falha ao criar usuário '$username'!"
        fi
    fi
}

create_all_users() {
    print_header "FASE 2: CRIANDO USUÁRIOS"

    # ---- Usuários do grupo GRP_ADM (Administração) ----
    print_info "Grupo GRP_ADM (Administração):"
    create_user "carlos"    "GRP_ADM" "Carlos Silva"
    create_user "maria"     "GRP_ADM" "Maria Oliveira"
    create_user "joao"      "GRP_ADM" "João Santos"
    echo ""

    # ---- Usuários do grupo GRP_VEN (Vendas) ----
    print_info "Grupo GRP_VEN (Vendas):"
    create_user "debora"      "GRP_VEN" "Débora Lima"
    create_user "sebastiana"  "GRP_VEN" "Sebastiana Costa"
    create_user "roberto"     "GRP_VEN" "Roberto Almeida"
    echo ""

    # ---- Usuários do grupo GRP_SEC (Segurança) ----
    print_info "Grupo GRP_SEC (Segurança):"
    create_user "josefina"  "GRP_SEC" "Josefina Pereira"
    create_user "amanda"    "GRP_SEC" "Amanda Rodrigues"
    create_user "rogerio"   "GRP_SEC" "Rogério Ferreira"
}

# ========================== CRIAÇÃO DE DIRETÓRIOS ============================

create_directories() {
    print_header "FASE 3: CRIANDO ESTRUTURA DE DIRETÓRIOS"

    local DIRS=("/publico" "/adm" "/ven" "/sec")

    for dir in "${DIRS[@]}"; do
        if [ -d "$dir" ]; then
            print_warning "Diretório '$dir' já existe. Pulando criação..."
        else
            mkdir -p "$dir"
            print_success "Diretório '$dir' criado com sucesso!"
        fi
    done
}

# ========================== CONFIGURAÇÃO DE PERMISSÕES =======================

set_permissions() {
    print_header "FASE 4: CONFIGURANDO PERMISSÕES"

    # ---- /publico → Acesso total para todos ----
    chown root:root /publico
    chmod 777 /publico
    print_success "/publico → Permissão 777 (acesso total para todos)"

    # ---- /adm → Somente grupo GRP_ADM ----
    chown root:GRP_ADM /adm
    chmod 770 /adm
    print_success "/adm     → Permissão 770 (dono + GRP_ADM apenas)"

    # ---- /ven → Somente grupo GRP_VEN ----
    chown root:GRP_VEN /ven
    chmod 770 /ven
    print_success "/ven     → Permissão 770 (dono + GRP_VEN apenas)"

    # ---- /sec → Somente grupo GRP_SEC ----
    chown root:GRP_SEC /sec
    chmod 770 /sec
    print_success "/sec     → Permissão 770 (dono + GRP_SEC apenas)"
}

# ========================== RELATÓRIO FINAL ==================================

print_report() {
    print_header "RELATÓRIO FINAL DA INFRAESTRUTURA"

    echo -e "  ${BLUE}┌─────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${BLUE}│              GRUPOS CRIADOS                         │${NC}"
    echo -e "  ${BLUE}├─────────────────────────────────────────────────────┤${NC}"

    for group in GRP_ADM GRP_VEN GRP_SEC; do
        members=$(getent group "$group" | cut -d: -f4)
        echo -e "  ${BLUE}│${NC}  $group: $members"
    done

    echo -e "  ${BLUE}├─────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${BLUE}│              DIRETÓRIOS E PERMISSÕES                │${NC}"
    echo -e "  ${BLUE}├─────────────────────────────────────────────────────┤${NC}"

    for dir in /publico /adm /ven /sec; do
        perms=$(stat -c "%a %U:%G" "$dir" 2>/dev/null)
        echo -e "  ${BLUE}│${NC}  $dir → $perms"
    done

    echo -e "  ${BLUE}├─────────────────────────────────────────────────────┤${NC}"
    echo -e "  ${BLUE}│              USUÁRIOS CRIADOS                       │${NC}"
    echo -e "  ${BLUE}├─────────────────────────────────────────────────────┤${NC}"

    for user in carlos maria joao debora sebastiana roberto josefina amanda rogerio; do
        if id "$user" > /dev/null 2>&1; then
            groups_list=$(id -nG "$user" | tr ' ' ', ')
            echo -e "  ${BLUE}│${NC}  $user → Grupos: $groups_list"
        fi
    done

    echo -e "  ${BLUE}└─────────────────────────────────────────────────────┘${NC}"

    echo ""
    echo -e "  ${YELLOW}⚠  Senha padrão: Senha123 (troca obrigatória no 1º login)${NC}"
    echo ""
}

# ========================== EXECUÇÃO PRINCIPAL ===============================

main() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║     🚀  SCRIPT DE PROVISIONAMENTO DE INFRAESTRUTURA  🚀   ║${NC}"
    echo -e "${GREEN}║                    Versão 1.0                              ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"

    check_root

    create_groups
    create_all_users
    create_directories
    set_permissions
    print_report

    echo -e "${GREEN}  ✅ Infraestrutura provisionada com sucesso!${NC}"
    echo ""
}

# Executa o script
main

exit 0
