$PackageName = "VLC 3.0.18 x64" # replace with your package name

$Path_local = "$Env:Programfiles\_MEM" # "$ENV:LOCALAPPDATA\_MEM" for user context installations
Start-Transcript -Path "$Path_local\$PackageName-install.txt" -Force
$ErrorActionPreference = 'Stop'

try{
    Start-Process '.\Source\vlc-3.0.18-win64.exe' -ArgumentList '/S' -Wait -Verbose

}catch{
    Write-Host "_____________________________________________________________________"
    Write-Host "ERROR while installing $PackageName"
    Write-Host "$_"
}

Stop-Transcript

