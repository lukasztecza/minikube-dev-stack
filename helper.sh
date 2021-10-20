#!/bin/bash

### this script assumes that your dev directory structure looks as follows (files important for this script are mentioned here)
#/some_dir_where_you_clone_git_reposs/minikube-dev-stack/helper.sh
#/some_dir_where_you_clone_git_reposs/some-app/Dockerfile
#/some_dir_where_you_clone_git_reposs/some-app/manifest/dev/deployment.yaml
#/some_dir_where_you_clone_git_reposs/some-app/manifest/dev/service.yaml
#/some_dir_where_you_clone_git_reposs/some-app/manifest/dev/cronjobs.yaml
#...
# note that for production ready images builds there should be /manifest/prod/ apart from /manifest/dev/

# these apps live in dev-stack and should only be used on dev as a replacement for prod services where cloud based services should be used
DEV_APPS=("dev-pgsql" "dev-mysql" "dev-memcached" "dev-rabbitmq" "dev-nginx")
#DEV_APPS=("dev-pgsql" "dev-memcached" "dev-nginx")
#DEV_APPS=("dev-pgsql" "dev-nginx")
#DEV_APPS=("dev-nginx")

# apps that should always be deployed to cluster beside dev-apps (above)
ALWAYS_DEPLOY=()

# production docker registry prefix
PRODUCTION_IMAGE_REPO_PREFIX="some_dockerhub_repo"

# script flags and vars
ABSOLUTE_DIR=$(pwd)
CURRENT_DIR=$(dirname $0)
ACTION="help"
IMAGE="none"
TAG=$(date +"%Y%m%d%H%M")

while getopts hbpt:i:ucd OPT; do
    case "$OPT" in
    h) ACTION="help";;
    b) ACTION="build";;
    p) ACTION="prod";;
    t) TAG="$OPTARG";;
    i) IMAGE="$OPTARG";;
    u) ACTION="up";;
    c) ACTION="clean";;
    d) ACTION="deleteall"
    esac
done

function checkMinikubeAndKubectl {
    if ! minikube status 2>&1 | grep "host: Running"; then
        if [ "$ACTION" == "up" ] ; then
            minikube start --mount --mount-string="$ABSOLUTE_DIR/$CURRENT_DIR/../:/dev-host-dir"
        else
            echo "Minikube needs to be started before using helper - first run ./helper -u"
            exit 0
        fi
    fi
    if ! kubectl config current-context | grep minikube; then
        echo "Your kubectl have to be in minikube context to run build command"
        exit 0
    fi
}

function buildSpecifiedImageForProd {
    if ls "$CURRENT_DIR/../$IMAGE/Dockerfile" 2>&1 | grep "Dockerfile" | grep -v "No such file or directory"; then
        PRODUCTION_IMAGE="$PRODUCTION_IMAGE_REPO_PREFIX/$IMAGE:$TAG"
        echo "Building production ready image $PRODUCTION_IMAGE"
        docker build -t $PRODUCTION_IMAGE -f "$CURRENT_DIR/../$IMAGE/Dockerfile" "$CURRENT_DIR/../$IMAGE/."
        if ls "$CURRENT_DIR/../$IMAGE/manifest/prod/deployment.yaml" 2>&1 | grep "deployment.yaml" | grep -v "No such file or directory"; then
            echo "Updating prod deployment.yaml"
            # avoid lines that should not have image replaced in case deployment file uses fluentd-kubernetes
            sed -i "" -e "/fluentd-kubernetes/! s#image:.*#image: $PRODUCTION_IMAGE#g" "$CURRENT_DIR/../$IMAGE/manifest/prod/deployment.yaml"
        fi
        if ls "$CURRENT_DIR/../$IMAGE/manifest/prod/cronjobs.yaml" 2>&1 | grep "cronjobs.yaml" | grep -v "No such file or directory"; then
            echo "Updating prod cronjobs.yaml"
            sed -i "" -e "s#image:.*#image: $PRODUCTION_IMAGE#g" "$CURRENT_DIR/../$IMAGE/manifest/prod/cronjobs.yaml"
        fi
        echo "Push it to your code repository and image registry $PRODUCTION_IMAGE"
        echo "If your app contains assets make sure to copy them to proper static bucket as assets should not be copied to the image but should be accessible to the web server"
    else
        echo "Could not find Dockerfile for in $CURRENT_DIR/../$IMAGE"
    fi
}

