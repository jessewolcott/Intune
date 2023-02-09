$PackageName = "MicrosoftCompanyPortal"
$Path_local = "$Env:Programfiles\_MEM" # "$ENV:LOCALAPPDATA\_MEM" for user context installations
Start-Transcript -Path "$Path_local\$PackageName-install.txt" -Force
$ErrorActionPreference = 'Stop'

try{

    Write-Output "Looking for NuGet Package Provider"
    $NuGetCurrentVersion   = ((Get-PackageProvider -Name Nuget).Version)
    $NuGetInstalledVersion = ((Get-Item "C:\Program Files\PackageManagement\ProviderAssemblies\nuget\2.8.5.208").Name)
    
    if ($NuGetInstalledVersion -ge $NuGetCurrentVersion)
        {Write-Output "Found NuGet install version greater than (or equal to) currently available version - ($NuGetCurrentVersion)"}
        else {
            Write-Output "Found NuGet install version less than currently available version - ($NuGetCurrentVersion)"
            Write-Output "Installing NuGet Package Provider"
            Install-PackageProvider -Name Nuget -force -ErrorAction SilentlyContinue -WhatIf         
        }
    

    Write-Output "Looking for WinGetTools Module"
    $WinGetToolsCurrentVersion   = (Get-InstalledModule -name Wingettools).Version
    $WinGetToolsInstalledVersion = (Get-Module -name Wingettools).Version
    
    if ($WinGetToolsInstalledVersion -ge $WinGetToolsCurrentVersion)
        {Write-Output "Found WinGetTools install version greater than (or equal to) currently available version - ($WinGetToolsCurrentVersion)"}
        else {
            Write-Output "Found WinGetTools install version less than currently available version - ($WinGetToolsCurrentVersion)"
            Write-Output "Installing WinGetTools Module"
            Install-Module -Name WingetTools -force -ErrorAction SilentlyContinue -WhatIf         
        }
        
    Write-Output "Looking for Winget"
    $WingetInstalledVersion = winget -v
    
    if ($null -eq $WingetInstalledVersion) {
        Write-Output "Winget not found"
        Install-Winget -Passthru        
        }   
        else {
            Write-Output "Found WinGet version - ($WingetInstalledVersion)"
        }
        
<# 
https://github.com/nuitsjp/posh-winget

function Invoke-WingetList {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Query,
        [Parameter()]
        [string]
        $Id,
        [Parameter()]
        [string]
        $Name,
        [Parameter()]
        [string]
        $Moniker,
        [Parameter()]
        [string]
        $Source,
        [Parameter()]
        [string]
        $Tag,
        [Parameter()]
        [string]
        $Command,
        [Parameter()]
        [int]
        $Count,
        [Parameter()]
        [switch]
        $Exact
    )
    $arguments = @()
    $arguments += $Query
    if ($Id) {
        $arguments += "--id"
        $arguments += $Id
    }
    if ($Name) {
        $arguments += "--name"
        $arguments += $Name
    }
    if ($Moniker) {
        $arguments += "--moniker"
        $arguments += $Moniker
    }
    if ($Source) {
        $arguments += "--source"
        $arguments += $Source
    }
    if ($Tag) {
        $arguments += "--tag"
        $arguments += $Tag
    }
    if ($Command) {
        $arguments += "--command"
        $arguments += $Command
    }
    if ($Count) {
        $arguments += "--count"
        $arguments += $Count.ToString()
    }
    if ($Exact) {
        $arguments += "--exact"
    }


    $result = (Invoke-Winget list $arguments)
    if ($result.IsSuccess) {
        Read-Package ($result.StandardOutput.Trim() -split "`r`n")
    }
    else {
        @()
    }
}
function Invoke-WingetImport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path
    )


    $config = Get-Content -Path $Path | ConvertFrom-Yaml
    $config | ForEach-Object {
        $package = $_
        $list = Invoke-WingetList -Id $package.id -Exact
        if($list.Length -eq 0) {
            $arguments = @()
            $arguments += 'install'
            if($package.silent) {
                $arguments += '--silent'
            }
            $arguments += '--id'
            $arguments += $package.id
            $arguments += '--accept-package-agreements'
            $arguments += '--accept-source-agreements'


            if($null -ne $package.packageParameters) {
                $arguments += '--override'
                $arguments += "`"$($package.packageParameters)`""
            }


            $argumentList = [string]::Join(' ', $arguments)
            Start-Process winget -NoNewWindow -Wait -ArgumentList $argumentList
        } else {
            Write-Host "$($package.id) is installed."
        }
    }
}
function Read-Package {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $Packages
    )
    if($Packages.Length -eq 1) {
        @()
    }


    $header = $Packages[0]
    $header = $header.Substring($header.LastIndexOf("`r") + 1).Trim()
    $columns = $header.Split(" ") | Where-Object { $_.Length -ne 0}
    $indexs = @()
    $columns | ForEach-Object {
        $column = $_
        $indexs += Get-Width $header.Substring(0, $header.IndexOf($column))
    }


    [array]::Reverse( $indexs )


    $result = @()
    $Packages | Select-Object -Skip 2 | ForEach-Object {
        $line = $_
        $columns = @()
        $indexs | ForEach-Object {
            $index = Get-Index $line $_
            if( $index -ge 0) {
                $column = $line.Substring($index).Trim()
                if ($column.EndsWith("…")) {
                    $column = $column.Substring(0, $column.Length - 1)
                }
                if ($column.Length -eq 0) {
                    $column = $null
                }
                $columns += $column
                $line = $line.Substring(0, $index)
            }
            else {
                $columns += $null
            }
        }
        # I want to determine the properties from the column names. 
        # However, since column names differ depending on the language, the number of columns should be used.
        if ($columns.Length -eq 5) {
            $result += [PSCustomObject]@{
                NamePrefix = $columns[4]
                IdPrefix = $columns[3]
                Version = $columns[2]
                Available = $columns[1]
                Source = $columns[0]
            }
        }
        elseif ($columns.Length -eq 4) {
            $result += [PSCustomObject]@{
                NamePrefix = $columns[3]
                IdPrefix = $columns[2]
                Version = $columns[1]
                Available = $null
                Source = $columns[0]
            }
        }
        else {
            $result += [PSCustomObject]@{
                NamePrefix = $columns[2]
                IdPrefix = $columns[1]
                Version = $columns[0]
                Available = $null
                Source = $null
            }
        }
    }
    $result
}
function Get-Width {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $str
    )
    $encoding = [system.Text.Encoding]::UTF8
    $charArray = $str.ToCharArray()
    $width = 0
    for ($i = 0; $i -lt $charArray.Count; $i++) {
        $char = $charArray[$i]
        if($char -eq "…") {
            $width += 1;
        }
        elseif ($encoding.GetBytes($char).Length -eq 1) {
            $width += 1;
        }
        else {
            $width += 2;
        }
    }
    $width
}
function Get-Index {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Word,
        [Parameter()]
        [int]
        $halfCharIndex
    )
    $encoding = [system.Text.Encoding]::UTF8


    if ($halfCharIndex -eq 0) {
        0
        return
    }


    $wordChars = $Word.ToCharArray()
    $currentIndex = 0
    for ($i = 0; $i -lt $wordChars.Count; $i++) {
        $current = $Word[$i]
        if($current -eq "…") {
            $currentIndex += 1;
        }
        elseif ($encoding.GetBytes($current).Length -eq 1) {
            $currentIndex += 1;
        }
        else {
            $currentIndex += 2;
        }
        if($currentIndex -eq $halfCharIndex) {
            ($i + 1)
            break
        }
    }
}
function Invoke-Winget {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Command,
        [Parameter()]
        [array]
        $Arguments
    )
    $convertedArguments = ($Arguments | Where-Object { $_.Length -ne 0 } | ForEach-Object { 
        $value = $_
        if ($value.StartsWith('--')) {
            $value
        }
        else {
            "`"${value}`"" 
        }
    })


    if ($null -eq $convertedArguments) {
        $argument = ''
    }
    else {
        $argument = [string]::Join(' ', $convertedArguments)
    }


    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = $env:LOCALAPPDATA + "\Microsoft\WindowsApps\winget.exe"
    $psi.Arguments = "$Command $argument"
    $psi.UseShellExecute = $false
    $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
    $psi.RedirectStandardOutput = $true
    Using-Object ($p = [Diagnostics.Process]::Start($psi)) {
        $s = $p.StandardOutput.ReadToEnd()
        $p.WaitForExit()
        if ($p.ExitCode -eq 0) {
            [PSCustomObject]@{
                IsSuccess = $true
                StandardOutput = $s
            }
        }
        else {
            [PSCustomObject]@{
                IsSuccess = $false
                StandardOutput = $s
            }
        }
    }
}
function Using-Object {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $InputObject,


        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )


    try
    {
        . $ScriptBlock
    }
    finally
    {
        if ($null -ne $InputObject -and $InputObject -is [System.IDisposable])
        {
            $InputObject.Dispose()
        }
    }
}

#Winget-List -ID "Microsoft.CompanyPortal"

#(Invoke-WingetList -Name "Company Portal").Version

(Invoke-Winget -Command show -Arguments "Company Portal").Standardoutput
#>
    #Write-Output "Installing $PackageName from Winget"
    #winget install "Company Portal"  --accept-package-agreements

    #(Get-WmiObject -class Win32_InstalledStoreProgram | Where-Object name -like "*Company*")


    #winget uninstall "Company Portal" 

}catch{
    Write-Host "_____________________________________________________________________"
    Write-Host "ERROR while installing $PackageName"
    Write-Host "$_"
}

Stop-Transcript
