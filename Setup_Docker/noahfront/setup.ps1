<#
    # Version
        2
    # Todo
        * Add chocolatey support to DSC : https://github.com/chocolatey/cChoco/blob/development/ExampleConfig.ps1
        * Install package with DSC/Choco
        * remove useless feature from "# Install the IIS role "
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [string] $DownloadFolder ="c:\Packages\",
    [Parameter(Mandatory=$false)]
    [string] $Src="https://github.com/arnaud-landry/noah/raw/version2/src/",
    [Parameter(Mandatory=$false)]
    [string] $DbUser="SA"    
    [Parameter(Mandatory=$false)]
    [string] $DbPassword="password"="11586985851756998150"
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
        $ModulesList += ,@("xWebAdministration", "1.18.0.0")  
        $ModulesList += ,@("xPhp", "1.2.0.0")
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
    # Add Php files
        $AppList += ,@('php-7.0.22-nts-Win32-VC14-x64.zip', "$DownloadFolder\Php", "$Src/php-7.0.22-nts-Win32-VC14-x64.zip")  
        $AppList += ,@('php-7.0.22-nts-Win32-VC14-x64_sqlsrv.zip', "$DownloadFolder\Php", "$Src/php-7.0.22-nts-Win32-VC14-x64_sqlsrv.zip")  
        $AppList += ,@('php.ini', "$DownloadFolder\Php", "$Src/php.ini") 
    # Add default website files
        $AppList += ,@('index.html', "$DownloadFolder\website", "$Src/index.html") 
        $AppList += ,@('testsql.php', "$DownloadFolder\website", "$Src/testsql.php")  
        $AppList += ,@('phpinfo.php', "$DownloadFolder\website", "$Src/phpinfo.php")
    # Add Noah files 
        $AppList += ,@('noah-master.zip', "$DownloadFolder\Noah", "https://github.com/giMini/NOAH/archive/master.zip") 
        $AppList += ,@('connection.php', "$DownloadFolder\Noah", "$Src/connection.php") 
    # Download files
        Foreach ($App in $AppList) {
            $AppName = $App[0]
            $AppDownloadFolder = $App[1]
            $AppUri = $App[2]
            xCreate-Directory -DestinationPath $AppDownloadFolder
            xDownload-File -URI $AppUri -DestinationPath $AppDownloadFolder -FileName $AppName
        }

