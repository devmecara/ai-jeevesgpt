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

# Generate Modelfile from shared template
TEMPLATE_FILE="./Modelfile.template"
MODELFILE_LOCAL="./volumes/generated/Modelfile.jeevesgpt.local"

sed -e "s|{{BASE_MODEL}}|$BASE_MODEL|g" \
    -e "s|{{ADMIN_NAME}}|$ADMIN_NAME|g" \
    -e "s|{{CURRENT_DATETIME}}|$CURRENT_DATETIME|g" \
    "$TEMPLATE_FILE" > "$MODELFILE_LOCAL"

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
