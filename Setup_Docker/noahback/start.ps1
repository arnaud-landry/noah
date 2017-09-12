# The script sets the sa password and start the SQL Service
# Also it attaches additional database from the disk
# The format for attach_dbs

param(
    [Parameter(Mandatory=$false)]
    [string] $NoahBackendFolder="C:\Noah\"
    )

    $lastCheck = (Get-Date).AddSeconds(-2)
    while ($true) {
        Test-Path $NoahBackendFolder
        Start-Sleep -Seconds 60
    }