function buildSpecifiedImageAndDeploy {
    if ls "$CURRENT_DIR/../$IMAGE/Dockerfile" 2>&1 | grep "Dockerfile" | grep -v "No such file or directory"; then
        if ls "$CURRENT_DIR/../$IMAGE/manifest/dev/deployment.yaml" 2>&1 | grep "deployment.yaml" | grep -v "No such file or directory"; then
            if ! docker image ls 2>&1 | grep $IMAGE | grep $TAG; then
                echo "Building image $IMAGE:$TAG"
                echo "Development image"
                docker build --build-arg=ENABLE_OPCACHE=0 -t $IMAGE:$TAG -f "$CURRENT_DIR/../$IMAGE/Dockerfile" "$CURRENT_DIR/../$IMAGE/."
                echo "Updating deployment.yaml with image: $IMAGE:$TAG"
                echo "For dev deployment"
                sed -i "" -e "s/image:.*/image: $IMAGE:$TAG/g" "$CURRENT_DIR/../$IMAGE/manifest/dev/deployment.yaml"
                if ls "$CURRENT_DIR/../$IMAGE/manifest/dev/cronjobs.yaml" 2>&1 | grep "cronjobs.yaml" | grep -v "No such file or directory"; then
                    echo "Updating cronjobs.yaml with image: $IMAGE:$TAG"
                    echo "For dev deployment"
                    sed -i "" -e "s/image:.*/image: $IMAGE:$TAG/g" "$CURRENT_DIR/../$IMAGE/manifest/dev/cronjobs.yaml"
                fi
            fi
            echo "Loading image to minikube"
            minikube image load $IMAGE:$TAG
            echo "Applying manifest using kubectl"
            kubectl apply -f "$CURRENT_DIR/../$IMAGE/manifest/dev"
        else
            echo "Could not find deployment.yaml for in $CURRENT_DIR/../$IMAGE/manifest/dev"
        fi
    else
        echo "Could not find Dockerfile for in $CURRENT_DIR/../$IMAGE"
    fi
}

