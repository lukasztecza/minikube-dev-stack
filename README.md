# minikube-dev-stack
Repository that should help you with development using minkube docker and some common tools

### how to use it
- Get and install git - follow steps here
```
https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
```
- Get and install docker - follow steps here
```
https://docs.docker.com/get-docker/
```
- make sure that you can run docker without `sudo` cause minikube requires that (note that it is ok on dev but you should never add regular users to docker group on production!)
```
https://docs.docker.com/engine/install/linux-postinstall/
```
- Get and install kubectl to communicate with your minikube instace (you will use same tool to communicate with production kubernetes) follow steps here
```
https://kubernetes.io/docs/tasks/tools/
```
- Get and install minikube that is prebuild cluster for dev - follow steps here
```
https://minikube.sigs.k8s.io/docs/start/
```
- Set default driver of your minikube to docker (if it is not done by default)
```
minikube config set driver docker
```
- Once you have it just run `helper.sh` script to start minikube and then create, load and deploy dev apps to minikube
```
./helper.sh -u
```
- Note that it will mount `../.` directory to minikube's /dev-host-dir (this is to make it possible to share files between pods and host machine not only minikube)
- Note that deployments that helper uses for dev apps create mounts for databases so data will be persistent (if you do not want that do not mount it in deployments)
- Note that dev environment creates ssl certificates for dev-nginx
- Note that in order to mount directories on dev without using root helper creates devuser:devgroup with 1010 uid and gid on your host that is used also by containers
- If you run `helper.sh` without any flag it will give you help info on other options
- To close and cleanup cluster (so later you can start new fresh instance) run
```
./helper.sh -d
```
- You may find this useful if you prefer to have gui (open in new terminal window)
```
minikube dashboard
```
- As long as your app is in paralel directory to `dev-stack` with proper directory structure you can use helper to deploy apps to minikube cluster
```
./helper.sh -b -i some_app
```
- To prepare image for production run (note -p instead of -b)
```
./helper.sh -p -i some_app
```
- Make sure you kubectl is in proper context
