<#
.SYNOPSIS
    Audits the explicit permission levels for specific folders in a SharePoint site.

.DESCRIPTION
    This script connects to a SharePoint site using PnP.PowerShell with a Client ID
    and reads the role assignments for the specified folders. It then displays a
    simplified table showing the user/group and their assigned permission level,
    while excluding system-related 'Limited Access' entries.

.NOTES
    - Requires the PnP.PowerShell module (Install-Module PnP.PowerShell).
    - Requires a Client ID with Full Control permissions on the target site for 
      accessing RoleAssignments via ListItemAllFields.
#>

Import-Module PnP.PowerShell

# --- Configuration ---
$SiteURL = "https://seusite.sharepoint.com/sites/DOCSCLIENT/2025" 
$ClientId = "API key with full permission to the site" 
$FolderPaths = @(
    "SHARED DOCS/Production",
    "" # Add more folder paths here (e.g., "Documents/Reports")
)
# --- End Configuration ---

Write-Host "Please sign in with your account" -ForegroundColor Cyan
Connect-PnPOnline -Url $SiteURL -ClientId $ClientId -Interactive -ErrorAction Stop
Write-Host "✅ Connection established." -ForegroundColor Green

Write-Host "`nFetching folder object (Please wait, this may take a few moments)..." -ForegroundColor Yellow
    
function GetFolderPermissions {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$Folders
    )
    
    foreach ($FolderURL in $Folders){
        try {
            
            # Fetch the folder object, including ListItemAllFields and its RoleAssignments
            $folderObj = Get-PnPFolder -Url $FolderURL -Includes ListItemAllFields, ListItemAllFields.RoleAssignments -ErrorAction Stop

            Write-Host "`n--- RELEVANT PERMISSIONS AUDIT ---" -ForegroundColor Blue            
            
            $SimplifiedPermissions = @()

            foreach ($roleAssignment in $folderObj.ListItemAllFields.RoleAssignments) {

                # Lazily load Member and RoleDefinitionBindings properties
                Get-PnPProperty -ClientObject $roleAssignment -Property Member, RoleDefinitionBindings -ErrorAction Stop
                
                $UserName = $roleAssignment.Member.Title 
                # Fallback to LoginName if the Title is empty (e.g., for certain users/groups)
                if (-not $UserName) { $UserName = $roleAssignment.Member.LoginName }

                # Get the name(s) of the permission level(s) assigned
                $PermissionLevels = $roleAssignment.RoleDefinitionBindings | Select-Object -ExpandProperty Name
                $PermissionString = $PermissionLevels -join ', '
                

                # Skip 'Limited Access' entries, which are usually required internally by SharePoint
                if ($PermissionString -eq 'Limited Access') { continue }
                if ($UserName -like 'Limited Access System Group*') { continue }


                # Adds the formatted entry to the list
                $SimplifiedPermissions += [PSCustomObject]@{
                    'User/Group' = $UserName
                    'Permission Level' = $PermissionString
                }
            }
            
            # 3. Formats and displays the simple table
            Write-Host "Folder Path: $FolderURL" -ForegroundColor Green
            $SimplifiedPermissions | Format-Table -AutoSize -Wrap

        } catch {
            Write-Host "❌ Error processing folder '$FolderURL':" -ForegroundColor Red
            Write-Host "Original Message: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
}

GetFolderPermissions -Folders $FolderPaths

Disconnect-PnPOnline