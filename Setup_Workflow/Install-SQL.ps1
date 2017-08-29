<#  
    .SYNOPSIS 
        This script install SQLEXPRESS 2016.
    .DESCRIPTION 
        Install SQLEXPRESS 2016, define user, activate Mied Mode.
    .INPUTS
        n/a
    .OUTPUTS
        n/a
    .EXAMPLE
        .\Install-SQL.ps1
    .LINK 
        https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/change-server-authentication-mode
        https://docs.microsoft.com/en-us/sql/relational-databases/security/choose-an-authentication-mode
        https://technet.microsoft.com/en-us/library/dd206997(v=sql.105).aspx
    .NOTES 
        # VERSION 0.1 [WIP]
        # AUTHOR: Arnaud Landry [https://github.com/arnaud-landry]
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string] $xFunctionsPath
)

### FUNCT
    . $xFunctionsPath

### VAR
    #$SqlSaDefaultPassword="SA-PWD-CHANGEME-723387667"
    #$SqlSaNewPassword = Read-Host 'What is your SA password?'
    #$SqlUserDefaultPassword="SA-PWD-CHANGEME-723387667"
    #$SqlUserNewPassword = Read-Host 'What is your Test-User password?'
    
### MAIN
    #Write-Output "Modify configuration.ini"
    #(Get-Content "C:\Packages\Sql\SQL2016Express-Configuration.ini").replace($SqlSaDefaultPassword, $SqlSaNewPassword) | Set-Content "C:\Packages\Sql\SQL2016Express-Configuration.ini"
    
    
    Write-Output "Install SQL"
    cd "C:\Packages\Sql\"
    $SqlSvc = Get-Service | where {$_.Name -like "*MSSQL*"}
    if([string]::IsNullOrEmpty($SqlSvc))
    {
        Write-Output "Install in progress , PLEASE WAIT !"
        .\SQLServer2016-SSEI-Expr.exe `
            /IAcceptSqlServerLicenseTerms `
            /ConfigurationFile=C:\Packages\Sql\SQL2016Express-Configuration-WithoutSA.ini `
            /MediaPath=C:\Packages\Sql\SqlServer2016Setup\
    }
    else{
        Write-Output "SQL already installed"
    }
    Write-Output "SQL - WAIT until install is completed"
   
    <#
    Start-Sleep 1800

    Write-Output "Update env:Path
    $env:Path += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn"
    SQLCMD.EXE /? | select-object -first 2

    Write-Output "SQL - Change SA password"
    $SQLChangeSAPassword = "C:\Packages\Sql\SQL-ChangeSAPassword.sql"
    (Get-Content $SQLChangeSAPassword).replace($SqlSaDefaultPassword, $SqlSaNewPassword) | Set-Content $SQLChangeSAPassword
    sqlcmd -S localhost\SQLEXPRESS -i $SQLChangeSAPassword

    Write-Output "SQL - Enable SA Login"
    $SQLEnableSA = "C:\Packages\Sql\SQL-EnableSA.sql"
    sqlcmd -S localhost\SQLEXPRESS -i $SQLEnableSA 

    Write-Output "SQL - Create TestDb"
    $SQLCreateTestDb  = "C:\Packages\Sql\SQL-CreateTestDb.sql"
    sqlcmd -S localhost\SQLEXPRESS -i $SQLCreateTestDb 

    Write-Output "SQL - Create TestUser"
    $SQLCreateTestUser = "C:\Packages\Sql\SQL-CreateTestUser.sql"
    (Get-Content $SQLCreateTestUser).replace($SqlUserDefaultPassword, $SqlUserNewPassword) | Set-Content $SQLCreateTestUser
    sqlcmd -S localhost\SQLEXPRESS -i $SQLCreateTestUser 

    Write-Output "SQL - Enable Mixed Mode"
    $SqlMixedModePath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQLServer\"
    $SqlMixedModeProperty = "LoginMode"
    $SqlMixedModeValue = "2"
    Set-ItemProperty -Path $SqlMixedModePath -Name $SqlMixedModeProperty -Value $SqlMixedModeValue
    Get-ItemProperty -Path $SqlMixedModePath -Name $SqlMixedModeProperty

    Write-Output "SQL - Generate testsql.php file"
    $SQLTestFile = "C:\Packages\Sql\TestSql.php"
    (Get-Content $SQLTestFile).replace($SqlUserDefaultPassword, $SqlUserNewPassword) | Set-Content $SQLTestFile

    #Write-Output "SQL - Enable TCPIP" =» later
    #Pause

    Write-Output "SQL - Restart SVC"
    Restart-Service "MSSQL`$SQLEXPRESS"
    Get-Service "MSSQL`$SQLEXPRESS"

    Write-Output "Install SMS 17.2"
    cd "C:\Packages\Sql\"
    .\SMS-17-2-Setup.exe /Install /norestart
    Write-Output "please wait...."
    Get-Process -Name "SMS-17-2-Setup"
    Get-Process -Name "msiexec"
    #>