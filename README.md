# MDT Deploy Monitor Web

Este projeto fornece um script em PowerShell que monitora o status de implantações via MDT (Microsoft Deployment Toolkit) e exibe as informações em tempo real por meio de uma página HTML atualizada automaticamente.

## 🔧 Tecnologias utilizadas

- **PowerShell**
- **Snap-in do MDT (`Microsoft.BDD.PSSnapIn`)**
- **HTML/CSS**

## 📊 Funcionalidade

O script:

    1. Lê os dados do MDT com `Get-MDTMonitorData`.
    2. Filtra apenas os computadores que ainda estão em processo (`Status -ne "Completed"`).
    3. Gera uma página HTML com uma tabela visual do progresso de cada máquina.
    4. Atualiza o arquivo a cada 15 segundos.
    5. Abre automaticamente no navegador na primeira execução.

## 📂 Estrutura do Arquivo HTML

A tabela HTML gerada contém:

- Nome do computador
- Progresso com barra visual
- Status da tarefa
- Etapa atual (`StepName`)
- Início e última atualização
- Total de etapas
- Indicadores de erro, aviso ou sucesso

## 📁 Caminho de saída

O arquivo HTML é salvo no seguinte caminho (ajustável conforme necessário):

## 🚀 Como usar

1. **Pré-requisitos:**
   - Windows com MDT instalado.
   - Acesso ao Deployment Share utilizado pelo MDT.

2. **Clone o repositório:**
   ```bash
   git clone https://github.com/Yurtachi/mdt-deploy-monitor-web.git

3.  **Configure o script**
   - Abra o arquivo mdt-deploy-monitor.ps1 em um editor de texto e localize as seguintes linhas:
     - $outputFolder = "C:\\Caminho\\Para\\Salvar\\HTML"
     - $deploymentSharePath = "E:\\DeploymentShare"
    
4. **Abra o PowerShell como administrador e execute o script:**
  - .\mdt-deploy-monitor.ps1
  
💡 O navegador será aberto automaticamente na primeira execução. A página HTML será atualizada a cada 15 segundos com as informações de progresso de deploy.
   
