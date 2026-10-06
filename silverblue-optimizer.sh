#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+] Iniciando Otimização e Provisionamento do Fedora Silverblue...${NC}\n"

# 1. Atualização e Limpeza de Flatpaks
echo -e "${YELLOW}--> Atualizando aplicativos Flatpak...${NC}"
flatpak update -y
echo -e "${YELLOW}--> Removendo runtimes do Flatpak não utilizados...${NC}"
flatpak uninstall --unused -y

# 2. Manutenção do rpm-ostree (Sistema Base)
echo -e "${YELLOW}--> Limpando deployments antigos e metadados do rpm-ostree...${NC}"
rpm-ostree cleanup -m -p -b

# 3. Atualização do Sistema Base
echo -e "${YELLOW}--> Verificando atualizações do sistema imutável...${NC}"
rpm-ostree upgrade

# 4. Verificação de Segurança (Firewall)
echo -e "${YELLOW}--> Status do Firewalld (Firewall Nativo):${NC}"
systemctl status firewalld --no-pager | grep Active

# 5. Provisionamento do Contêiner de Segurança (Distrobox)
echo -e "\n${YELLOW}--> Verificando ambiente de contêiner de segurança...${NC}"
if command -v distrobox &> /dev/null; then
    if distrobox list | grep -q "kali-sec"; then
        echo -e "${GREEN}[+] Contêiner 'kali-sec' já está provisionado e pronto para uso.${NC}"
    else
        echo -e "${YELLOW}--> Criando contêiner 'kali-sec' baseado no Kali Linux (Rolling)...${NC}"
        # Puxa a imagem oficial do Kali e cria o contêiner aceitando os prompts automaticamente
        distrobox create --name kali-sec --image docker.io/kalilinux/kali-rolling:latest --yes
        echo -e "${GREEN}[+] Contêiner de segurança criado com sucesso!${NC}"
    fi
else
    echo -e "${RED}[!] Comando 'distrobox' não encontrado. O contêiner não foi criado.${NC}"
    echo -e "${YELLOW}Para habilitar este recurso, instale o Distrobox via rpm-ostree.${NC}"
fi

echo -e "\n${GREEN}[+] Tarefas concluídas!${NC}"
echo -e "${YELLOW}--> Para acessar seu laboratório de segurança, digite: distrobox enter kali-sec${NC}"
