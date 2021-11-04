# dev-redis
- This is redis server that you may want to use on your dev machine
- To run redis that is accessible on testnetwork assuming you are in dev-reids directory
```
docker build -t dev-redis .
docker network create --driver=bridge testnetwork
docker run -d --network=testnetwork --name=dev-redis dev-redis
```
- Now you should be able to connect to memcached instance using
```
docker exec -ti dev-redis redis-cli
```
- Now you should be able to run for instance
```
set some_key some_value
```
- Get stored value with following command
```
get some_key
```
- Exit redis
```
quit
```
- Once done testing remove container and network
```
docker container rm --force $(docker container ls -qa)
docker network rm testnetwork
```
