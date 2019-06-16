#!/bin/bash

#################################
CONTAINER_NAME='wimscontainer'
IMAGE_NAME='wimsimage'
HOST_PORT='5050'
CONTAINER_DATA_DIR='/DATA'
HOST_DATA_DIR="$(pwd)"/DATA
#################################

if [ "$(docker ps -q -f name=$CONTAINER_NAME -f status=running)" ]; then
	echo "[LOG] --- $CONTAINER_NAME is already running localy"
	exit 0
fi

echo "--------- $(date) "---------" >> .log

if [ "$(docker ps -q -f name=$CONTAINER_NAME -f status=exited)" ]; then
	echo "[LOG] --- $CONTAINER_NAME found"
	docker container start $CONTAINER_NAME >> .log
	echo "[LOG] --- $CONTAINER_NAME has been started"
else
	echo "[LOG] --- No $CONTAINER_NAME found"
	if [[ "$(docker images -q $IMAGE_NAME:latest 2> /dev/null)" == "" ]]; then
		echo "[LOG] --- no $IMAGE_NAME found."
		echo "[LOG] --- Build docker image is starting...."
		docker build -t $IMAGE_NAME . >> .log
		echo "[LOG] --- Build SUCCES"
	else
		echo "[LOG] --- $IMAGE_NAME already exists"
		echo "[LOG] --- Creating $CONTAINER_NAME from $IMAGE_NAME..."
		docker run -itd -p 5050:80 -v "$(pwd)"/DATA:/DATA --name $CONTAINER_NAME $IMAGE_NAME >> .log
		echo "[LOG] --- $CONTAINER_NAME has been started"
	fi
fi

echo "[LOG] --- restart services from $CONTAINER_NAME"
docker exec -it $CONTAINER_NAME ./bin/apache-config >> .log
docker exec -it $CONTAINER_NAME service apache2 restart >> .log

echo "[LOG] --- $CONTAINER_NAME is running !"
echo "------> http://localhost:5050/wims"

echo "----------------------------------------------------------------------------------" >> .log
echo "" >> .log
echo "" >> .log
