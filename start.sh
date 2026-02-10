#!/bin/bash

set -e

echo "Starting JeevesGPT..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create volumes directory if it doesn't exist
mkdir -p volumes/ollama_data

# Load model settings from .env if available
if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    source .env
    set +a
fi

RAG_EMBEDDING_MODEL=${RAG_EMBEDDING_MODEL:-nomic-embed-text:latest}
BASE_MODEL=${BASE_MODEL:-mistral-nemo}

echo "Pulling Ollama embedding model: $RAG_EMBEDDING_MODEL..."
echo "This may take a few minutes on first run..."
docker run --rm -v "$(pwd)/volumes/ollama_data:/root/.ollama" ollama/ollama:latest ollama pull "$RAG_EMBEDDING_MODEL"

echo "Pulling Ollama base model: $BASE_MODEL..."
docker run --rm -v "$(pwd)/volumes/ollama_data:/root/.ollama" ollama/ollama:latest ollama pull "$BASE_MODEL"

echo ""
echo "Model pull complete. Starting Docker containers with docker compose..."
echo ""
docker compose up
