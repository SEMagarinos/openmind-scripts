<#
.SYNOPSIS
    Instala glpi-agent en un host Windows y lo enruta a la Entidad del cliente por tag.

.DESCRIPTION
    Descarga el MSI oficial desde las releases de glpi-project en GitHub, lo instala en modo
    servicio silencioso apuntando a la instancia GLPI y fuerza un primer inventario.
    El tag define la Entidad/Ubicación vía las reglas de importación de GLPI
    (la tabla de tags por cliente es documentación interna, no está en este repo).

.EXAMPLE
    .\Install-GlpiAgent.ps1 -Tag CLIENTE01

.EXAMPLE
    .\Install-GlpiAgent.ps1 -Tag CLIENTE01 -Version 1.19
#>
param (
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    # Versión validada; antes de subirla revisar el changelog de glpi-agent.
    [string]$Version = "1.19",

    [string]$Server = "https://cop.openmind.com.ar/"
)

$ErrorActionPreference = "Stop"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Ejecutar en PowerShell como administrador."
}

$serverHost = ([Uri]$Server).Host
if (-not (Test-NetConnection $serverHost -Port 443 -InformationLevel Quiet)) {
    throw "Sin salida HTTPS (443) hacia $serverHost."
}

$msiName = "GLPI-Agent-$Version-x64.msi"
$msiPath = Join-Path $env:TEMP $msiName
$logPath = Join-Path $env:TEMP "glpi-agent-install.log"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host "Descargando $msiName..."
Invoke-WebRequest -UseBasicParsing `
    -Uri "https://github.com/glpi-project/glpi-agent/releases/download/$Version/$msiName" `
    -OutFile $msiPath

Write-Host "Instalando glpi-agent $Version con TAG=$Tag hacia $Server..."
$proc = Start-Process msiexec.exe -Wait -PassThru -ArgumentList @(
    "/i", "`"$msiPath`"", "/quiet",
    "SERVER=$Server",
    "TAG=$Tag",
    "RUNNOW=1",
    "/l*v", "`"$logPath`""
)
if ($proc.ExitCode -ne 0) {
    throw "msiexec terminó con código $($proc.ExitCode). Ver log: $logPath"
}

Get-Service -Name "GLPI-Agent" | Format-Table Name, Status, StartType
Write-Host "Listo. Verificar en GLPI que $env:COMPUTERNAME aparezca en la entidad del tag $Tag."
