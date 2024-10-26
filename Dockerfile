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
 wget https://github.com/oneapi-src/level-zero/releases/download/v1.18.3/level-zero_1.18.3+u22.04_amd64.deb && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17791.9/intel-igc-core_1.0.17791.9_amd64.deb && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17791.9/intel-igc-opencl_1.0.17791.9_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.39.31294.12/intel-level-zero-gpu_1.6.31294.12_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.39.31294.12/intel-opencl-icd_24.39.31294.12_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.39.31294.12/libigdgmm12_22.5.2_amd64.deb && \
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
    intel-oneapi-common-vars=2024.0.0-49406 \
    intel-oneapi-common-oneapi-vars=2024.0.0-49406 \
    intel-oneapi-compiler-dpcpp-cpp=2024.0.2-49895 \
    intel-oneapi-dpcpp-ct=2024.0.0-49381 \
    intel-oneapi-mkl=2024.0.0-49656 \
    intel-oneapi-mpi=2021.11.0-49493 \
    intel-oneapi-dal=2024.0.1-25 \
    intel-oneapi-ippcp=2021.9.1-5 \
    intel-oneapi-ipp=2021.10.1-13 \
    intel-oneapi-tlt=2024.0.0-352 \
    intel-oneapi-ccl=2021.11.2-5 \
    intel-oneapi-dnnl=2024.0.0-49521 \
    intel-oneapi-tcm-1.0=1.0.0-435

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

