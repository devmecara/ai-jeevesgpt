# ai-jeevesgpt
A local, Docker-based AI stack using Open WebUI, Ollama, PostgreSQL, and pgAdmin. It includes a custom model named `jeevesgpt` that is built automatically on startup from a generated Modelfile.

## What You Get

- Open WebUI for chat UI and model management
- Ollama for local model inference
- PostgreSQL for Open WebUI persistence
- pgAdmin for database administration
- Automated creation of a custom `jeevesgpt` model

## Prerequisites

- Docker Desktop (or Docker Engine + Compose)
- Internet access to pull Ollama models the first time

## Quick Start

### macOS / Linux

```bash
./start.sh
```

### Windows

```cmd
start.bat
```

Both scripts will:
1. Check if Docker is running
2. Create needed volume folders
3. Pull the embedding model
4. Start all services with `docker compose up`

## Manual Startup

```bash
docker compose up -d
```

On first boot, the Ollama container will:
- Pull the embedding model (`RAG_EMBEDDING_MODEL`)
- Pull the base model (`BASE_MODEL`)
- Generate a Modelfile at `./volumes/generated/Modelfile.jeevesgpt`
- Create the `jeevesgpt` model in Ollama

## Configuration

Edit the [ .env ](./.env) file to change models and settings:

```dotenv
RAG_EMBEDDING_MODEL=nomic-embed-text:latest
BASE_MODEL=mistral-nemo
WEBUI_ADMIN_NAME=Kish
```

To generate or update secrets used by the stack, run:

```bash
./scripts/configure-secrets.sh
```

This script writes secure values into `.env` (for example `WEBUI_SECRET_KEY`). Re-run it after a reset or whenever you want to rotate secrets.

If you add new values, restart the stack:

```bash
docker compose down
docker compose up -d
```

## Services

- Open WebUI: http://localhost:3000
- Ollama API: http://localhost:11434
- PostgreSQL: localhost:5432
- pgAdmin: http://localhost:5050

## Creating the Model Manually

You can regenerate the `jeevesgpt` model without restarting containers:

```bash
./create-jeevesgpt-model.sh
```

This generates a local Modelfile at `./volumes/generated/Modelfile.jeevesgpt.local` and rebuilds the Ollama model.

## Reset Everything

To wipe Open WebUI, Postgres, and pgAdmin data and start fresh:

```bash
./reset.sh
```

Then bring the stack back up:

```bash
docker compose up -d
```

## Troubleshooting

- If model pulls fail, verify Docker is running and your network allows access to model registries.
- If Open WebUI does not default to `jeevesgpt`, update the default model in the UI settings or recreate the account after a reset.
- Generated Modelfiles are stored in `./volumes/generated/` for inspection.