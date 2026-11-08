#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}[+] Iniciando Otimização e Provisionamento do Fedora Silverblue...${NC}\n"

# 0. Atualização SO
echo -e "${YELLOW}--> Atualizando Fedora Silverblue...${NC}"
rpm-ostree update

# 1. Atualização e Limpeza de Flatpaks
echo -e "${YELLOW}--> Atualizando aplicativos Flatpak...${NC}"
flatpak update -y

echo -e "${YELLOW}--> Removendo runtimes do Flatpak não utilizados...${NC}"
flatpak uninstall --unused -y

# 2. Otimizações de Desempenho e Kernel (Para Jogos/VKD3D)
echo -e "\n${YELLOW}--> Verificando parâmetros do Kernel (Otimização do Scheduler)...${NC}"
CURRENT_KARGS=$(rpm-ostree kargs)
KARGS_TO_ADD=""

# Verifica se os kargs já existem antes de os adicionar
if [[ "$CURRENT_KARGS" != *"split_lock_mitigate=0"* ]]; then
    KARGS_TO_ADD="$KARGS_TO_ADD --append=split_lock_mitigate=0"
fi

if [[ "$CURRENT_KARGS" != *"mitigations=off"* ]]; then
    KARGS_TO_ADD="$KARGS_TO_ADD --append=mitigations=off"
fi

if [ -n "$KARGS_TO_ADD" ]; then
    echo -e "${GREEN}[+] Injetando novos parâmetros no Kernel...${NC}"
    rpm-ostree kargs $KARGS_TO_ADD
else
    echo -e "${GREEN}[+] Parâmetros de Kernel já otimizados.${NC}"
fi

# 3. Instalação do GameMode
echo -e "\n${YELLOW}--> Verificando serviço GameMode no sistema base...${NC}"
if ! rpm -q gamemode &> /dev/null; then
    echo -e "${GREEN}[+] Instalando GameMode via rpm-ostree...${NC}"
    rpm-ostree install gamemode
else
    echo -e "${GREEN}[+] GameMode já se encontra instalado.${NC}"
fi

# 4. Melhoria do vm.max_map_count
echo -e "\n${YELLOW}--> Verificando configuração de vm.max_map_count...${NC}"
CURRENT_MAP_COUNT=$(sysctl -n vm.max_map_count)
TARGET_MAP_COUNT="2147483642"

if [ "$CURRENT_MAP_COUNT" == "$TARGET_MAP_COUNT" ]; then
    echo -e "${GREEN}[+] vm.max_map_count já está configurado corretamente ($TARGET_MAP_COUNT). Pulando...${NC}"
else
    echo -e "${YELLOW}--> Aplicando nova configuração ($TARGET_MAP_COUNT)...${NC}"
    echo "vm.max_map_count=$TARGET_MAP_COUNT" | sudo tee /etc/sysctl.d/99-gaming.conf > /dev/null
    sudo sysctl --system
    echo -e "${GREEN}[+] Configuração aplicada com sucesso!${NC}"
fi

# 5. Provisionamento do Contêiner de Segurança
echo -e "\n${YELLOW}--> Configuração de Contêiner (Toolbox/Distrobox)${NC}"
read -p "Deseja provisionar o contêiner de segurança (Kali Linux) agora? (s/n): " CRIAR_CONTAINER

if [[ "$CRIAR_CONTAINER" =~ ^[Ss]$ ]]; then
    if command -v toolbox &> /dev/null; then
        echo -e "${YELLOW}--> Criando contêiner via Toolbox...${NC}"
        toolbox create --image docker.io/kalilinux/kali-rolling:latest -c kali-sec
        echo -e "${GREEN}[+] Contêiner 'kali-sec' criado com sucesso!${NC}"
    elif command -v distrobox &> /dev/null; then
        echo -e "${YELLOW}--> Criando contêiner via Distrobox...${NC}"
        distrobox create --name kali-sec --image docker.io/kalilinux/kali-rolling:latest --yes
        echo -e "${GREEN}[+] Contêiner 'kali-sec' criado com sucesso!${NC}"
    else
        echo -e "${RED}[!] Nem Toolbox nem Distrobox encontrados. Instale um deles primeiro.${NC}"
    fi
else
    echo -e "${YELLOW}--> Criação de contêiner ignorada pelo utilizador.${NC}"
fi

echo -e "\n${GREEN}[+] Tarefas concluídas!${NC}"
echo -e "${YELLOW}[!] ATENÇÃO: Se foram feitas alterações no Kernel ou o GameMode foi instalado, você DEVE reiniciar o computador para iniciar na nova imagem OSTree.${NC}"
