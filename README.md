# SharePoint Folder Permissions Auditor  
**PowerShell script para auditoria de permissões explícitas em pastas específicas do SharePoint Online**

[![PowerShell](https://img.shields.io/badge/PowerShell-7.2%2B-blue?logo=powershell)](https://github.com/PowerShell/PowerShell)  [![PnP.PowerShell](https://img.shields.io/badge/PnP.PowerShell-2.0%2B-green)](https://pnp.github.io/powershell/)  

---

## Descrição do Projeto

Este script em **PowerShell** realiza uma **auditoria detalhada das permissões explícitas** aplicadas em pastas específicas dentro de um site do **SharePoint Online**.

Ele utiliza o módulo **`PnP.PowerShell`** para conectar-se ao site com autenticação via **Azure AD App (Client ID)** e exibe uma tabela simplificada com:

- **Usuário ou Grupo**
- **Nível de permissão atribuído**



---

## Pré-requisitos (OBRIGATÓRIO)

| Item | Requisito |
|------|---------|
| **PowerShell** | **Versão 7.2 ou superior** (não funciona no Windows PowerShell 5.1) |
| **Módulo PnP.PowerShell** | `Install-Module PnP.PowerShell -Scope CurrentUser` |
| **Permissões no Azure AD** | App registrada com **permissão de API `Sites.FullControl.All` (Application)** no Microsoft Graph |
| **Acesso ao site SharePoint** | Usuário com **Full Control** no site alvo (para ler `ListItemAllFields.RoleAssignments`) |

> **Atenção:** O script **não funciona com contas de serviço ou MFA direto**. É necessário usar **Client ID + login interativo**.

---

## Passo a Passo: Configuração Completa

### 1. Instalar PowerShell 7+

powershell
Verifique sua versão
$PSVersionTable.PSVersion
Baixe em: https://github.com/PowerShell/PowerShell/releases
Ou via winget (Windows):
winget install --id Microsoft.PowerShell --source winget


### 2. Instalar o módulo PnP.PowerShell
powershellInstall-Module PnP.PowerShell -Scope CurrentUser -Force
Confirme com Y se solicitado. Verifique a versão instalada com Get-Module PnP.PowerShell.

### 3. Registrar App no Azure AD (API Permissions)

Acesse: [https://entra.microsot.com](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade) → App registrations
Clique em New registration
Name: SharePoint-Permissions-Auditor
Supported account types: Accounts in this organizational directory only
Redirect URI: deixe em branco (ou use http://localhost se necessário para interativo)

Após criar, copie:
Application (client) ID
Directory (tenant) ID (pode ser necessário para autenticação avançada)


> [!IMPORTANT]
> This is a crucial note that users must pay attention to.
> It contains vital information for successful completion.
> **API Permissions require Full Control access to the SharePoint site and relevant permissions for Microsoft Graph.**


---

Abra o arquivo Audit-FolderPermissions.ps1 e edite a seção de configuração:
````powershell
# --- Configuration ---
$SiteURL = "https://seusite.sharepoint.com/sites/DOCSCLIENT/2025" #<<<<------- CAMINHO DO SITE
$ClientId = "SEU-CLIENT-ID-AQUI" 
$FolderPaths = @(
    "SHARED DOCS/Production",  # <<<------ CAMINHO DA PASTA DENTRO DO SITE
    "SHARED DOCS/Production/freelas"
)
````
> **Exclui automaticamente entradas de "Limited Access"** (geradas pelo sistema SharePoint para controle interno).

> [!IMPORTANT]
> Caminhos das pastas são relativos à biblioteca raiz (ex: Shared Documents). Certifique-se de que o site existe e você tem acesso.
