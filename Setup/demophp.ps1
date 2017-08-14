#64
configuration demophp 
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
        # xphp , requierements : VC14 Visual C++ 2015 Redist Package (x64)
        # MSVC++ 14.0 _MSC_VER == 1900 (Visual Studio 2015)
            [Parameter(Mandatory = $true)]
            [string] $Vc14DownloadUri,
        # xphp , VC14 x64 Non Thread Safe from http://windows.php.net/download/ 
            [Parameter(Mandatory = $true)]
            [string] $Php7DownloadUri,
        # xphp , sqlsrv ext for php7 VC14 x64 Non Thread Safe
            [Parameter(Mandatory = $true)]
            [string] $Php7ExtDownloadUri,
        # xphp , destination aka c:\php
            [Parameter(Mandatory = $true)]
            [String] $Php7DestinationPath,
        # xphp , php.ini URI
            [Parameter(Mandatory = $true)]
            [string] $Php7ConfigurationUri,
        # Sql server
            [Parameter(Mandatory = $true)]
            [string] $SqlServerExpress2017Uri,
        # WebappUri
            [Parameter(Mandatory = $true)]
            [string] $WebappUri
    ) 
    # Import the module that defines custom resources 
    $index ="
    <html>
    <head>
        <title>My </title>
    </head>
    <body>
        <BR><h1> Site : $WebSiteName Test64 </H1><BR2>
    </body>
    </html> "
    $phpinfo = "<?php phpinfo(); ?>"

    Import-DscResource -ModuleName "PSDesiredStateConfiguration"
    Import-DscResource -ModuleName "xPSDesiredStateConfiguration" -moduleVersion "6.4.0.0"
    Import-DscResource -ModuleName "xDnsServer" -moduleVersion "1.7.0.0"
    Import-DscResource -ModuleName "xNetworking" -moduleVersion "5.0.0.0"
    Import-DscResource -ModuleName "xWebAdministration" -moduleVersion "1.18.0.0"
    Import-DscResource -ModuleName "xphp" -moduleVersion "1.2.0.0"

    Node $NodeName 
    { 
        # Install the IIS role 
            WindowsFeature IIS 
            { 
                Ensure          = "Present" 
                Name            = "Web-Server" 
            } 
            foreach ($Feature in @("Web-Mgmt-Tools","web-Default-Doc", `
                    "Web-Dir-Browsing","Web-Http-Errors","Web-Static-Content",`
                    "Web-Http-Logging","web-Stat-Compression","web-Filtering",`
                    "web-CGI","web-ISAPI-Ext","web-ISAPI-Filter","Web-Asp-Net45","Web-Mgmt-Service","Web-Mgmt-Console"))
            {
                WindowsFeature "$Feature$Number"
                {
                    Ensure       = "Present"
                    Name         = $Feature
                    DependsOn    = "[WindowsFeature]IIS" 
                }
            }
        
        # Stop the default website 
            xWebsite StopDefaultSite  
            { 
                Ensure          = "Present" 
                Name            = "Default Web Site" 
                State           = "Stopped" 
                PhysicalPath    = "C:\inetpub\wwwroot" 
                DependsOn       = "[WindowsFeature]IIS" 
            }

        # Create WebSiteName Path and Default index.html
            File index
            {
                DestinationPath = "$WebsitePath\index.html"
                Contents = $index
            }
            File phpinfo
            {
                DestinationPath = "$WebsitePath\phpinfo.php"
                Contents = $phpinfo
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
                                Port                  = 80 
                                } 
                DependsOn       = "[File]index" 
            }
        # Install VC14
            $Vc14Zip = Join-Path $PackageFolder "vc14_redist_x64.zip"
            xRemoteFile Vc14Archive
            {
                uri = $Vc14DownloadUri
                DestinationPath = $Vc14Zip
            }
            Archive Vc14Unzip
            {
                Path = $Vc14Zip
                Destination  = $PackageFolder
                #DependsOn = [xRemoteFile]Vc14Archive
            }
            
            $Vc14Exe = Join-Path $PackageFolder "vc_redist_x64.exe"
            Package Vc14Exe
            {
                Ensure = "Present"
                Name = "Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24212"
                Path = $Vc14Exe
                ProductId = ''
                Arguments = '/install /passive /norestart' # args for silent mode
            }

        # Install PHP
            # Install php 7
            $Php7Zip = Join-Path $PackageFolder "php-7.0.22-nts-Win32-VC14-x64.zip"
            xRemoteFile Php7Archive
            {
                uri = $Php7DownloadUri
                DestinationPath = $Php7Zip
            }

            Archive Php7Unzip
            {
                Path = $Php7Zip
                Destination  = $Php7DestinationPath
                # DependsOn = [xRemoteFile]Php7Archive
            }

            # Install php 7 Ext mssql
            $Php7ExtZip = Join-Path $PackageFolder "php-7.0.22-nts-Win32-VC14-x64_sqlsrv.zip"
            xRemoteFile Php7ExtArchive
            {
                uri = $Php7ExtDownloadUri
                DestinationPath = $Php7ExtZip
            }

            Archive Php7ExtUnzip
            {
                Path = $Php7ExtZip
                Destination  = "$($Php7DestinationPath)\ext\"
                #DependsOn = [xRemoteFile]Php7ExtArchive
            }

            <# Configure PHP
            if ($installMySqlExt )
            {
                # Make sure the MySql extention for PHP is in the main PHP path
                File phpMySqlExt
                {
                    SourcePath = "$($PHPDestinationPath)\ext\php_mysql.dll"
                    DestinationPath = "$($PHPDestinationPath)\php_mysql.dll"
                    Ensure = "Present"
                    DependsOn = @("[Archive]PHP")
                    MatchSource = $true
                }
            }
            #>
            # Make sure the php.ini is in the Php folder
            $Php7Configuration = Join-Path $PackageFolder "php.ini"
            xRemoteFile Php7IniSrc
            {
                uri = $Php7ConfigurationUri
                DestinationPath = $Php7Configuration
            }

            File Php7Ini
            {
                Ensure = "Present" 
                Type = "File" 
                SourcePath = $Php7Configuration
                DestinationPath = "$($Php7DestinationPath)\php.ini"  
            }

            # Make sure the php cgi module is registered with IIS
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

            # Make sure the php binary folder is in the path
            Environment PathPhp
            {
                Name = "Path"
                Value = ";$($Php7DestinationPath)"
                Ensure = "Present"
                Path = $true
            }
            # Download SQL server 2017 express
            $SqlServerExpress2017 = Join-Path $PackageFolder "SQLServer2016-SSEI-Expr.exe"
            xRemoteFile SqlServerExpress2017Src
            {
                uri = $SqlServerExpress2017Uri
                DestinationPath = $SqlServerExpress2017
            }
            # Download Webapp
            $WebappZip  = Join-Path $PackageFolder "Webapp-Master.zip"
            xRemoteFile WebappSrc
            {
                uri = $WebappUri
                DestinationPath = $WebappZip
            }
            <#Archive WebappUnzip
            {
                Path = $WebappZip
                Destination  = $PackageFolder
            }#>
    } 
}

demophp -nodename localhost `
    -WebSiteName demophp `
    -WebsitePath C:\inetpub\wwwroot\webapp `
    -PackageFolder "C:\Packages" `
    -Vc14DownloadUri "https://github.com/arnaud-landry/noah/raw/master/src/vc14_redist_x64.zip" `
    -Php7DownloadUri "https://github.com/arnaud-landry/noah/raw/master/src/php-7.0.22-nts-Win32-VC14-x64.zip" `
    -Php7ExtDownloadUri "https://github.com/arnaud-landry/noah/raw/master/src/php-7.0.22-nts-Win32-VC14-x64_sqlsrv.zip" `
    -Php7DestinationPath "C:\php" `
    -Php7ConfigurationUri "https://raw.githubusercontent.com/arnaud-landry/noah/master/php/php.ini" `
    -SqlServerExpress2017Uri "https://ib.adnxs.com/seg?add=1&redir=https%3A%2F%2Fgo.microsoft.com%2Ffwlink%2F%3FLinkID%3D799012" `
    -WebappUri "https://github.com/banago/simple-php-website/archive/master.zip"
New-DscCheckSum -Path ".\" -Force