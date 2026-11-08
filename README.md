Fedora Silverblue Security & AI Efficiency Optimizer

Este repositório contém um script Bash automatizado para a manutenção de sistemas imutáveis Fedora Silverblue, otimização de baixo nível para cargas de trabalho de Inteligência Artificial Local (Inferência de LLMs) e provisionamento isolado de um laboratório de cibersegurança via Distrobox/Toolbox.

O projeto demonstra como afinar o kernel, o agendamento de hardware (AMD Ryzen + Radeon) e a gestão térmica para maximizar a estabilidade e eliminar picos desnecessários de consumo energético ao executar modelos de IA locais e ferramentas de pentest.

Especificações e Engenharia de Hardware

Processador: AMD Ryzen 7 5700X3D (Arrefecimento Corsair Nautilus RS 360mm AIO)

Placa Gráfica: PowerColor Red Devil AMD Radeon RX 6900 XT (16GB VRAM, com mod térmico e exaustão ativa no backplate)

Armazenamento: SSD NVMe em Btrfs (noatime, compress=zstd:1)

Eficiência Aplicada à IA Local

Curva PBO Per-Core (Ryzen 7 5700X3D): Afinação manual avançada por núcleo, mantendo os principais núcleos com uma curva mais agressiva para preservar o desempenho em single-core (Core 0: -15, Core 1: -10, Core 2: -20, Core 3-7: -30), mantendo o 3D V-Cache frio durante o carregamento massivo de tensores e prompt evaluation, eliminando o thermal throttling.

Teto de Potência (LACT - RX 6900 XT): Undervolt aplicado em -80mV, cortando drasticamente a dissipação térmica e o ruído das ventoinhas sob inferência contínua de LLMs locais, mantendo o rendimento máximo de tokens por segundo. Por ser um workload limitado por largura de banda de VRAM, foi aplicado também um Overclock na VRAM de +7.8% com Fast Timings ativos, aumentando a largura de banda e mitigando o gargalo das memórias. Para reduzir ainda mais as temperaturas e manter o hardware frio sem perda de desempenho e com desgaste mínimo, foi realizado o repaste com pasta térmica de alta condutividade térmica, a substituição dos thermal pads por thermal putty de alta condutividade em pontos críticos, e a adição de um mod de ventoinhas auxiliares no backplate o que, em conjunto, mantém as temperaturas da memória e dos VRMs baixas mesmo sob cargas elevadas de trabalho.

Funcionalidades do Script (silverblue-optimizer.sh)

Manutenção Imutável (rpm-ostree): Limpeza profunda de metadados (-m), pacotes pendentes (-p) e deployments base antigos (-b), prevenindo o inchaço da imagem do sistema base e executando a atualização do mesmo.

Gerenciamento de Flatpaks: Atualização automática de aplicativos sandbox e remoção de runtimes órfãos.

Ajuste de vm.max_map_count: Eleva o limite de mapeamento de memória para 2147483642, prevenindo crashes silenciosos e falhas de alocação ao carregar ficheiros de pesos de IA massivos ou motores gráficos pesados.

Otimizações de Kernel (kargs): Injeção de split_lock_mitigate=0 e mitigations=off para livrar o agendador de overheads de segurança excessivos.

Security Check: Validação do status de execução do serviço de firewall nativo (firewalld).

Instalação do GameMode: Garante a presença do serviço de otimização de desempenho dinâmico de jogos e aplicações de alta prioridade.

Provisionamento de Laboratório (Toolbox): Verifica a presença do Toolbox e cria automaticamente um contêiner isolado (kali-sec) baseado na imagem oficial do kali-rolling, pronto para ferramentas como Nmap, Metasploit e Wireshark sem tocar na raiz do Fedora.

## Como Utilizar

Faça o clone deste repositório e execute o script no seu terminal. Algumas ações de sistema (`rpm-ostree`) podem solicitar sua senha administrativa.

```bash
git clone https://github.com/nemo-sec/silverblue-optimizer.git
cd silverblue-optimizer
chmod +x silverblue-optimizer.sh
./silverblue-optimizer.sh
```
## Acessando o Laboratório de Segurança

Após a execução do script, o seu contêiner do Kali Linux estará criado e integrado ao seu terminal. Para acessá-lo, execute:

```bash
toolbox enter kali-sec
```
Nota de Arquitetura: Caso o rpm-ostree baixe uma nova imagem de sistema principal durante a execução, será necessário reiniciar o computador para aplicar a atualização da camada base do Fedora. O contêiner permanecerá intacto.
