* NOTES
    * latest = Version 1
    
    * Version 1 : Ready (POC/Demo only)

        * __Front__ : noahdront:version1

        * __Database__ : noahdb:version1

        * __Backend__ : NO, you'll have to run the backend "noah.ps1" somewhere else

        * Tested on : 

            * Windows 2016, Powershell 5.1 [Azure : Basic A3 : 4vcpu/7GB]

            * Windows 10 Pro, Powershell 5.1 (Docker 17.06.1-ce, build 874a737) 
        
        * data are not persistant

        * SA password set by default, if you change it , modify connection.php on noahfront !
  
    * Version 2 : in progress

        * __Front__ : noahdront:version2 

        * __Database__ : noahdb:version2

        * __Backend__ : noahback:version2

        * Tested on : 

            * Windows 2016, Powershell 5.1 [Azure : Basic A3 : 4vcpu/7GB]

            * Windows 10 Pro, Powershell 5.1 (Docker version 17.06.2-ce, build cec0b72)

        * add backend : noahback 

        * fix SA password (autogen and ENV)

        * add persistant data
    
    * Version 3 : to do
        * __Front__ : noahdront:version3

        * __Database__ : noahdb:version3

        * __Backend__ : noahback:version3

        * add TLS for noahfront (LetsEncrypt)

        * fix sqlexpress licence mode

        * add noahdb dedicated user

        * replace ENV with SECRET

        * docker compose

        * ONE LINER TO PULL AND START CONTAINER

    * Version 4 : to do

        * vagrant env to test the slution

    * Version 5 : to do

        * add linux support as OS Base for noahfront, noahdb and noahback

* USAGE
    docker pull arnaudlandry/noahdb:version1 
    docker pull arnaudlandry/noahfront:version1
    
    docker run -dit -h noahdb --name noahdb -p 1433:1433 -e sa_password="5c4_fdc6a50+1864b89d8a6576bd9dbb-90" -e ACCEPT_EULA=Y arnaudlandry/noahdb:version1
    docker run -dit -h noahfront --name noahfront -p 8000:8000 arnaudlandry/noahfront:version1
    # docker run -dit -h noahfront --name noahfront -p 8000:8000 -e sa_password="5c4_fdc6a50+1864b89d8a6576bd9dbb-90" arnaudlandry/noahfront:version1
    
    $NoahFrontIP=docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" noahfront
    $NoahFrontIP8000=$NoahFrontIP+":8000"
    Write-Output "Server URL : http://$NoahFrontIP8000"
    Write-Output "PhpInfo: http://$NoahFrontIP8000/phpinfo.php"
    Write-Output "Test SQL : http://$NoahFrontIP8000/testsql.php"
    Write-Output " Noah : http://$NoahFrontIP8000/index.php"
    
* COMMAND
    List containers : docker ps -a

    Stop all running containers : docker stop $(docker ps -a -q)

    Remove all containers : docker rm $(docker ps -a -q)
    
    Get container IP : docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" ContainerName

    Connect to conainer : docker exec -ti ContainerName powershell

* LINKS
    NoahDb : https://hub.docker.com/r/arnaudlandry/noahdb/
    
    Noah Front : https://hub.docker.com/r/arnaudlandry/noahfront/
    
    Noah Source : https://github.com/giMini/NOAH

* MISC
    https://social.technet.microsoft.com/wiki/contents/articles/34147.nano-server-deploying-php-7-0-6-on-internet-information-services-iis-web-server.aspx
    https://stackoverflow.com/questions/26504846/copy-directory-to-other-directory-at-docker-using-add-command
    https://blog.docker.com/2016/09/build-your-first-docker-windows-server-container/
    https://github.com/friism/MusicStore/blob/master/Dockerfile.windows
    https://store.docker.com/images/mssql-server-windows-express
    https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms
    https://docs.docker.com/engine/reference/commandline/commit/#commit-a-container-with-new-cmd-and-expose-instructions