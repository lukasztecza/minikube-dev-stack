# dev-memcached
- This is memcached server that you may want to use on your dev machine
- To run memcached that is accessible on testnetwork assuming you are in dev-memcached directory
```
docker build -t dev-memcached .
docker network create --driver=bridge testnetwork
docker run -d --network=testnetwork -p 11211:11211 --name=dev-memcached dev-memcached
```
- Now you should be able to connect to memcached instance using
```
telnet localhost 11211
```
- Now you should be able to run for instance (create key value pair and obtain value - note that 900 indicates 900 seconds and 10 indicates length of `some_value`)
```
add some_key 0 900 10
```
- Now write and hit enter
```
some_value
```
- Get stored value with following command
```
get some_key
```
- You may also check slabs and dump cache from one of them (this assumes that after previous command slab 1 was created and we are taking 10 records from it)
```
stats slabs
stats cachedump 1 10
delete some_key
quit
```
- Once done testing remove container and network
```
docker container rm --force $(docker container ls -qa)
docker network rm testnetwork
```
