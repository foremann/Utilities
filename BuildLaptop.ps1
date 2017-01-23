<#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
#>

#Restart shell once you run above and comment it out, continue script below


mkdir c:\git
mkdir c:\git\personal
mkdir c:\git\collab
mkdir c:\scripts
mkdir c:\temp
mkdir c:\vagrant

#Install NuGet for DSC
Install-PackageProvider -Name NuGet -Force

#Install chocolatey packages
choco install firefox -y
#choco install mremoteng -y not working currently
choco install javaruntime -y
choco install github -y
choco install cutepdf -y 
choco install keepass -y
choco install notepadplusplus -y
choco install virtualbox -y
choco install wireshark -y
choco install putty -y
choco install 7zip -y
choco install visualstudiocode -y
choco install vagrant -y
choco install packer -y


#Install AD
Function Install-ADModule {
    [CmdletBinding()]
    Param(
        [switch]$Test = $false
    )

    If ((Get-CimInstance Win32_OperatingSystem).Caption -like "*Windows 10*") {
        Write-Verbose '---This system is running Windows 10'
    } Else {
        Write-Warning '---This system is not running Windows 10'
        break
    }

    If (Get-HotFix -Id KB2693643 -ErrorAction SilentlyContinue) {

        Write-Verbose '---RSAT for Windows 10 is already installed'

    } Else {

        Write-Verbose '---Downloading RSAT for Windows 10'

        If ((Get-CimInstance Win32_ComputerSystem).SystemType -like "x64*") {
            $dl = 'WindowsTH-KB2693643-x64.msu'
        } Else {
            $dl = 'WindowsTH-KB2693643-x86.msu'
        }
        Write-Verbose "---Hotfix file is $dl"

        Write-Verbose "---$(Get-Date)"
        #Download file sample
        #https://gallery.technet.microsoft.com/scriptcenter/files-from-websites-4a181ff3
        $BaseURL = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/'
        $URL = $BaseURL + $dl
        $Destination = Join-Path -Path $HOME -ChildPath "Downloads\$dl"
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($URL,$Destination)
        $WebClient.Dispose()

        Write-Verbose '---Installing RSAT for Windows 10'
        Write-Verbose "---$(Get-Date)"
        # http://stackoverflow.com/questions/21112244/apply-service-packs-msu-file-update-using-powershell-scripts-on-local-server
        wusa.exe $Destination /quiet /norestart /log:$home\Documents\RSAT.log

        # wusa.exe returns immediately. Loop until install complete.
        do {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 3
        } until (Get-HotFix -Id KB2693643 -ErrorAction SilentlyContinue)
        Write-Host "."
        Write-Verbose "---$(Get-Date)"
    }

    # The latest versions of the RSAT automatically enable all RSAT features
    If ((Get-WindowsOptionalFeature -Online -FeatureName `
        RSATClient-Roles-AD-Powershell -ErrorAction SilentlyContinue).State `
        -eq 'Enabled') {

        Write-Verbose '---RSAT AD PowerShell already enabled'

    } Else {

        Write-Verbose '---Enabling RSAT AD PowerShell'
        Enable-WindowsOptionalFeature -Online -FeatureName RSATClient-Roles-AD-Powershell

    }

    Write-Verbose '---Downloading help for AD PowerShell'
    Update-Help -Module ActiveDirectory -Verbose -Force

    Write-Verbose '---ActiveDirectory PowerShell module install complete.'

    # Verify
    If ($Test) {
        Write-Verbose '---Validating AD PowerShell install'
        dir (Join-Path -Path $HOME -ChildPath Downloads\*msu)
        Get-HotFix -Id KB2693643
        Get-Help Get-ADDomain
        Get-ADDomain
    }
}

Install-ADModule

#Disable Cortana 
New-Item "hklm:\software\policies\microsoft\windows\Windows Search" | Out-Null
New-ItemProperty -Path "hklm:\software\policies\microsoft\windows\Windows Search" -Name "AllowCortana" -Value 0 -PropertyType DWORD | Out-Null
if((Get-ItemPropertyValue -Path "HKLM:\software\policies\microsoft\windows\Windows Search\" -Name "AllowCortana") -eq 0){Write-Host "Cortana Disabled" -ForegroundColor Red -BackgroundColor Black}
else{Write-Host "Cortana was not disabled successfully" -ForegroundColor Red -BackgroundColor Black}





#Manually install office, skype, onedrive, powershell pspki module, sql 2016
#Once git is setup copy down repos
#Copy down ISO files for virtualbox
#Import bookmarks

<# Vagrant setup
Open admin shell
cd c:\vagrant
vagrant init 
vagrant box add jacqinthebox/windowsserver2016

#>