# http://powershelldistrict.com/powershell-workflows/

workflow Noah {
    Param(
        $DownloadFolder = "C:\Packages\" #replace in InlineScipt if modified !
       )
    Remove-Item $DownloadFolder -Force -Recurse
    New-Item -Type Directory $DownloadFolder 
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/arnaud-landry/noah/master/Setup_Workflow/xFunctions.ps1" -OutFile "$DownloadFolder\xFunctions.ps1"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/arnaud-landry/noah/master/Setup_Workflow/Download-Src.ps1" -OutFile "$DownloadFolder\Download-Src.ps1"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/arnaud-landry/noah/master/Setup_Workflow/Install-Modules.ps1" -OutFile "$DownloadFolder\Install-Modules.ps1"
    InlineScript { C:\Packages\Download-Src.ps1 -xFunctionsPath $using:DownloadFolder\xFunctions.ps1 -DownloadFolder $using:DownloadFolder }
    InlineScript { C:\Packages\Install-Modules.ps1 -xFunctionsPath $using:DownloadFolder\xFunctions.ps1 }
}
Noah

<#
    OUTPUT
    PS C:\Dev> .\Worflow1.ps1

        Directory: C:\
    
        Mode                LastWriteTime         Length Name                                PSComputerName
    ----                -------------         ------ ----                                --------------
    d-----       2017-08-23  11:49 PM                Packages                            localhost
    C:\Packages\\Firefox created
    C:\Packages\\iis created
    C:\Packages\\Php created
    C:\Packages\\Php already exist
    C:\Packages\\Php already exist
    C:\Packages\\Php already exist
    C:\Packages\\Php already exist
    Nuget already installed
    PowershellGet already installed
    PSGallery Trusted
    Pester installed
    PSScriptAnalyzer installed
    xPSDesiredStateConfiguration installed
    xWebAdministration installed
    xPhp installed
    xSQLServer installed
    InvokeBuild installed
#>