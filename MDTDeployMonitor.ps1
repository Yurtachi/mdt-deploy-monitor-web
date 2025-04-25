# Importando o Snap-in do MDT
Add-PSSnapin Microsoft.BDD.PSSnapIn

# === CONFIGURAÇÕES INICIAIS (EDITE CONFORME SUA ESTRUTURA) ===
$outputFolder = "C:\Caminho\Para\Salvar\HTML"  # Caminho onde será salvo o HTML
$deploymentSharePath = "E:\DeploymentShare"       # Caminho do Deployment Share MDT

$outputPath = Join-Path $outputFolder "StatusDeploy.html"

Write-Host "Iniciando atualização em tempo real..." -ForegroundColor Green
$abriuBrowser = $false

while ($true) {
    try {
        # Cria o PSDrive temporário com base no caminho configurado
        $Driver = New-PSDrive -Name DS001 -PSProvider "Microsoft.BDD.PSSnapIn\MDTProvider" -Root $deploymentSharePath

        # Obtém os dados do monitoramento e filtra os que ainda não finalizaram
        $computers = Get-MDTMonitorData -Path "$($Driver.Name):" | Where-Object { $_.Status -ne "Completed" }

        # Remove o PSDrive após uso
        Remove-PSDrive -Name "$($Driver.Name)" -Force

        # Geração da página HTML
        $html = @"
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="15">
    <title>Status de Deployment MDT</title>
    <link rel="icon" type="image/png" href="https://cdn-icons-png.flaticon.com/256/3867/3867325.png">
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; background: #fff; }
        th, td { border: 1px solid #ccc; padding: 10px; text-align: left; }
        th { background-color: #0078D4; color: white; }
        tr:hover { background-color: #f1f1f1; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .status { font-weight: bold; }
        .progress-bar { background-color: #eee; border-radius: 4px; overflow: hidden; }
        .progress-bar > div { background-color: #0078D4; height: 10px; }
    </style>
</head>
<body>
    <h1>Status de Deployment MDT</h1>
    <p>Atualizado em: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</p>
    <table>
        <thead>
            <tr>
                <th>Nome do Computador</th>
                <th>Progresso</th>
                <th>Status</th>
                <th>Etapa Atual</th>
                <th>Início</th>
                <th>Última Atualização</th>
                <th>Etapas Totais</th>
                <th>Detalhes</th>
            </tr>
        </thead>
        <tbody>
"@

        foreach ($pc in $computers) {
            $percent = [math]::Round($pc.PercentComplete)
            $etapaAtual = if ($pc.StepName) { $pc.StepName } else { "Finalizado ou iniciando" }
            $startTimeFormatted = $pc.StartTime.ToString("dd/MM/yyyy HH:mm:ss")
            $lastTimeFormatted = $pc.LastTime.ToString("dd/MM/yyyy HH:mm:ss")

            $detalhesHtml = ""
            if ($pc.Errors -gt 0) {
                $detalhesHtml = "<span title='Erros: $($pc.Errors)' style='color: red;'>❌</span>"
            } elseif ($pc.Warnings -gt 0) {
                $detalhesHtml = "<span title='Avisos: $($pc.Warnings)' style='color: orange;'>⚠️</span>"
            } else {
                $detalhesHtml = "<span title='Sem erros ou avisos' style='color: green;'>✔️</span>"
            }

            $html += @"
    <tr>
        <td>$($pc.Name)</td>
        <td>
            <div class='progress-bar'><div style='width: ${percent}%;'></div></div>
            $percent%
        </td>
        <td class='status'>$($pc.Status)</td>
        <td>$etapaAtual</td>
        <td>$startTimeFormatted</td>
        <td>$lastTimeFormatted</td>
        <td>$($pc.CurrentStep)/$($pc.TotalSteps)</td>
        <td>$detalhesHtml</td>
    </tr>
"@
        }

        $html += @"
        </tbody>
    </table>
</body>
</html>
"@

        # Salva o HTML
        $html | Out-File -Encoding utf8 -FilePath $outputPath

        # Abre no navegador na primeira execução
        if (-not $abriuBrowser -and (Test-Path $outputPath)) {
            Start-Process $outputPath
            $abriuBrowser = $true
        }

    } catch {
        Write-Warning "Erro ao atualizar: $_"
    }

    Start-Sleep -Seconds 15
}
