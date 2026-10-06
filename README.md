# Fedora Silverblue Security & Maintenance Optimizer

Este repositório contém um script Bash automatizado para manutenção do sistema imutável **Fedora Silverblue** e provisionamento de um laboratório de segurança cibernética utilizando **Distrobox**.

Ao invés de instalar ferramentas de pentest diretamente no sistema operacional e comprometer a estabilidade ou segurança do host, este projeto automatiza a criação de um contêiner isolado baseado no Kali Linux.

## ⚙ Funcionalidades

- **Manutenção Imutável (`rpm-ostree`):** Limpeza profunda de metadados (`-m`), pacotes pendentes (`-p`) e deployments base antigos (`-b`), prevenindo o inchaço da imagem do sistema base.
- **Gerenciamento de Flatpaks:** Atualização automática de aplicativos sandbox e remoção de runtimes órfãos.
- **Security Check:** Validação do status de execução do serviço de firewall nativo (`firewalld`).
- **Provisionamento de Laboratório (Distrobox):** Verifica a presença do Distrobox e cria automaticamente um contêiner (`kali-sec`) baixando a imagem oficial do `kali-rolling`, pronto para a instalação de pacotes como Nmap, Metasploit e Wireshark sem tocar na raiz do Fedora.

## Como Utilizar

Faça o clone deste repositório e execute o script no seu terminal. Algumas ações de sistema (`rpm-ostree`) podem solicitar sua senha administrativa.

```bash
cd silverblue-optimizer
chmod +x silverblue-optimizer.sh
./silverblue-optimizer.sh
```
## Acessando o Laboratório de Segurança

Após a execução do script, o seu contêiner do Kali Linux estará criado e integrado ao seu terminal. Para acessá-lo, execute:

```bash
distrobox enter kali-sec
```
Nota de Arquitetura: Caso o rpm-ostree baixe uma nova imagem de sistema principal durante a execução, será necessário reiniciar o computador para aplicar a atualização da camada base do Fedora. O contêiner permanecerá intacto.
