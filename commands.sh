#!/bin/bash
source ipex-llm-init --gpu --device $DEVICE
export OLLAMA_HOST=0.0.0.0:11434
cd /llm/ollama
./ollama serve
