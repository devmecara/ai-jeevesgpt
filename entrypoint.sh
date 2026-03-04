#!/bin/bash

# Script to initialize Ollama with required models before running the RAG test
# Configuration from environment variables with defaults

RAG_EMBEDDING_MODEL=${RAG_EMBEDDING_MODEL:-nomic-embed-text}
BASE_MODEL=${BASE_MODEL:-mistral-nemo}
WEBUI_ADMIN_NAME=${WEBUI_ADMIN_NAME:-JeevesGPT}
CURRENT_DATETIME=""

if [ -x /scripts/get-current-datetime.sh ]; then
  CURRENT_DATETIME=$(/scripts/get-current-datetime.sh)
else
  CURRENT_DATETIME=$(date "+%a %b %d %Y %I:%M:%S %p %Z")
fi

ollama serve &

# Wait for server to start using the built-in ollama tool
until ollama list > /dev/null 2>&1; do
  echo "Waiting for Ollama server to start..."
  sleep 2
done

echo "Pulling embedding model: $RAG_EMBEDDING_MODEL"
ollama pull $RAG_EMBEDDING_MODEL
echo "Pulling base model: $BASE_MODEL"
ollama pull $BASE_MODEL

# Create custom model from shared Modelfile template
echo "Creating custom $WEBUI_ADMIN_NAME model based on $BASE_MODEL..."
TEMPLATE_PATH="/Modelfile.template"
MODELFILE_PATH="/generated/Modelfile.jeevesgpt"

sed -e "s|{{BASE_MODEL}}|$BASE_MODEL|g" \
    -e "s|{{ADMIN_NAME}}|$WEBUI_ADMIN_NAME|g" \
    -e "s|{{CURRENT_DATETIME}}|$CURRENT_DATETIME|g" \
    "$TEMPLATE_PATH" > "$MODELFILE_PATH"

echo "Modelfile saved to: $MODELFILE_PATH"
ollama create jeevesgpt -f "$MODELFILE_PATH"

# Create a marker file for the health check to find
touch /tmp/ollama_ready
wait
