# dev-rabbitmq
- This is rabbitmq server that you may want to use on your dev machine
- To run rabbitmq that is accessible on testnetwork assuming you are in dev-rabbitmq directory
```
docker build -t dev-rabbitmq .
docker network create --driver=bridge testnetwork
docker run -d --network=testnetwork -e RABBITMQ_DEFAULT_USER=root -e RABBITMQ_DEFAULT_PASS=mypass -e RABBITMQ_ERLANG_COOKIE=mysecret -p 15672:15672 --name=dev-rabbitmq dev-rabbitmq
```
- Now you should be able to visit and login using `myuser` and `mypass` and use user interface
```
http://localhost:15672
```
- If you prefer you may also use rabbitmqadmin script that was added to the container on build stage (https://www.rabbitmq.com/management-cli.html)
```
docker exec -it dev-rabbitmq sh
rabbitmqadmin -uroot -pmypass list exchanges
rabbitmqadmin -uroot -pmypass list queues
```
- Once done testing remove container and network
```
docker container rm --force $(docker container ls -qa)
docker network rm testnetwork
```
