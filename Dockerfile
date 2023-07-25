### ----- INSTALL TENSORRT ----- ###
FROM nvcr.io/nvidia/tensorrt:20.10-py3

### ----- INSTALL TENSORRT OPEN SOURCE SOFTWARE ----- ###
# Install required libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    wget \
    zlib1g-dev \
    git \
    pkg-config \
    python3 \
    python3-pip

RUN cd /usr/local/bin &&\
   ln -s /usr/bin/python3 python

# Install Cmake
RUN cd /tmp &&\
   wget https://github.com/Kitware/CMake/releases/download/v3.14.4/cmake-3.14.4-Linux-x86_64.sh &&\
   chmod +x cmake-3.14.4-Linux-x86_64.sh &&\
   ./cmake-3.14.4-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir --skip-license &&\
   rm ./cmake-3.14.4-Linux-x86_64.sh

# Download TensorRT OSS
RUN cd /workspace &&\
  git clone -b release/5.1 https://github.com/nvidia/TensorRT TensorRT-OSS &&\
  cd TensorRT-OSS &&\
  git submodule update --init --recursive

# Build TensorRT OSS Components
RUN cd /workspace/TensorRT-OSS &&\
 mkdir -p build &&\
 cd build &&\
 cmake .. -DTRT_LIB_DIR=/usr/lib/x86_64-linux-gnu -DTRT_BIN_DIR=`pwd`/out &&\
 make -j$(nproc)

# Copy over files
RUN cd /workspace/TensorRT-OSS/build/out &&\
  cp *.so* /usr/lib/x86_64-linux-gnu/

### ----- INSTALL PACKAGES FOR RUNNING WEBCAM INFERENCE ----- ###

# Install OpenCV
WORKDIR /
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y libsm6 libxext6 libxrender-dev python3-tk
RUN apt update && apt install -y pkg-config \
  ffmpeg \
  libavformat-dev \
  libavcodec-dev \
  libswscale-dev \
  cmake \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-rtsp \
  python3-dev \
  python3-numpy

RUN git clone --depth=1 -b 4.5.4 https://github.com/opencv/opencv
RUN cd opencv && \
    mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/usr -D WITH_GSTREAMER=ON .. && \
    make -j$(nproc)  && \
    make install 

# RUN mkdir /usr/lib/python3.6/dist-packages
# RUN ln -s /usr/lib/python3.6/site-packages/cv2 /usr/lib/python3.6/dist-packages/

# Install miscellaneous Python packages
RUN /opt/tensorrt/python/python_setup.sh

# Export environment variable for webcam functionality
ENV QT_X11_NO_MITSHM=1

# Return to project directory and open a terminal
WORKDIR /object-detection-tensorrt-example
COPY . .

CMD /bin/bash

# python SSD_Model/detect_objects.py
