# 🖥️ IaC - Provisionamento Automático de Infraestrutura Linux

Script Bash para provisionamento automático de usuários, grupos,
diretórios e permissões em servidores Linux.

## 📋 O que o script faz?

| Fase | Ação                        |
|------|-----------------------------|
| 1    | Cria 3 grupos de usuários   |
| 2    | Cria 9 usuários             |
| 3    | Cria 4 diretórios           |
| 4    | Configura todas as permissões |

### Estrutura criada

```
Grupos e Usuários:
├── GRP_ADM ─── carlos, maria, joao
├── GRP_VEN ─── debora, sebastiana, roberto
└── GRP_SEC ─── josefina, amanda, rogerio

Diretórios:
├── /publico  → 777 (todos acessam)
├── /adm      → 770 (somente GRP_ADM)
├── /ven      → 770 (somente GRP_VEN)
└── /sec      → 770 (somente GRP_SEC)
```

## 🚀 Como usar

### Opção 1 — Clone do GitHub
```bash
git clone https://github.com/seu-usuario/iac-linux-project.git
cd iac-linux-project
chmod +x iac_setup.sh
sudo ./iac_setup.sh
```

### Opção 2 — Download direto + execução
```bash
wget https://raw.githubusercontent.com/seu-usuario/iac-linux-project/main/iac_setup.sh
chmod +x iac_setup.sh
sudo ./iac_setup.sh
```

## ⚙️ Requisitos
- Sistema operacional Linux (Ubuntu/Debian recomendado)
- Acesso root (sudo)
- OpenSSL instalado

## ⚠️ Observações
- Senha padrão dos usuários: `Senha123`
- Troca de senha é obrigatória no primeiro login
- O script é **idempotente** (pode ser executado várias vezes)
```

---

## 📄 Arquivo: `.gitignore`

```gitignore
*.log
*.bak
*.swp
.DS_Store
```

---

## 🚀 Upload para o GitHub

```bash
# 1. Criar o repositório local
mkdir iac-linux-project && cd iac-linux-project

# 2. Criar os arquivos (cole o conteúdo acima em cada um)
nano iac_setup.sh
nano README.md
nano .gitignore

# 3. Tornar o script executável
chmod +x iac_setup.sh

# 4. Inicializar o Git e subir para o GitHub
git init
git add .
git commit -m "feat: script de provisionamento de infraestrutura Linux"
git branch -M main
git remote add origin https://github.com/seu-usuario/iac-linux-project.git
git push -u origin main
```

---

## 🧪 Testando em uma Nova VM

```bash
# Em qualquer nova máquina virtual, basta rodar:
sudo apt update && sudo apt install -y git

git clone https://github.com/seu-usuario/iac-linux-project.git
cd iac-linux-project
sudo ./iac_setup.sh
```

---

## 📊 Diagrama Visual da Infraestrutura

```
┌──────────────────────────────────────────────────────────┐
│                    SERVIDOR LINUX                         │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  GRUPOS          USUÁRIOS           DIRETÓRIOS           │
│  ──────          ────────           ───────────          │
│                                                          │
│  GRP_ADM ───┬── carlos             /publico [777]       │
│             ├── maria        ┌────▶ Todos acessam        │
│             └── joao         │                           │
│                              │     /adm     [770]       │
│  GRP_VEN ───┬── debora       │ ───▶ Só GRP_ADM          │
│             ├── sebastiana   │                           │
│             └── roberto      │     /ven     [770]       │
│                              │ ───▶ Só GRP_VEN          │
│  GRP_SEC ───┬── josefina     │                           │
│             ├── amanda       │     /sec     [770]       │
│             └── rogerio      └───▶ Só GRP_SEC           │
│                                                          │
└──────────────────────────────────────────────────────────┘

PERMISSÕES:
  777 = rwx rwx rwx (dono + grupo + outros)
  770 = rwx rwx --- (dono + grupo, outros sem acesso)
```

---

## ✅ Pontos-Chave do Script

| Recurso | Descrição |
|---|---|
| **Idempotente** | Verifica se grupo/usuário/diretório já existe antes de criar |
| **Seguro** | Senhas criptografadas com SHA-512 (`openssl passwd -6`) |
| **Forçar troca** | `passwd -e` expira a senha, obrigando troca no primeiro login |
| **Colorido** | Output com cores para facilitar leitura do resultado |
| **Relatório** | Gera resumo completo ao final da execução |
| **Versionado** | Pronto para versionamento no GitHub |
