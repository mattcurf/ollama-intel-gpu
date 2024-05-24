FROM ubuntu:22.04
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=america/los_angeles

# #1 install base packages
#-----------------------
RUN apt update && \
    apt install --no-install-recommends -q -y \
    software-properties-common \
    ca-certificates \
    gnupg \
    wget \
    python3 \
    python3-pip

# #2 Install Intel GPU compute user-space drivers
#-----------------------
  RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
  gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | \
  tee /etc/apt/sources.list.d/intel-gpu-jammy.list
# apt update && \
#  apt install --no-install-recommends -q -y \
#    intel-opencl-icd intel-level-zero-gpu level-zero
# *Defect/Workaround*: Intel's apt repo does not contain the latest GPU runtime supporting kernel 6.8, so install the packages directly from their compute
# runtime repo
# https://github.com/intel/compute-runtime/issues/710
RUN apt update && \
 apt install --no-install-recommends -q -y \
   ocl-icd-libopencl1 \
   clinfo && \
 cd /tmp && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.16510.2/intel-igc-core_1.0.16510.2_amd64.deb && \
 wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.16510.2/intel-igc-opencl_1.0.16510.2_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/intel-level-zero-gpu_1.3.29138.7_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/intel-opencl-icd_24.13.29138.7_amd64.deb && \
 wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/libigdgmm12_22.3.18_amd64.deb && \
 dpkg -i *.deb && \
 apt install --no-install-recommends -q -y \
   level-zero 

# Required compute runtime level-zero variables
ENV ZES_ENABLE_SYSMAN=1

# #3 Install oneAPI 
#-----------------------
# *Defect/Workaround*: Intel's oneAPI MKL changed the linkage model, breaking pytorch wheel.  Downgrade to oneAPI 2024.0 instead
# Source: https://github.com/pytorch/pytorch/issues/123097
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
   gpg --dearmor --output /usr/share/keyrings/oneapi-archive-keyring.gpg && \
   echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
   tee /etc/apt/sources.list.d/oneAPI.list && \
  apt update && \
  apt install --no-install-recommends -q -y \
  intel-oneapi-common-vars=2024.0.0-49406 \
  intel-oneapi-common-oneapi-vars=2024.0.0-49406 \
  intel-oneapi-mkl=2024.0.0-49656 \
  intel-oneapi-tcm-1.0=1.0.0-435 \
  intel-oneapi-dnnl=2024.0.0-49521 

# Required oneAPI environment variables
ENV USE_XETLA=OFF
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
ENV SYCL_CACHE_PERSISTENT=1

COPY _init.sh /usr/share/lib/init_workspace.sh
COPY _run.sh /usr/share/lib/run_workspace.sh

# #3 Ollama specific dependencies
#-----------------------
RUN pip3 install --pre --upgrade ipex-llm[cpp] 

ENV OLLAMA_NUM_GPU=999
ENV OLLAMA_HOST 0.0.0.0:11434

ENTRYPOINT ["/bin/bash", "/usr/share/lib/run_workspace.sh"]

