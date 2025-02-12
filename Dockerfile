FROM intelanalytics/ipex-llm-inference-cpp-xpu:latest

RUN mkdir -p /llm/ollama; \
    cd /llm/ollama; \
    init-ollama;
WORKDIR /llm/ollama

COPY commands.sh /llm/ollama/commands.sh
RUN ["chmod", "+x", "/llm/ollama/commands.sh"]
ENTRYPOINT ["/llm/ollama/commands.sh"]
