[CmdletBinding()]
#Param(
#    [Parameter(Mandatory=$true)]
#    [string] $DownloadFolder
#)
$DownloadFolder="c:\Packages\"

# Functions
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
    Function xNew-RandomComplexPassword ($length=24)
    {
        $Assembly = Add-Type -AssemblyName System.Web
        $password = [System.Web.Security.Membership]::GeneratePassword($length,2)
        return $password
    }

# Install Modules
    <#
    $ModulesList = @()  
        #$ModulesList += ,@("Pester", "4.0.6")  
        #$ModulesList += ,@("PSScriptAnalyzer", "1.16.0")  
        $ModulesList += ,@("xPSDesiredStateConfiguration", "6.4.0.0")  
        $ModulesList += ,@("xWebAdministration", "1.18.0.0")  
        #$ModulesList += ,@("xPhp", "1.2.0.0")  
        #$ModulesList += ,@("xSQLServer", "8.0.0.0")  
        #$ModulesList += ,@("InvokeBuild", "3.6.4") 

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
    #>
# Download Src
    $AppList = @()
    # Php
    $AppList += ,@('vc14_redist_x64.zip', "$DownloadFolder\Php", 'https://github.com/arnaud-landry/noah/raw/master/src/vc14_redist_x64.zip')  
    $AppList += ,@('php-7.0.22-nts-Win32-VC14-x64.zip', "$DownloadFolder\Php", 'https://github.com/arnaud-landry/noah/raw/master/src/php-7.0.22-nts-Win32-VC14-x64.zip')  
    $AppList += ,@('php-7.0.22-nts-Win32-VC14-x64_sqlsrv.zip', "$DownloadFolder\Php", 'https://github.com/arnaud-landry/noah/raw/master/src/php-7.0.22-nts-Win32-VC14-x64_sqlsrv.zip')  
    $AppList += ,@('php.ini', "$DownloadFolder\Php", 'https://raw.githubusercontent.com/arnaud-landry/noah/master/php/php.ini') 
    $AppList += ,@('phpinfo.php', "$DownloadFolder\Php", 'https://raw.githubusercontent.com/arnaud-landry/noah/master/php/phpinfo.php') 
    # Noah
    $AppList += ,@('noah-master.zip', "$DownloadFolder\Noah", 'https://github.com/giMini/NOAH/archive/master.zip')  
    #WebServer default files
    $AppList += ,@('index.html', "$DownloadFolder\iis", 'https://raw.githubusercontent.com/arnaud-landry/noah/master/Setup_Docker/noahfront/index.html') 
    $AppList += ,@('TestSql.php', "$DownloadFolder\Sql", 'https://raw.githubusercontent.com/arnaud-landry/noah/master/Setup_Docker/noahfront/TestSql.php')  
    
    Foreach ($App in $AppList) {
        $AppName = $App[0]
        $AppDownloadFolder = $App[1]
        $AppUri = $App[2]
        xCreate-Directory -DestinationPath $AppDownloadFolder
        xDownload-File -URI $AppUri -DestinationPath $AppDownloadFolder -FileName $AppName
    }

# Configuration
    configuration IISPHP 
    { 
    param 
        ( 
            # Target nodes to apply the configuration 
            [string]$NodeName = 'localhost', 
            # Name of the website to create 
            [Parameter(Mandatory)] 
            [ValidateNotNullOrEmpty()] 
            [String]$WebSiteName,  
            # Destination path for Website content 
            [Parameter(Mandatory)] 
            [ValidateNotNullOrEmpty()] 
            [String]$WebsitePath,
            # Package Folder
            [Parameter(Mandatory = $true)]
            [string] $PackageFolder,
            # xphp , destination aka c:\php
            [Parameter(Mandatory = $true)]
            [String] $Php7DestinationPath
        ) 
    # Import Resources
        Import-DscResource -ModuleName "PSDesiredStateConfiguration"
        Import-DscResource -ModuleName "xPSDesiredStateConfiguration" -moduleVersion "6.4.0.0"
        Import-DscResource -ModuleName "xWebAdministration" -moduleVersion "1.18.0.0"
        #Import-DscResource -ModuleName "xphp" -moduleVersion "1.2.0.0"
        #Import-DscResource -ModuleName "xSQLServer" -moduleVersion "8.0.0.0"
        
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
                    SourcePath = "C:\Packages\iis\index.html"
                    DestinationPath = "$WebsitePath\index.html"
                }
                File phpinfo
                {
                    Ensure = "Present"  
                    Type = "File" 
                    SourcePath = "C:\Packages\Php\phpinfo.php"
                    DestinationPath = "$WebsitePath\phpinfo.php"
                }
                File testsql
                {
                    Ensure = "Present"  
                    Type = "File" 
                    SourcePath = "C:\Packages\Sql\TestSql.php"
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
                        $PhpCgi = 'C:\php\php-cgi.exe'
                        New-WebHandler -Name "PHP-FastCGI" -Path "*.php" -Verb "*" -Modules "FastCgiModule" -ScriptProcessor $PhpCgi -ResourceType File
                        $configPath = get-webconfiguration 'system.webServer/fastcgi/application' | where-object { $_.fullPath -eq $PhpCgi }
                        if (!$pool) {
                            add-webconfiguration 'system.webserver/fastcgi' -value @{'fullPath' = $PhpCgi }
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

# Setup
    cd $DownloadFolder
    Write-Output "Build Configuration"
    IISPHP -nodename "localhost" `
        -WebSiteName "noah" `
        -WebsitePath "C:\inetpub\wwwroot\noah" `
        -PackageFolder "C:\Packages" `
        -Php7DestinationPath "C:\php"
    Write-Output "Create Checksum"
    New-DscCheckSum -Path ".\IISPHP\" -Force
    Write-Output "Apply Configuration"
    #Start-DscConfiguration -Path .\IISPHP -Verbose -Wait -Force
    Start-DscConfiguration -Path .\IISPHP -Wait -Force
    Test-DscConfiguration

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
    (Get-Content $NoahConn).replace("P@ssword3!", "5c4_fdc6a50+1864b89d8a6576bd9dbb-90") | Set-Content $NoahConn
    (Get-Content $NoahConn).replace("Administrator", "SA") | Set-Content $NoahConn
    (Get-Content $NoahConn).replace("SQL01", "noahdb") | Set-Content $NoahConn