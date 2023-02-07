$PackageName = "VLC 3.0.18 x64"

$Path_local = "$Env:Programfiles\_MEM" # "$ENV:LOCALAPPDATA\_MEM" for user context installations
Start-Transcript -Path "$Path_local\uninstall\$PackageName-install.txt" -Force

try{
    Start-Process '"C:\Program Files\VideoLAN\VLC\uninstall.exe"' -ArgumentList '/S' -Wait 
}catch{
    Write-Host "_____________________________________________________________________"
    Write-Host "ERROR while uninstalling $PackageName"
    Write-Host "$_"
}

Stop-Transcript

