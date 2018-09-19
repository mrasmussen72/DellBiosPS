$filePath = "C:\Users\Administrator\Desktop\DellCCTK4\cctk.exe"
$setPassword = "--setuppwd=Dell530"
$bootOrder = "bootorder --activebootlist=uefi --valsetuppwd=Dell530"
$block3 = "--blocks3=enable --valsetuppwd=Dell530"
$disableLegacy = "--legacyorom=disable --valsetuppwd=Dell530"
$enableSecureBoot = "--secureboot=enable --valsetuppwd=Dell530"
$DisableRaid = "--embsataraid=ahci --valsetuppwd=Dell530"

$tpmOn = "--tpm=on --valsetuppwd=Dell530"
$clearPassword = "--setuppwd= --valsetuppwd=Dell530"

# SCCM task sequence only
$tsEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$logpath = $tsEnv.Value("_SMSTSLogPath")
$logfile = "$logpath\CCTKlogs.log"

#$logfile = "c:\temp\CCTK.log"


$StringBuilder = New-Object System.Text.StringBuilder
Function Write-Logging($Message)
{
    $DateTime = Get-Date -Format yyyyMMddTHHmmss
    $null= $StringBuilder.Append($DateTime.ToString())
    $null= $StringBuilder.Append("`t==>`t")
    $null= $StringBuilder.Append($Message)
    $null= $StringBuilder.ToString() | Out-File -FilePath $logfile -Append
    $null= $StringBuilder.Clear() 

}

try
{
    Write-Logging -Message "Starting CCTK script################"
   Write-Logging -Message "Setting BIOS Password"

   $BiosPwdRc = (Start-Process -FilePath $filePath -ArgumentList $setPassword -Wait -PassThru).ExitCode 
    if( $BiosPwdRc -ne 0)
    {
        #problem
        Write-Logging "Error setting BIOS password, return code $($BiosPwdRc)"
        throw "Error setting setPassword, arguments = $($setPassword)"
    }

    Write-Logging "Setting active boot list to UEFI"
    $bootOrderRc = (Start-Process -FilePath $filePath -ArgumentList $bootOrder -Wait -PassThru).ExitCode

    if($bootOrderRc -ne 0)
    {
        Write-Logging "Error setting BIOS password, return code $($bootOrderRc)"
        throw "Error setting bootorder, arguments = $($bootOrder)"
    }
    Write-Logging "Disabling sleep state"
    $sleepStateRc = (Start-Process -FilePath $filePath -ArgumentList $block3 -Wait -PassThru).ExitCode 
    if($sleepStateRc -ne 0)
    {
        #problem
        Write-Logging "Error setting sleep state, return code $($sleepStateRc)"
        throw "Error setting block3, arguments = $($block3)"
    }

    Write-Logging -Message "Disabling legacy boot"
    $disableLegacyRc = (Start-Process -FilePath $filePath -ArgumentList $disableLegacy -Wait -PassThru).ExitCode
    if($disableLegacyRc -ne 0)
    {
        #problem
        Write-Logging "Error disabling legacy boot, return code $($disableLegacyRc)"
        throw "Error setting disableLegacy, arguments = $($disableLegacy)"
    }
    Write-Logging -Message "Enabling secure boot"
    $enableSecureBootRc = (Start-Process -FilePath $filePath -ArgumentList $enableSecureBoot -Wait -PassThru).ExitCode
    if($enableSecureBootRc -ne 0)
    {
        #problem
        Write-Logging "Error enabling secure boot, return code $($enableSecureBootRc)"
        throw "Error setting enableSecureBoot, arguments = $($enableSecureBoot)"
    }

    Write-Logging "Enabling AHCI"
    $enableAHCIRc = (Start-Process -FilePath $filePath -ArgumentList $DisableRaid -Wait -PassThru).ExitCode 
    if($enableAHCIRc -ne 0)
    {
        #problem
        Write-Logging "Error enabling AHCI, return code $($enableAHCIRc)"
        throw "Error setting DisableRaid, arguments = $($DisableRaid)"
    }
    
    Write-Logging "Enabling TPM"
    $enableTPMRc = (Start-Process -FilePath $filePath -ArgumentList $tpmOn -Wait -PassThru).ExitCode
    if($enableTPMRc -ne 0)
    {
        #problem
        Write-Logging -Message "Error enabling TMP, return code $($enableTPMRc)"
        throw "Error setting tpmOn, arguments = $($tpmOn)"
    }

    Write-Logging "Clearning password"
    $clearPasswordRc = (Start-Process -FilePath $filePath -ArgumentList $clearPassword -Wait -PassThru).ExitCode
    if($clearPasswordRc -ne 0)
    {
        #problem
        Write-Logging "Error clearing password, return code $($clearPasswordRc)"
        throw "Error setting clearPassword, arguments = $($clearPassword)"
    }

}
Catch
{
    Write-Logging "Error, exiting script#####################################################"
}

Write-Logging -Message "Exiting CCTK script################"
