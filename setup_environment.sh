set -e
# # So that docker can see the webcam
# echo "Setting envivonment variables for the webcam" 
# xhost +local:docker
# XSOCK=/tmp/.X11-unix
# XAUTH=/tmp/.docker.xauth
# xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# # Download the VOC dataset for INT8 Calibration 
# DATA_DIR=VOCdevkit
# if [ -d "$DATA_DIR" ]; then
# 	echo "$DATA_DIR has already been downloaded"
# else
# 	echo "Downloading VOC dataset"
# 	wget http://host.robots.ox.ac.uk/pascal/VOC/voc2007/VOCtest_06-Nov-2007.tar
# 	tar -xf VOCtest_06-Nov-2007.tar
# fi

echo "Building docker image" 
docker build -f Dockerfile --tag=neilvaltec/tensorrt_object_detection:0.0.1 .

# Start the docker container
echo "Starting docker container" 
export CAMERA_SIMULATOR_CONTAINER_ID=$(docker ps -q)
# docker run --network=container:${CAMERA_SIMULATOR_CONTAINER_ID} --runtime=nvidia -it -v `pwd`:/mnt -e DISPLAY=$DISPLAY -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH neilvaltec/tensorrt_object_detection:0.0.1
docker run --network=container:${CAMERA_SIMULATOR_CONTAINER_ID} --runtime=nvidia -it -e DISPLAY=$DISPLAY -v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH neilvaltec/tensorrt_object_detection:0.0.1