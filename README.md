# ollama-intel-gpu

This repo illlustrates the use of Ollama with support for Intel ARC GPU based via SYCL.  Run the recently released [Meta llama3.1](https://llama.meta.com/) or [Microsoft phi3](https://news.microsoft.com/source/features/ai/the-phi-3-small-language-models-with-big-potential) models on your local Intel ARC GPU based PC using Linux or Windows WSL2.

## Screenshot
![screenshot](doc/screenshot.png)

# Prerequisites
* Ubuntu 24.04 or newer (for Intel ARC GPU kernel driver support. Tested with Ubuntu 24.04), or Windows 11 with WSL2 (graphics driver [101.5445](https://www.intel.com/content/www/us/en/download/785597/intel-arc-iris-xe-graphics-windows.html) or newer)
* Installed Docker and Docker-compose tools (for Linux) or Docker Desktop (for Windows)
* Intel ARC series GPU (tested with Intel ARC A770 16GB and Intel(R) Core(TM) Ultra 5 125H integrated GPU)
 
# Usage

The following will build the Ollama with Intel ARC GPU support, and compose those with the public docker image based on OpenWEB UI from https://github.com/open-webui/open-webui

Linux:
```bash
$ git clone https://github.com/mattcurf/ollama-intel-gpu
$ cd ollama-intel-gpu
$ docker compose up 
```

Windows WSL2:
```bash
$ git clone https://github.com/mattcurf/ollama-intel-gpu
$ cd ollama-intel-gpu
$ docker-compose -f docker-compose-wsl2.yml up 
```

Then launch your web browser to http://localhost:3000 to launch the web ui.  Create a local OpenWeb UI credential, then click the settings icon in the top right of the screen, then select 'Models', then click 'Show', then download a model like 'llama3.1:8b-instruct-q8_0' for Intel ARC A770 16GB VRAM

# References
* https://github.com/ollama/ollama/issues/1590
* https://github.com/ollama/ollama/pull/3278
