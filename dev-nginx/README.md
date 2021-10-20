# dev-nginx
- Note that this nginx instance runs as non root user hence server listens on port 8080 instead of default 80 (which requires root access)
- Note that this repo is able to handle internal traffic through `localhost:8181/target_service/url_that_will_get_passed_to_target_service`
- Important! On production servers port 8181 can not be mapped to publicly available port! Only ports 8080 and 8443 should be accessible outside of vpc!
- Note that this image expects resolver and fqdn enviromental variables to be passed cause it will use them to replace values in conf files on deploy
### Check (this is just to confirm if everything works as expected - for dev you should use minikube)
- Exclude `extra.conf` from `nginx.conf` (extra.conf requires ssl certs to be set up and here we will not do it)
```
#    include /etc/nginx/conf.d/extra.conf;
```
- Build image and run dev-nginx on testnetwork
```
docker build -t dev-nginx .
docker network create --driver=bridge testnetwork
docker run -d -p 8080:8080 -p 8181:8181 --network=testnetwork -e NGINX_LOCATION_RESOLVER=127.0.0.11 -e NGINX_SERVICE_NAME_FQDN_ADDITION= --name=dev-nginx dev-nginx
```
- Now you should be able to hit
```
http://localhost/favicon.ico
http://localhost/favicon.jpg
http://localhost/nginxhealth
```
- Note that we exposed port 8181 (which must not be exposed on production!)
- You should be able to hit private health check now
```
http://localhost:8181/nginxhealth
```
- Once done testing remove container and network
```
docker container rm --force $(docker container ls -qa)
docker network rm testnetwork
```
- Do not foget to include back `extra.conf` in `nginx.conf` if you intend to use it