function checkDevDirsAndFiles {
    echo "Creating dev directories and files"
    if cat "/etc/passwd" 2>&1 | grep "1010"; then
        echo "user group gid 1010 already created"
    else
        sudo /usr/sbin/addgroup --gid 1010 --system devgroup
        sudo /usr/sbin/adduser --uid 1010 --gid 1010 --system --no-create-home devuser
    fi
    if ls "$CURRENT_DIR/dev-nginx/ssldir" 2>&1 | grep "No such file or directory"; then
        mkdir "$CURRENT_DIR/dev-nginx/ssldir"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$CURRENT_DIR"/dev-nginx/ssldir/privkey.pem \
        -out "$CURRENT_DIR"/dev-nginx/ssldir/fullchain.pem -subj "/C=CA/ST=Ontario/L=Toronto/O=Local/OU=Local/CN=*.localhost"
        sudo chown 1010:1010 "$CURRENT_DIR"/dev-nginx/ssldir/*.pem
    fi
    if ls "$CURRENT_DIR/dev-nginx/assetsdir" 2>&1 | grep "No such file or directory"; then
        mkdir "$CURRENT_DIR/dev-nginx/assetsdir"
        sudo chown 1010:1010 "$CURRENT_DIR"/dev-nginx/assetsdir
    fi
    if ls "$CURRENT_DIR/dev-pgsql/dbdir" 2>&1 | grep "No such file or directory"; then
        mkdir "$CURRENT_DIR/dev-pgsql/dbdir"
        sudo chown 1010:1010 "$CURRENT_DIR"/dev-pgsql/dbdir
    fi
    if ls "$CURRENT_DIR/dev-mysql/dbdir" 2>&1 | grep "No such file or directory"; then
        mkdir "$CURRENT_DIR/dev-mysql/dbdir"
        sudo chown 1010:1010 "$CURRENT_DIR"/dev-mysql/dbdir
    fi
}

function cleanDevDirsAndFiles {
    echo "Cleaning up dev directories and files"
    sudo /usr/sbin/userdel devuser
    sudo /usr/sbin/groupdel devgroup
    sudo rm -rf "$CURRENT_DIR/dev-nginx/ssldir";
    sudo rm -rf "$CURRENT_DIR/dev-nginx/assetsdir";
    sudo rm -rf "$CURRENT_DIR/dev-pgsql/dbdir";
    sudo rm -rf "$CURRENT_DIR/dev-mysql/dbdir";
}

function loadDevImagesAndDeployConfigurations {
    for DEV_APP in ${DEV_APPS[@]}; do
        echo "Dev app $DEV_APP"
        if ! docker image ls 2>&1 | grep $DEV_APP; then
            echo "Building image"
            docker build -t $DEV_APP -f "$CURRENT_DIR/$DEV_APP/Dockerfile" "$CURRENT_DIR/$DEV_APP/."
        fi
        if ! minikube image list 2>&1 | grep $DEV_APP; then
            echo "Loading image to minikube"
            minikube image load $DEV_APP:latest
        fi
        echo "Applying manifest using kubectl"
        kubectl apply -f "$CURRENT_DIR/$DEV_APP/manifest"
    done
    for ALWAYS_DEPLOY_ITEM in ${ALWAYS_DEPLOY[@]}; do
        echo "Applying manifest for dev configs $ALWAYS_DEPLOY_ITEM"
        if ls "$CURRENT_DIR/../$ALWAYS_DEPLOY_ITEM/manifest/dev/deployment.yaml" 2>&1 | grep "deployment.yaml" | grep -v "No such file or directory"; then
            ALWAYS_DEPLOY_ITEM_IMAGE_WITH_TAG=$( cat "$CURRENT_DIR/../$ALWAYS_DEPLOY_ITEM/manifest/dev/deployment.yaml" | grep image: | awk '{print $2}' )
            if ! minikube image list 2>&1 | grep $ALWAYS_DEPLOY_ITEM_IMAGE_WITH_TAG; then
                echo "Loading specific image to minikube $ALWAYS_DEPLOY_ITEM_IMAGE_WITH_TAG"
                minikube image load $ALWAYS_DEPLOY_ITEM_IMAGE_WITH_TAG
            fi
            kubectl apply -f "$CURRENT_DIR/../$ALWAYS_DEPLOY_ITEM/manifest/dev"
        else
            echo "Could not find deployment.yaml for in $CURRENT_DIR/../$ALWAYS_DEPLOY_ITEM/manifest/dev"
        fi
    done
    echo "For kubernetes ui run"
    echo "minikube dashboard"
}

if [ "$ACTION" == "help" ]; then
    cat << EndOfMessage
===============================================================================================================================================================
This helper is to help you build and tag images, deploy or remove configurations for minikube.
This helper assumes that you have minikue installed already
This helper assumes that you have kubectl installed already
This helper will mount ../. directory to minikube's /dev-host-dir (to make it possible to share files between pods and host machine not only minikube)
This helper by default passes --build-arg=ENABLE_OPCACHE=0 on docker build stage when you use -b flag (you may want to use it in php builds)
In order to prepare image for production build set ENABLE_OPCACHE=1 in Dockerfile (if you intend to use it)
This helper updates your deployment.yaml and cronjobs.yaml image line with whatever it builds
Run like this:
./helper.sh -h
Where instead of -h you may pass any other recognized flag which are:
-h Display this help (default value if no flag is provided).
-b Build image for your app specified by -i flag (optionally pass -t to specify tag) load to minikube and deploy
   this flag assumes that your app files needed for build are accessible by
   ../your_app/Dockerfile
   ../your_app/manifest/dev/deployment.yaml
-i Specify image for build command
-t Specify tag for build command or for deploy command
-u Deploy configurations from DEV_APPS, DEV_SECRETS, DEV_VOLUMES
-d Delete minikube cluster so you can start a new fresh instance later if you need to
-p Build production ready image specified by -i flag (optionally pass -t to specify tag)
Sample usage
./helper.sh -u
./helper.sh -b -i some-app -t some-tag
Most common kubectl commands
kubectl get all
kubectl get pods
kubectl apply -f path_to_manifest_yaml_files
kubectl delete -f path_to_manifest_yaml_files
kubectl port-forward service/dev-nginx 8080 8181 8443
kubectl port-forward service/dev-memcached 11211
kubectl port-forward service/dev-rabbitmq 15672 
kubectl exec -it name_of_some_pod -- sh
kubectl exec -it name_of_the_pgsql_pod -- psql -Uroot -dmydb
kubectl exec -it name_of_the_mysql_pod -- psql -uroot -pmypass
kubectl config get-contexts
kubectl config use-context some_context
kubectl scale deployment/some-deployment --replicas=1
kubectl create job --from=cronjob/some-cronjob same-job-name
kubectl rollout undo deployment/your_deployment
kubectl rollout history deployment/your_deployment
kubectl rollout undo deployment/your_deployment --to-revision=2
Most common minikube commands
minikube dashboard
minikube image load some_image:some_tag
minikube config set driver docker
minikube ssh
From within minikube to have root access to some container
docker container ls
docker exec -ti -uroot some_container sh
If minikube context is broken then run
minikube update-context
If you want to get rid of old images run
docker image rm \$(docker image ls | grep image_name | grep -v tagname_that_you_want_to_keep | awk '{print \$1 ":" \$2}')
===============================================================================================================================================================
EndOfMessage
elif [ "$ACTION" == "build" ] && [ "$IMAGE" != "none" ]; then
    checkMinikubeAndKubectl
    buildSpecifiedImageAndDeploy
elif [ "$ACTION" == "up" ] ; then
    checkMinikubeAndKubectl
    checkDevDirsAndFiles
    loadDevImagesAndDeployConfigurations
elif [ "$ACTION" == "prod" ] && [ "$IMAGE" != "none" ]; then
    checkMinikubeAndKubectl
    buildSpecifiedImageForProd
elif [ "$ACTION" == "clean" ] ; then
    cleanDevDirsAndFiles
elif [ "$ACTION" == "deleteall" ] ; then
    minikube delete --all
else
    echo "Invalid action, or not all required flags provided run scirpt with -h for usage."
fi
