<#PSScriptInfo

.VERSION 0.0

.GUID 23cd18fc-467d-4a15-a0b6-0418c51a9b3c

.AUTHOR David Walker, Sitecore Dave, Radical Dave

.COMPANYNAME David Walker, Sitecore Dave, Radical Dave

.COPYRIGHT David Walker, Sitecore Dave, Radical Dave

.TAGS powershell file io script scriptfileinfo

.LICENSEURI https://github.com/Radical-Dave/Get-ScriptFileInfo/blob/main/LICENSE

.PROJECTURI https://github.com/Radical-Dave/Get-ScriptFileInfo

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


#>

<#
.SYNOPSIS
Gets a script file including metadata with helpers

.DESCRIPTION
Gets a script file including metadata with helpers

.EXAMPLE
PS> .\Get-ScriptFileInfo path

.Link
https://github.com/Radical-Dave/Get-ScriptFileInfo

.OUTPUTS
    System.String
#>
#####################################################
#  Get-ScriptFileInfoScript
#####################################################
function Get-ScriptFileInfoScript
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string] $Path
    )
    process
    {
        if (!$Path) { $Path = $PSScriptPath}
        if (!$Path) { $Path = $MyInvocation.MyCommand.Path}

        return Get-Content $Path
    }
}

#####################################################
#  Get-ScriptFileInfoProperty
#####################################################
function Get-ScriptFileInfoProperty
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string] $Path,
        [string] $Property
    )
    process
    {
        if (!$PSScriptScript) { $PSScriptScript = Get-ScriptFileInfoScript $Path }
        $startPos = $PSScriptScript.IndexOf(".$Property")
        if ($startPos -eq -1) { return '' }
        $endPos = $PSScriptScript.IndexOf(".", $startPos + 1)
        if ($endPos -ne -1) { return $PSScriptScript.Substring($startPos, $endPos - $startPos).Replace(".$Property", "") }
        return ''
    }
}

#####################################################
#  Get-ScriptFileInfo
#####################################################
function Get-ScriptFileInfo {
    Param(
        # Path of script
        #[ValidateScript({Test-Path $_})]
        [Parameter(Mandatory=$false, Position=0)] [string]$path,
        # Set - Set Global variables from ScriptFileInfo
        [Parameter(Mandatory=$false)] [switch]$Set = $false
    )
    $ErrorActionPreference = 'Stop'
    $PSScriptName = $MyInvocation.MyCommand.Name.Replace(".ps1","")
    Write-Verbose "$PSScriptName start -Set:$Set"
    Write-Verbose "PSScriptPath:$PSScriptPath"
    if (!$path) { if ($PSScriptPath) { $path = $PSScriptPath } }
    #if (!$path) { $path = $MyInvocation.MyCommand.Path}
    Write-Verbose "path:$path"
    $PSScriptScript = Get-Content $path
    Write-Verbose "PSScriptScript.Length:$($PSScriptScript.Length)"
    if ($Set) { Set-Variable -Name PSScriptScript -Value $PSScriptScript -Scope Global }

    if ($PSScriptScript) {
        $PSScriptAuthor = "$($PSScriptScript | Where-Object {$_ -like '.AUTHOR*'})"
        if ($PSScriptAuthor.IndexOf('.AUTHOR') -gt -1) {$PSScriptAuthor = $PSScriptAuthor.Remove(0, 8) }
        if ($Set) { Set-Variable -Name PSScriptAuthor -Value $PSScriptAuthor -Scope Global }
        Write-Verbose "PSScriptAuthor:$PSScriptAuthor"

        #$PSScriptDesc = Get-ScriptFileInfoProperty $path, 'DESCRIPTION'
        $PSScriptDesc = "$($PSScriptScript | Where-Object {$_ -like '.DESCRIPTION*'})"
        #$PSScriptDesc = $PSScriptScript | Select-String '.DESCRIPTION'
        if ($PSScriptDesc.IndexOf('.DESCRIPTION') -gt -1) {$PSScriptDesc = $PSScriptDesc.Remove(0, 12) }
        if ($Set) { Set-Variable -Name PSScriptDesc -Value $PSScriptDesc -Scope Global }
        Write-Verbose "PSScriptDesc:$PSScriptDesc"
    }

    Write-Verbose "$PSScriptName end"

    #Version = "2.0"
    #CompanyName = "Contoso"

    $ScriptFileInfo = @{
        Path = $path
        Script = $PSScriptScript
        Author = $PSScriptAuthor
        Description = $PSScriptDesc
    }

    return $ScriptFileInfo
}
Get-ScriptFileInfo