
#docker info
#docker images
#docker ps
#docker rmi mcr.microsoft.com/mssql/server;
#docker inspect sql2022 -f "{{ .NetworkSettings.Networks.nat.IPAddress }}"
#docker inspect postgresql --format '{{ json .Mounts }}' # | python -m json.tool
#docker inspect postgresql --format "{{ json .Config.Env }}" | ConvertFrom-Json # | ConvertTo-Json
#docker exec postgresql /usr/bin/env
#docker exec postgresql psql -U sa -l

$Env:SqlPassword='changeMe!789'

# Set up the Docker DB backup location
docker volume create dbbackups
docker run --rm -v $Env:SYSTEMDRIVE\Temp\DbBackups\:/source -v dbbackups:/dest -w /source alpine cp . /dest -r
#docker run --rm -it -v dbbackups:/mnt/dbbackups alpine ls -l /mnt/dbbackups

docker stop postgresql; docker rm postgresql;
docker run --name postgresql -e POSTGRES_USER=sa -e POSTGRES_PASSWORD="$Env:SqlPassword" -e POSTGRES_DB=ManagedService -v pgsqldata:/var/lib/postgresql/data -v dbbackups:/mnt/dbbackups -p 5432:5432 -d postgres #--restart=on-failure:3
# Check that the ManagedService DB is online before running the next command
docker exec postgresql pg_restore --host=localhost --username=sa -W --format=d --dbname=ManagedService --no-owner --no-privileges /mnt/dbbackups/pgdump

docker stop sql2022; docker rm sql2022;
docker run --name sql2022 -e SA_PASSWORD="$Env:SqlPassword" -e ACCEPT_EULA=Y -v mssqldata:/var/opt/mssql -v dbbackups:/mnt/dbbackups -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest
# Azure Data Studio steps: Install the Admin Pack for SQL Server extension. Right click the server and select "Data-tier Application Wizard" --> Create a database from a .bacpac file [Import Bacpac].
# docker exec -it sql2022 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$Env:SqlPassword" `
#    -Q "SELECT TOP 0 * FROM master"

# https://www.db-fiddle.com/f/cQNoTXkenX2autVtaw3cD/1
# SELECT ROW_NUMBER() OVER (ORDER BY Amount DESC) AS RowNum