#!/bin/bash

# Script to create customized JeevesGPT model using BASE_MODEL from .env

# Load environment variables from .env
set -a
source .env
set +a

# Use BASE_MODEL from .env, default to mistral-nemo if not set
BASE_MODEL=${BASE_MODEL:-mistral-nemo}
# Use WEBUI_ADMIN_NAME from .env, default to JeevesGPT if not set
ADMIN_NAME=${WEBUI_ADMIN_NAME:-JeevesGPT}
CURRENT_DATETIME=""

if [ -x ./scripts/get-current-datetime.sh ]; then
	CURRENT_DATETIME=$(./scripts/get-current-datetime.sh)
else
	CURRENT_DATETIME=$(date "+%a %b %d %Y %I:%M:%S %p %Z")
fi

echo "Creating $ADMIN_NAME model based on: $BASE_MODEL"

# Create Modelfile in shared generated directory
MODELFILE_LOCAL="./volumes/generated/Modelfile.jeevesgpt.local"

cat > "$MODELFILE_LOCAL" << EOF
# Base model to customize
FROM $BASE_MODEL

# Custom system prompt
SYSTEM """You are a helpful AI bulter for $ADMIN_NAME. Your name is JeevesGPT. You are knowledgeable, professional, and courteous. Current datetime: $CURRENT_DATETIME."""

# Model parameters
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER num_ctx 32768

# Additional instructions
TEMPLATE """{{ if .System }}<|system|>
{{ .System }}</s>
{{ end }}{{ if .Prompt }}<|user|>
{{ .Prompt }}</s>
{{ end }}<|assistant|>
{{ .Response }}</s>
"""
EOF

echo "Generated Modelfile locally at: $MODELFILE_LOCAL"
cat "$MODELFILE_LOCAL"

# Copy to container and create model
echo ""
echo "Copying Modelfile to Ollama container..."
docker cp "$MODELFILE_LOCAL" jeevesgpt-ollama:/root/Modelfile.local

echo "Creating $ADMIN_NAME model in Ollama..."
docker exec jeevesgpt-ollama ollama create jeevesgpt -f /root/Modelfile.local

echo "$ADMIN_NAME model created successfully!"
echo ""
echo "Modelfile saved to: $MODELFILE_LOCAL"
echo "Test the model with:"
echo "  docker exec -it jeevesgpt-ollama ollama run jeevesgpt 'Hello, who are you?'"
