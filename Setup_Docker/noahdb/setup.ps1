[CmdletBinding()]
#Param(
#    [Parameter(Mandatory=$true)]
#    [string] $DownloadFolder
#)
$DownloadFolder="c:\Packages\"
New-Item -Type Directory "$DownloadFolder"

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
    <#
    $AppList = @()
    # Noah
    $AppList += ,@('noah-master.zip', "$DownloadFolder\Noah", 'https://github.com/giMini/NOAH/archive/master.zip')  
    
    Foreach ($App in $AppList) {
        $AppName = $App[0]
        $AppDownloadFolder = $App[1]
        $AppUri = $App[2]
        xCreate-Directory -DestinationPath $AppDownloadFolder
        xDownload-File -URI $AppUri -DestinationPath $AppDownloadFolder -FileName $AppName
    }
    #>


# Setup
    cd $DownloadFolder

    $uri1="https://raw.githubusercontent.com/giMini/NOAH/master/generateDatabase/NOAH_generation.sql"
    $file1="NOAH_generation.sql"
    Invoke-WebRequest -Uri $uri1 -OutFile $file1
    sqlcmd -S localhost\SQLEXPRESS -i .\$file1
    
    $uri2="https://raw.githubusercontent.com/giMini/NOAH/master/generateDatabase/Generate_WhiteList.sql"
    $file2="Generate_WhiteList.sql"
    Invoke-WebRequest -Uri $uri2 -OutFile $file2
    sqlcmd -S localhost\SQLEXPRESS -i .\$file2

    $uri3="https://raw.githubusercontent.com/giMini/NOAH/master/generateDatabase/Generate_VT.sql"
    $file3="Generate_VT.sql"
    Invoke-WebRequest -Uri $uri3 -OutFile $file3
    sqlcmd -S localhost\SQLEXPRESS -i .\$file3