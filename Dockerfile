FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=america/los_angeles

# Base packages
RUN apt update && \
    apt install --no-install-recommends -q -y \
    software-properties-common \
    ca-certificates \
    gnupg \
    wget \
    ocl-icd-libopencl1

# Intel GPU compute user-space drivers
RUN mkdir -p /tmp/gpu && \
 cd /tmp/gpu && \
 wget https://github.com/oneapi-src/level-zero/releases/download/v1.19.2/level-zero_1.19.2+u24.04_amd64.deb && \ 
 wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.5.6/intel-igc-core-2_2.5.6+18417_amd64.deb && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.5.6/intel-igc-opencl-2_2.5.6+18417_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/intel-level-zero-gpu_1.6.32224.5_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/intel-opencl-icd_24.52.32224.5_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.52.32224.5/libigdgmm12_22.5.5_amd64.deb && \
 dpkg -i *.deb && \
 rm *.deb

ENV ZES_ENABLE_SYSMAN=1

# Intel GPU compute user-space drivers
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

# Install Python 3.11 via conda
RUN cd /tmp && \
  wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
  bash Miniforge3-$(uname)-$(uname -m).sh -b && \
  rm Miniforge3-$(uname)-$(uname -m).sh 

# Install ipex-llm and Ollama
RUN /bin/bash -c "source /root/miniforge3/bin/activate  && \
  conda create -n ipex python=3.11* -y" && \ 
  /bin/bash -c "source /root/miniforge3/bin/activate ipex && \
  pip install --upgrade pip && \
  pip install --pre --upgrade ipex-llm[cpp] && \
  cd /root && \
  init-ollama"

ENV OLLAMA_NUM_GPU=999
ENV OLLAMA_HOST=0.0.0.0:11434

COPY _init.sh /usr/share/lib/init_workspace.sh
COPY _run.sh /usr/share/lib/run_workspace.sh

ENTRYPOINT ["/bin/bash", "/usr/share/lib/run_workspace.sh"]
