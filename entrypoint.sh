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

# Create custom model from Modelfile with dynamic substitution
echo "Creating custom $WEBUI_ADMIN_NAME model based on $BASE_MODEL..."
MODELFILE_PATH="/generated/Modelfile.jeevesgpt"
cat > "$MODELFILE_PATH" << EOF
# Base model to customize
FROM $BASE_MODEL

# Custom system prompt
SYSTEM """You are JeevesGPT, a helpful AI assistant for $WEBUI_ADMIN_NAME. You are knowledgeable, professional, and courteous. Current datetime: $CURRENT_DATETIME."""

# Model parameters
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER num_ctx 4096

# Additional instructions
TEMPLATE """{{ if .System }}<|system|>
{{ .System }}</s>
{{ end }}{{ if .Prompt }}<|user|>
{{ .Prompt }}</s>
{{ end }}<|assistant|>
{{ .Response }}</s>
"""
EOF

echo "Modelfile saved to: $MODELFILE_PATH"
ollama create jeevesgpt -f "$MODELFILE_PATH"

# Create a marker file for the health check to find
touch /tmp/ollama_ready
wait
