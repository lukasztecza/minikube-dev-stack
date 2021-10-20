# nginx-proxy
- Note that this nginx instance runs as non root user hence server listens on port 8080 instead of default 80 (which requires root access)
- Note that this repo is able to handle internal traffic through `private-web-server:8181/target_service/url_that_will_get_passed_to_target_service`
- Important! On production servers port 8181 can not be mapped to publicly available port! Only port 8080 should be accessible outside of vpc!
- Note that this image expects resolver and fqdn enviromental variables to be passed cause it will use them to replace values in conf files on deploy
### Check (this is just to confirm if everything works as expected - for dev you should use minikube)
- Build image and run nginx-proxy on testnetwork
```
docker build -t nginx-proxy .
docker network create --driver=bridge testnetwork
docker run -d -p 80:8080 -p 8181:8181 --network=testnetwork -e NGINX_LOCATION_RESOLVER=127.0.0.11 -e NGINX_SERVICE_NAME_FQDN_ADDITION= nginx-proxy
```
- Now you should be able to hit
```
http://localhost/favicon.ico
http://localhost/favicon.jpg
http://localhost/nginxhealth
```
- You may want to update your `/etc/hosts` file and include there for instance
```
127.0.0.1 somedomain.com.localhost
127.0.0.1 www.somedomain.com.localhost
```
- Now you should be able to hit
```
http://www.somedomain.com.localhost/favicon.ico
http://www.somedomain.com.localhost/favicon.jpg
http://www.somedomain.com.localhost/nginxhealth
```
- If you hit url without `www` you should get redireced to url that contains `www.` 
```
http://somedomain.com.localhost/nginxhealth
```
- Note that we exposed port 8181 (which must not be exposed on production!)
- You should be able to hit private health check now
```
http://localhost:8181/nginxhealth
```
- Once done testing remove from your `/etc/hosts`
```
127.0.0.1 somedomain.com.localhost
127.0.0.1 www.somedomain.com.localhost
```
- And cleanup containers
```
docker container rm --force $(docker container ls -qa)
docker network rm testnetwork
```
