$ProgramPath = "C:\Program Files (x86)\Microsoft SQL Server Management Studio 19\Common7\IDE\Ssms.exe"

if (Test-Path -Path $ProgramPath) {
    $ProgramVersion_target = '16.200.20209.0' 
    $ProgramVersion_current = (Get-Item $ProgramPath).VersionInfo.ProductVersion
        if($ProgramVersion_current -ge [System.Version]$ProgramVersion_target){
            Write-Host "Found it!"
    }
}

