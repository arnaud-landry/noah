# The script sets the sa password and start the SQL Service
# Also it attaches additional database from the disk
# The format for attach_dbs

param(
    [Parameter(Mandatory=$false)]
    [string]$DbUser,
    [Parameter(Mandatory=$false)]
    [string]$DbPassword
    )

    if($sa_password -ne "_"){
        # Modify connection.php
        Write-Output "modifying connection.php"
        $NoahConn = "C:\inetpub\wwwroot\noah\connection.php"
        (Get-Content $NoahConn).replace("P@ssword3!", $DbPassword) | Set-Content $NoahConn
        (Get-Content $NoahConn).replace("Administrator", $DbUser) | Set-Content $NoahConn
        (Get-Content $NoahConn).replace("SQL01", "noahdb") | Set-Content $NoahConn
    }