# dev-mysql
- This is database that you may want to use on your dev machine
- To run database that is accessible on testnetwork assuming you are in dev-mysql directory
```
docker build -t dev-mysql .
docker network create --driver=bridge testnetwork
docker run -d --network=testnetwork -e MYSQL_ROOT_PASSWORD=mypass -e MYSQL_DATABASE=mydb --name=dev-mysql dev-mysql
```
- Now you should be able to connect to database using `root` and `mypass`
```
docker exec -ti dev-mysql mysql -uroot -pmypass
```
- You may want to create databases for your dev environment
```
create database mydb;
```
- Note that if you want to mount data directory to make it persistent then add `-v $(pwd)/dbdir:/var/lib/mysql` when you execute `docker run`
- Once done testing remove container and network
```
docker container rm --force $(docker container ls -qa)
docker network rm testnetwork
```
