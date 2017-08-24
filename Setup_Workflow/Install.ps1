# download only for now ...
workflow Noah {
    Param(
        $DownloadFolder = "C:\Packages\"
       )
    Remove-Item $DownloadFolder -Force -Recurse

    New-Item -Type Directory $DownloadFolder 
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/arnaud-landry/noah/master/Setup_Workflow/xFunctions.ps1" -OutFile "$DownloadFolder\xFunctions.ps1"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/arnaud-landry/noah/master/Setup_Workflow/Download-Src.ps1" -OutFile "$DownloadFolder\Download-Src.ps1"
     
    $Results = InlineScript {
        #Get-childitem $using:DownloadFolder
        C:\Packages\Download-Src.ps1 -xFunctionsPath $using:DownloadFolder\xFunctions.ps1 -DownloadFolder $using:DownloadFolder
    }
    return $Results

}
Noah