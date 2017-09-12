<#
    # Version
        2
    # Todo
        * Add chocolatey support to DSC : https://github.com/chocolatey/cChoco/blob/development/ExampleConfig.ps1
        * Install package with DSC/Choco cChoco : https://github.com/chocolatey/cChoco/blob/development/ExampleConfig.ps1
        * remove useless feature from "# Install the IIS role "
        * add start file to set password and user for connection.php
    # BUG
        * n/a
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [string] $DownloadFolder ="c:\Packages\",
    [Parameter(Mandatory=$false)]
    [string] $Src="https://github.com/arnaud-landry/noah/raw/version2/src/",
    [Parameter(Mandatory=$false)]
    [string] $NoahBackendFolder="C:\Noah\"
)

# Functions
    # xDownload-File
        Function xDownload-File
        {
            # xDownload-File -URI "http://test-debit.free.fr/4096.rnd" -DestinationPath "C:\TMP" -FileName "4096.rnd"
            [cmdletbinding()]
            param(
                [Parameter(Mandatory=$True)]
                [string] $URI,
                [Parameter(Mandatory=$True)]
                [string] $DestinationPath,
                [Parameter(Mandatory=$True)]
                [string] $FileName
            )
            try	
            {
                $output = $DestinationPath+"\"+$FileName
                (New-Object System.Net.WebClient).DownloadFile($URI,$output)
            }	
            catch
            {
                Write-Output "Invalid URI/Output"
            }
        }
    # xCreate-Directory
        Function xCreate-Directory
        {
            # xCreate-Directory -DestinationPath "C:\TMP"
            [cmdletbinding()]
            param(
                [Parameter(Mandatory=$True)]
                [string] $DestinationPath
            )
            try	
            {
                if (-not (test-path $DestinationPath) ) {
                    New-Item -type Directory $DestinationPath |out-null
                    Write-Output "$DestinationPath created"
                } else {
                    Write-Output "$DestinationPath already exist"
                }
            }	
            catch
            {
                Write-Output "Invalid DestinationPath"
            }
        }
    # xInstall-PackageProvider
        Function xInstall-PackageProvider
        {
            # xInstall-PackageProvider -ProviderName "xxx"
            [cmdletbinding()]
            param(
                [Parameter(Mandatory=$True)]
                [string] $ProviderName
            )
            try	
            {
                if (-not (Get-PackageProvider -Name $ProviderName ) ) {
                    #Install-PackageProvider $ProviderName -ForceBootstrap -Force
                    Write-Output "$ProviderName install ..."
                } else {
                    Write-Output "$ProviderName already installed"
                }
            }	
            catch
            {
                Write-Output "Invalid DestinationPath"
            }
        }
    # xInstall-Module
        Function xInstall-Module
        {
            [cmdletbinding()]
            param(
                [Parameter(Mandatory=$True)]
                [string] $ModuleName,
                [Parameter(Mandatory=$True)]
                [string] $ModuleVersion
            )
            try	
            {
                Install-Module $ModuleName -RequiredVersion $ModuleVersion -Force -SkipPublisherCheck
            }	
            catch
            {
                Write-Output "Invalid $ModuleName"
            }
        }
    # xNew-RandomComplexPassword 
        Function xNew-RandomComplexPassword ($length=24)
        {
            $Assembly = Add-Type -AssemblyName System.Web
            $password = [System.Web.Security.Membership]::GeneratePassword($length,2)
            return $password
        }

# Install Modules
    # Define modules
        $ModulesList = @()  
        $ModulesList += ,@("xPSDesiredStateConfiguration", "6.4.0.0")  
    # Install modules
        #xInstall-PackageProvider "Nuget"
        #xInstall-PackageProvider "PowershellGet"
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
        Write-Output "PSGallery Trusted"
        foreach ($Module in $ModulesList) {
            $ModuleName = $Module[0]
            $ModuleVersion = $Module[1]
            xInstall-Module -ModuleName $ModuleName -ModuleVersion $ModuleVersion
            Write-Output "$ModuleName installed"
            #$error[0]|select *
        }

