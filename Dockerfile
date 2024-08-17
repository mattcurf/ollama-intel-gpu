FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=america/los_angeles

# Base packages
RUN apt update && \
    apt install --no-install-recommends -q -y \
    software-properties-common \
    ca-certificates \
    gnupg \
    wget \
    curl \
    python3 \
    python3-pip \
    ocl-icd-libopencl1

# Intel GPU compute user-space drivers
RUN mkdir -p /tmp/gpu && \
 cd /tmp/gpu && \
 wget https://github.com/oneapi-src/level-zero/releases/download/v1.17.19/level-zero_1.17.19+u22.04_amd64.deb && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17193.4/intel-igc-core_1.0.17193.4_amd64.deb && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17193.4/intel-igc-opencl_1.0.17193.4_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/intel-level-zero-gpu_1.3.30049.6_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/intel-opencl-icd_24.26.30049.6_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/libigdgmm12_22.3.20_amd64.deb && \
 dpkg -i *.deb && \
 rm *.deb

# Required compute runtime level-zero variables
ENV ZES_ENABLE_SYSMAN=1

# oneAPI 
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
   gpg --dearmor --output /usr/share/keyrings/oneapi-archive-keyring.gpg && \
   echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
   tee /etc/apt/sources.list.d/oneAPI.list && \
  apt update && \
  apt install --no-install-recommends -q -y \
  intel-basekit

# Required oneAPI environment variables
ENV USE_XETLA=OFF
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
ENV SYCL_CACHE_PERSISTENT=1

COPY _init.sh /usr/share/lib/init_workspace.sh
COPY _run.sh /usr/share/lib/run_workspace.sh

# Ollama via ipex-llm 
RUN pip3 install --pre --upgrade ipex-llm[cpp] 

ENV OLLAMA_NUM_GPU=999
ENV OLLAMA_HOST=0.0.0.0:11434

ENTRYPOINT ["/bin/bash", "/usr/share/lib/run_workspace.sh"]

