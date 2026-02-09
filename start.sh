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
mkdir -p volumes/ollama

echo "Pulling Ollama model: nomic-embed-text:latest..."
echo "This may take a few minutes on first run..."
docker run --rm -v "$(pwd)/volumes/ollama:/root/.ollama" ollama/ollama:latest ollama pull nomic-embed-text:latest

echo ""
echo "Model pull complete. Starting Docker containers with docker compose..."
echo ""
docker compose up
