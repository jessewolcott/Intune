

######################################################################################################################
# Program EXE with target Version
######################################################################################################################
$ProgramPath = "C:\Program Files (x86)\Nexus Insurance Solutions\NexusAudit\NexusAudit.exe"
$WMIC = Get-WmiObject Win32_Product -filter "name like 'NexusAudit'"
$ProgramVersion_target = '5.5.6.0' 
$ProgramVersion_current = (Get-Item $ProgramPath -ErrorAction SilentlyContinue).VersionInfo.FileVersion 



if ($null -ne $WMIC){
   if($ProgramVersion_current -eq $ProgramVersion_target){
        Write-Host "Found it!"
        }
   }

