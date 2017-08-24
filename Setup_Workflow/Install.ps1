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