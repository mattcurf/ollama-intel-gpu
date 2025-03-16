# ollama-intel-gpu

This repo illustrates the use of Ollama with support for Intel ARC GPU based via ipex-llm and Ollama Portable ZIP support.  Run the recently released [deepseek-r1](https://github.com/deepseek-ai/DeepSeek-R1) model on your local Intel ARC GPU based PC using Linux

## Important Note

All Ollama based ipex-llm defects should be reported directly to the ipex-llm project at https://github.com/intel/ipex-llm

## Screenshot
![screenshot](doc/screenshot.png)

# Prerequisites
* Ubuntu 24.04 or newer (for Intel ARC GPU kernel driver support. Tested with Ubuntu 24.04.02
* Installed Docker and Docker-compose tools
* Intel ARC series GPU (tested with Intel ARC A770 16GB and Intel(R) Core(TM) Ultra 5 125H integrated GPU)
 
# Usage

The following will build the Ollama with Intel ARC GPU support, and compose those with the public docker image based on OpenWEB UI from https://github.com/open-webui/open-webui

Linux:
```bash
$ git clone https://github.com/mattcurf/ollama-intel-gpu
$ cd ollama-intel-gpu
$ docker compose up 
```

*Note:* If you have multiple GPU's installed (like integrated and discrete), set the ONEAPI_DEVICE_DELECTOR environment variable in the docker compose file to select the intended device to use.

Then launch your web browser to http://localhost:3000 to launch the web ui.  Create a local OpenWeb UI credential, then click the settings icon in the top right of the screen, then select 'Models', then click 'Show', then download a model like 'llama3.1:8b-instruct-q8_0' for Intel ARC A770 16GB VRAM

## Update to the latest IPEX-LLM Portable Zip Version

To update to the latest portable zip version of IPEX-LLM's Ollama, update the compose file's `IPEXLLM_PORTABLE_ZIP_FILENAME` build argument to the latest `ollama-*.tgz` release from https://github.com/intel/ipex-llm/releases/tag/v2.2.0-nightly , then rebuild the image.

# References
* https://dgpu-docs.intel.com/driver/client/overview.html
* https://github.com/intel/ipex-llm/blob/main/docs/mddocs/Quickstart/ollama_portablze_zip_quickstart.md
