FROM ubuntu:jammy

ENV TZ=america/los_angeles

# Install prerequisite packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends -q -y \
    apt-utils \
    software-properties-common \
    gnupg \
    wget \
    ocl-icd-libopencl1

# Install Intel GPU user-space driver apt repo 
#RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
#   gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
#   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | \
#   tee /etc/apt/sources.list.d/intel-gpu-jammy.list
# Note: Intel's apt repo does not contain the latest GPU runtime supporting kernel 6.8, so install the packages directly from their compute
# runtime repo
RUN cd /tmp && \
  wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.16510.2/intel-igc-core_1.0.16510.2_amd64.deb && \
  wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.16510.2/intel-igc-opencl_1.0.16510.2_amd64.deb && \
  wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/intel-level-zero-gpu_1.3.29138.7_amd64.deb && \
  wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/intel-opencl-icd_24.13.29138.7_amd64.deb && \
  wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/libigdgmm12_22.3.18_amd64.deb && \
  dpkg -i *.deb

# Install oneAPI apt repo
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
   gpg --dearmor --output /usr/share/keyrings/oneapi-archive-keyring.gpg && \ 
   echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
   tee /etc/apt/sources.list.d/oneAPI.list

# Install Conda apt repo
RUN wget -qO - https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | \
   gpg --dearmor --output /usr/share/keyrings/conda-archive-keyring.gpg && \
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/conda-archive-keyring.gpg] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | \
   tee /etc/apt/sources.list.d/conda.list 

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install --no-install-recommends -q -y \
    intel-basekit=2024.0.1-43 \
    conda

ENV USE_XETLA=OFF
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
ENV SYCL_CACHE_PERSISTENT=1
ENV ZES_ENABLE_SYSMAN=1
ENV OLLAMA_NUM_GPU=999
ENV OLLAMA_HOST 0.0.0.0:11434

COPY _init.sh /usr/share/lib/init_workspace.sh
COPY _run.sh /usr/share/lib/run_workspace.sh

RUN /bin/bash -c "source /usr/share/lib/init_workspace.sh && \
   conda create -n llm-cpp python=3.11 && \
   conda activate llm-cpp && \ 
   pip install --pre --upgrade ipex-llm[cpp] && \
   mkdir /workspace && \
   cd /workspace && \
   init-llama-cpp && \
   init-ollama" 

ENTRYPOINT ["/bin/bash", "/usr/share/lib/run_workspace.sh"]

