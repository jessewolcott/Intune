$PackageName = "Nexus Audit 5.5.6" # replace with your package name

$Path_local = "$Env:Programfiles\_MEM" # "$ENV:LOCALAPPDATA\_MEM" for user context installations
Start-Transcript -Path "$Path_local\$PackageName-install.txt" -Force
$ErrorActionPreference = 'Stop'

try{

    # Stop NexusAudit if running
    Stop-Process -Name "NexusAudit*" -force -confirm:$false -ErrorAction SilentlyContinue
    # Install MSI
    Write-Output "Installing $PackageName"
    $Exitcode = (Start-Process ".\Source\NexusAuditProdRelease.5.5.6.msi" -ArgumentList "/quiet ALLUSERS=1" -wait -PassThru).Exitcode

    if ($Exitcode -eq '0'){
        # Clean up old shortcuts
        Write-Output "Removing old desktop shortcuts"
        Remove-Item -Path "C:\Users\Public\Desktop\*NexusAudit*.lnk" -force

        # Create new desktop shortcuts
        Write-Output "Creating new desktop shortcuts"
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\NexusAudit-5.5.6.lnk")
        $Shortcut.TargetPath = "C:\Program Files (x86)\Nexus Insurance Solutions\NexusAudit\NexusAudit.exe"
        $Shortcut.Save()

    }

    $ProgramPath = "C:\Program Files (x86)\Nexus Insurance Solutions\NexusAudit\NexusAudit.exe"
    $WMIC = Get-WmiObject Win32_Product -filter "name like 'NexusAudit'"
    $ProgramVersion_target = '5.5.6.0' 
    $ProgramVersion_current = (Get-Item $ProgramPath -ErrorAction SilentlyContinue).VersionInfo.FileVersion 

    if (Test-Path $ProgramPath){
    Write-Output "We found the application EXE"
    Write-Output "Application EXE is version $ProgramVersion_Current"}

    if($ProgramVersion_current -eq $ProgramVersion_target){
        Write-Output "Program version is supposed to be $ProgramVersion_target. It is!"
    }


    if ($null -ne $WMIC){
       if($ProgramVersion_current -eq $ProgramVersion_target){
            Write-Host "Application appears to be installed properly."
            }
       }



}catch{
    Write-Host "_____________________________________________________________________"
    Write-Host "ERROR while installing $PackageName"
    Write-Host "$_"
}

Stop-Transcript

