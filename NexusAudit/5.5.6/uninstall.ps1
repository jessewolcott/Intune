$PackageName = "Nexus Audit 5.5.6"

$Path_local = "$Env:Programfiles\_MEM" # "$ENV:LOCALAPPDATA\_MEM" for user context installations
Start-Transcript -Path "$Path_local\uninstall\$PackageName-install.txt" -Force

try{
    Write-Output "Stopping process"
    Stop-Process -Name "NexusAudit" -force -confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    
    Write-Output "Uninstalling with MSI"
    # MSI Exec uninstall
    #Start-Process 'msiexec.exe' -ArgumentList '/x {C5A147FC-76FB-408D-BA84-9CE8ED8B01D8}' #MsiExec.exe /I{898D2FFB-8AFF-41FB-8F89-4629B7454D73}
    $ExitCode = (Start-Process 'msiexec.exe' -ArgumentList '/uninstall {898D2FFB-8AFF-41FB-8F89-4629B7454D73} /qn' -wait -PassThru -ErrorAction SilentlyContinue).Exitcode

    Write-output "We exited with a code of $Exitcode"

    If ($ExitCode -eq "0"){
    # Remove Program Folder
    Write-Output "Removing program folders"
    Remove-Item -Path "C:\Program Files (x86)\Nexus Insurance Solutions\NexusAudit" -force -Recurse

    # Remove User Configs
    Write-Output "Removing all user configs"
    $CurrentUser = (((Get-WMIObject -class Win32_ComputerSystem).username) -creplace '^[^\\]*\\', '')
    Remove-Item -Path "C:\Users\$CurrentUser\AppData\Local\Nexus_Insurance_Solutions\NexusAudit.exe*" -Recurse -Force -ErrorAction SilentlyContinue
        
    # Remove Desktop Shortcuts
    Write-Output "Removing old desktop shortcuts"
    Remove-Item -Path "C:\Users\Public\Desktop\*NexusAudit*.lnk" -force}


}catch{
    Write-Host "_____________________________________________________________________"
    Write-Host "ERROR while uninstalling $PackageName"
    Write-Host "$_"
}

Stop-Transcript

# 898D2FFB-8AFF-41FB-8F89-4629B7454D73