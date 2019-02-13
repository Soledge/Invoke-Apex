<#
.SYNOPSIS
PowerShell Post-Exploitation Toolkit

.LINK 
https://www.github.com/securemode/Invoke-Apex

.EXAMPLE

PS> Import-Module .\Invoke-Apex.psd1
PS> Invoke-Apex

Author: Fabrizio Siciliano (@0rbz_)

#>

Get-ChildItem -Path $PWD\modules\*.ps1 | Foreach-Object{ . $_.FullName }