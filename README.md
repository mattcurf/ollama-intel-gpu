# ollama-intel-gpu

Using Ollama for Intel based GPUs is not as straight forward as other natively Ollama supported platforms.  As a workaround, this repo provides a quick sample showing the use of Ollama built with support for Intel ARC GPU based from the information provided by the references bellow.  Run the recently released [Meta llama3](https://llama.meta.com/llama3) or [Microsoft phi3](https://news.microsoft.com/source/features/ai/the-phi-3-small-language-models-with-big-potential) models on your local Intel ARC GPU based PC.

## Screenshot
![screenshot](doc/screenshot.png)

# Prerequisites
* Ubuntu 23.04 or newer (for Intel ARC GPU kernel driver support. Tested with Ubuntu 23.10)
* Installed Docker and Docker-compose tools
* Intel ARC series GPU (tested with Intel ARC A770 16GB)
 
# Usage

The following will build the Ollama with Intel ARC GPU support, and compose those with the public docker image based on OpenWEB UI from https://github.com/open-webui/open-webui

```bash
$ git clone https://github.com/mattcurf/ollama-intel-gpu
$ cd ollama-intel-gpu
$ docker-compose up 
```

Then launch your web browser to http://localhost:3000 to launch the web ui.  Create a local OpenWeb UI credential, then click the settings icon in the top right of the screen, then select 'Models', then click 'Show', then download a model like 'llama3:8b-instruct-q8_0' for Intel ARC A770 16GB VRAM

# Known issues
* It should be easy to adopt/refactor this for support on Windows WSL2, but this was not the target for this repo
* No effort has been made to prune the packages pulled into the Ollama docker image for Intel GPU

# References
* https://dgpu-docs.intel.com/driver/client/overview.html 
* https://ipex-llm.readthedocs.io/en/latest/doc/LLM/Quickstart/ollama_quickstart.html 
