# dev-pqsql
- This is database that you may want to use on your dev machine
- To run database that is accessible on testnetwork assuming you are in dev-pgsql directory
```
docker build -t dev-pgsql .
docker network create --driver=bridge testnetwork
docker run -d --network=testnetwork -e POSTGRES_USER=root -e POSTGRES_PASSWORD=mypass -e POSTGRES_DB=mydb -e PGDATA=/var/lib/postgresql/data/pgdata --name=dev-pgsql dev-pgsql
```
- Now you should be able to connect to database using `root` and `mypass` (note that from localhost postgres does not need password)
```
docker exec -ti dev-pgsql psql -Uroot -dmydb
```
- Note that if you want to mount data directory to make it persistent then add `-v $(pwd)/dbdir:/var/lib/postgresql/data/pgdata` when you execute `docker run`
- Once done testing remove container and network
```
docker container rm --force $(docker container ls -qa)
docker network rm testnetwork
```
