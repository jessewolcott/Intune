$ProgramPath = "C:\Program Files\VideoLAN\VLC\vlc.exe"

$ProgramVersion_target = '3.0.18' 
$ProgramVersion_current = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($ProgramPath).FileVersion

if($ProgramVersion_current -eq $ProgramVersion_target){
    Write-Host "Found it!"
}