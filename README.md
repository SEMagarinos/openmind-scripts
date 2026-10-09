# openmind-scripts

Scripts operativos **públicos y genéricos** de Open Mind: se descargan directo en los
hosts que administramos, sin credenciales ni token.

> Este repo es público. **Nunca** agregar credenciales, tokens, IPs internas, nombres de
> hosts ni datos de clientes. Todo lo que sea específico de un cliente se pasa como
> parámetro en el momento de ejecutar.

## glpi-agent

Instala [glpi-agent](https://github.com/glpi-project/glpi-agent) con el instalador oficial
y lo enruta a la entidad del cliente mediante un tag.

Windows (PowerShell como administrador):

```powershell
irm https://raw.githubusercontent.com/SEMagarinos/openmind-scripts/main/glpi-agent/Install-GlpiAgent.ps1 -OutFile "$env:TEMP\Install-GlpiAgent.ps1"
powershell -ExecutionPolicy Bypass -File "$env:TEMP\Install-GlpiAgent.ps1" -Tag <TAG>
```

Linux (root):

```bash
curl -fsSL -o /tmp/install-glpi-agent.sh https://raw.githubusercontent.com/SEMagarinos/openmind-scripts/main/glpi-agent/install-glpi-agent.sh
bash /tmp/install-glpi-agent.sh <TAG>
```

Parámetros opcionales: versión del agente (default `1.19`) y URL del servidor GLPI.