# Download Src
    # Define App List
        $AppList = @()
    # Add Noah files 
        $AppList += ,@('noah-master.zip', "$DownloadFolder\Noah", "https://github.com/giMini/NOAH/archive/master.zip") 
    # Download files
        Foreach ($App in $AppList) {
            $AppName = $App[0]
            $AppDownloadFolder = $App[1]
            $AppUri = $App[2]
            xCreate-Directory -DestinationPath $AppDownloadFolder
            xDownload-File -URI $AppUri -DestinationPath $AppDownloadFolder -FileName $AppName
        }

# Define noahback desired state configuration (DSC)
    configuration noahback 
    {
    # Param
        param 
            ( 
                # Target nodes to apply the configuration 
                [string]$NodeName = 'localhost', 
                # Package Folder
                [Parameter(Mandatory = $true)]
                [string] $PackageFolder,
                # NoahBakend Folder
                [Parameter(Mandatory = $true)]
                [string] $NoahBackendFolder
            ) 
    # Import Resources
        Import-DscResource -ModuleName "PSDesiredStateConfiguration"
        Import-DscResource -ModuleName "xPSDesiredStateConfiguration" -moduleVersion "6.4.0.0"
    # Configuration
        Node $NodeName 
        {
            # Install backend
                $NoahZip = Join-Path $PackageFolder "\noah\noah-master.zip"
                Archive NoahZip
                {
                    Path = $NoahZip
                    Destination  = $NoahBackendFolder
                }
            # NOAH
                # Download
                # Unzip
                # Flush generateDatabase folder
                # Flush setup folder
                # Flush Backend folder
                # Copy source to inetpub
                # Connection.php
            # 
        } 
    }
# Build and Apply noahback desired state configuration (DSC)
    # Change directory to DownloadFolder
        Write-Output "Change directory to $DownloadFolder"
        cd $DownloadFolder
    # Build Configuration IISPHP
        Write-Output "Build Configuration"
        noahback -nodename "localhost" `
            -PackageFolder $DownloadFolder `
            -NoahBackendFolder $NoahBackendFolder
    # Apply Configuration noahback
        Write-Output "Apply Configuration"
        Start-DscConfiguration -Path .\noahback -Wait -Force -verbose
    # Test Configuration IISPHP
        Test-DscConfiguration

# Create secureKeyDatabase.key and autoPasswordDatabase.txt
Write-Output "Create Keys"

New-Item -Type Directory "C:\temp\PoshPortal\Keys\"
$SqlNoahNewPassword = "5c4_fdc6a50+1864b89d8a6576bd9dbb-90"

$KeyFile = "C:\temp\PoshPortal\Keys\secureKeyDatabase.key"
$Key = New-Object Byte[] 32   # AES encryption only supports 128-bit (16 bytes), 192-bit (24 bytes) or 256-bit key (32 bytes) 
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile

$PasswordFile = "C:\temp\PoshPortal\Keys\autoPasswordDatabase.txt"
$KeyFile = "C:\temp\PoshPortal\Keys\secureKeyDatabase.key"
$Key = Get-Content $KeyFile
$Password = $SqlNoahNewPassword | ConvertTo-SecureString -AsPlainText -Force
$Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile

$NoahBackend = "C:\Noah\NOAH-master\Backend\NOAH.ps1"
(Get-Content $NoahBackend).replace("NOAHAdmin", "sa") | Set-Content $NoahBackend
(Get-Content $NoahBackend).replace("SQL01", "noahdb") | Set-Content $NoahBackend


# Deploy Noah
    <#
        # Unzip archive
            Write-Output "Unzip Noah Archive"
            cd C:\Packages\Noah\
            expand-archive -path 'C:\Packages\Noah\noah-master.zip' -destinationpath 'C:\Packages\Noah\'
        # Flush generateDatabase folder
            Write-Output "Flush generateDatabase folder"    
            Remove-Item "C:\Packages\Noah\NOAH-master\generateDatabase\" -Force -Recurse
        # Flush setup folder
            Write-Output "Flush setup folder"    
            Remove-Item "C:\Packages\Noah\NOAH-master\setup\" -Force -Recurse
        # Flush Backend folder
            Write-Output "Flush backend folder"    
            Remove-Item "C:\Packages\Noah\NOAH-master\Backend\" -Force -Recurse
        # Copy source to inetpub
            Write-Output "move code to intepub"
            Move-Item C:\Packages\Noah\NOAH-master\* -Destination C:\inetpub\wwwroot\noah\ -Force
    #>