# Define IISPHP desired state configuration (DSC)
    configuration IISPHP 
    {
    # Param
        param 
            ( 
                # Target nodes to apply the configuration 
                [string]$NodeName = 'localhost', 
                
                # Name of the website to create 
                [Parameter(Mandatory = $false)] 
                [ValidateNotNullOrEmpty()] 
                [String]$WebSiteName = "noah",  
                
                # Destination path for Website content 
                [Parameter(Mandatory = $false)] 
                [ValidateNotNullOrEmpty()] 
                [String]$WebsitePath="C:\inetpub\wwwroot\noah",
                
                # Package Folder
                [Parameter(Mandatory = $true)]
                [string] $PackageFolder,
                
                # Php install folder : c:\php
                [Parameter(Mandatory = $false)]
                [String] $Php7DestinationPath = "C:\php"
            ) 
    # Import Resources
        Import-DscResource -ModuleName "PSDesiredStateConfiguration"
        Import-DscResource -ModuleName "xPSDesiredStateConfiguration" -moduleVersion "6.4.0.0"
        Import-DscResource -ModuleName "xWebAdministration" -moduleVersion "1.18.0.0"
        Import-DscResource -ModuleName "xPhp" -moduleVersion "1.2.0.0"
    # Configuration
        Node $NodeName 
        { 
            # Install the IIS role 
                WindowsFeature WebServer 
                { 
                    Ensure          = "Present" 
                    Name            = "Web-Server" 
                }
                foreach ($Feature in @("Web-Mgmt-Tools","web-Default-Doc", `
                        "Web-Dir-Browsing","Web-Http-Errors","Web-Static-Content",`
                        "Web-Http-Logging","web-Stat-Compression","web-Filtering",`
                        "web-CGI","web-ISAPI-Ext","web-ISAPI-Filter","Web-Asp-Net45","Web-Mgmt-Service"))
                {
                    WindowsFeature "$Feature$Number"
                    {
                        Ensure       = "Present"
                        Name         = $Feature
                        DependsOn    = "[WindowsFeature]WebServer" 
                    }
                }     
            # Stop the default website 
                xWebsite StopDefaultSite  
                { 
                    Ensure          = "Present" 
                    Name            = "Default Web Site" 
                    State           = "Stopped" 
                    PhysicalPath    = "C:\inetpub\wwwroot" 
                    DependsOn       = "[WindowsFeature]WebServer" 
                }
            # Create WebSiteName Path and Default files (index.html, phpinfo.php and testsql.php)
                File index
                {
                    Ensure = "Present"  
                    Type = "File" 
                    SourcePath = "$PackageFolder\website\index.html"
                    DestinationPath = "$WebsitePath\index.html"
                }
                File phpinfo
                {
                    Ensure = "Present"  
                    Type = "File" 
                    SourcePath = "$PackageFolder\website\phpinfo.php"
                    DestinationPath = "$WebsitePath\phpinfo.php"
                }
                File testsql
                {
                    Ensure = "Present"  
                    Type = "File" 
                    SourcePath = "$PackageFolder\website\TestSql.php"
                    DestinationPath = "$WebsitePath\TestSql.php"
                }
            # Create the new Website 
                xWebsite NewWebsite
                { 
                    Ensure          = "Present" 
                    Name            = $WebSiteName 
                    State           = "Started" 
                    PhysicalPath    = $WebsitePath 
                    BindingInfo     = MSFT_xWebBindingInformation 
                                    { 
                                    Protocol              = "HTTP" 
                                    Port                  = 8000 
                                    } 
                    DependsOn       = "[File]index" 
                }
            # Install PHP
                $Php7Zip = Join-Path $PackageFolder "\php\php-7.0.22-nts-Win32-VC14-x64.zip"
                Archive Php7Unzip
                {
                    Path = $Php7Zip
                    Destination  = $Php7DestinationPath
                    # DependsOn = [xRemoteFile]Php7Archive
                }
                $Php7ExtZip = Join-Path $PackageFolder "\php\php-7.0.22-nts-Win32-VC14-x64_sqlsrv.zip"
                Archive Php7ExtUnzip
                {
                    Path = $Php7ExtZip
                    Destination  = "$($Php7DestinationPath)\ext\"
                    #DependsOn = [xRemoteFile]Php7ExtArchive
                }
                $Php7Configuration = Join-Path $PackageFolder "\php\php.ini"
                File Php7Ini
                {
                    Ensure = "Present" 
                    Type = "File" 
                    SourcePath = $Php7Configuration
                    DestinationPath = "$($Php7DestinationPath)\php.ini"  
                }
            # Register php cgi module with IIS
                Script FastCGI-IIS
                {
                    SetScript = 
                    { 
                        #$PhpCgi = 'C:\php\php-cgi.exe'
                        $Php7Cgi = Join-Path $Php7DestinationPath "\php-cgi.exe"
                        New-WebHandler -Name "PHP-FastCGI" -Path "*.php" -Verb "*" -Modules "FastCgiModule" -ScriptProcessor $Php7Cgi -ResourceType File
                        $configPath = get-webconfiguration 'system.webServer/fastcgi/application' | where-object { $_.fullPath -eq $Php7Cgi }
                        if (!$pool) {
                            add-webconfiguration 'system.webserver/fastcgi' -value @{'fullPath' = $Php7Cgi }
                        }                
                    }
                    TestScript = { 
                    $result = Get-WebHandler -Name "*php*"
                        if([string]::IsNullOrEmpty($result))
                        {
                            return $false
                        }
                        else{
                            return $true
                        }
                    
                    }
                    GetScript = { @{ Result = (Get-WebHandler -Name "*php*") } }          
                }
            # Update env:path with php folder
                Environment PathPhp
                {
                    Name = "Path"
                    Value = ";$($Php7DestinationPath)"
                    Ensure = "Present"
                    Path = $true
                }
        } 
    }
# Build and Apply IISPHP desired state configuration (DSC)
    # Change directory to DownloadFolder
        Write-Output "Change directory to $DownloadFolder"
        cd $DownloadFolder
    # Build Configuration IISPHP
        Write-Output "Build Configuration"
        IISPHP -nodename "localhost" `
            -PackageFolder $DownloadFolder
            #-WebSiteName "noah" `
            #-WebsitePath "C:\inetpub\wwwroot\noah" `
            #-Php7DestinationPath "C:\php"
    # Apply Configuration IISPHP
        Write-Output "Apply Configuration"
        Start-DscConfiguration -Path .\IISPHP -Wait -Force #-verbose
    # Test Configuration IISPHP
        Test-DscConfiguration
# Deploy Noah
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
    # Modify connection.php
        Write-Output "modify connection.php"
        $NoahConn = "C:\inetpub\wwwroot\noah\connection.php"
        (Get-Content $NoahConn).replace("P@ssword3!", $DbPassword) | Set-Content $NoahConn
        (Get-Content $NoahConn).replace("Administrator", $DbUser) | Set-Content $NoahConn
        (Get-Content $NoahConn).replace("SQL01", "noahdb") | Set-Content $NoahConn