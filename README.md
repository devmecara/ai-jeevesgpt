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
- Once you have Docker Desktop installed, open it, go to Settings->Resources and make sure you are setting Memory (RAM) to at least 16 GB and Swap to at least 2 GB

- If you haven't already downloaded the git repo yet, Open a terminal and type in
## NOTE: Always type in the commands between ```bash and ``` lines ONLY

```bash
mkdir ai
cd ai
git clone https://github.com/gitphish/ai-jeevesgpt.git
cd ai-jeevesgpt
```

## Configuration

Copy the example file and fill in your values. Open a terminal and type in:
```bash
cp env-example .env
```

Generate a secure `WEBUI_SECRET_KEY`

- visit https://randomkeygen.com/jwt-secret and enter 'generate'
- OR open a terminal and type in (what's between the ```bash and ``` lines):

```bash
openssl rand -hex 32
```

Then edit `.env` directly by filling in the values below, other than the two MODEL names

```dotenv
PGADMIN_DEFAULT_EMAIL=you@example.com
PGADMIN_DEFAULT_PASSWORD=your-pgadmin-password
WEBUI_SECRET_KEY=your-secret-key
WEBUI_ADMIN_EMAIL=you@example.com
WEBUI_ADMIN_PASSWORD=your-webui-password
WEBUI_ADMIN_NAME=KishGPT
RAG_EMBEDDING_MODEL=nomic-embed-text:latest
BASE_MODEL=mistral-nemo
```

## Quick Start

Open a terminal and type in:

```bash
docker compose up --build
```

On first boot, the Ollama container will:
- Pull the embedding model (`RAG_EMBEDDING_MODEL`)
- Pull the base model (`BASE_MODEL`)
- Generate a Modelfile at `./volumes/generated/Modelfile.jeevesgpt` from the shared template (`Modelfile.template`)
- Create the `jeevesgpt` model in Ollama

## Services

- Open WebUI: http://localhost:3000
- Ollama API: http://localhost:11434
- PostgreSQL: localhost:5432
- pgAdmin: http://localhost:5050

## Creating the Model Manually

You can regenerate the `jeevesgpt` model without restarting containers. Open a terminal and type in (what's between the ``` lines):

```bash
./create-jeevesgpt-model.sh
```

This generates a local Modelfile at `./volumes/generated/Modelfile.jeevesgpt.local` from the shared template and rebuilds the Ollama model.

## Reset Everything

To wipe Open WebUI, Postgres, and pgAdmin data and start fresh, open a terminal and type in (what's between the ``` lines):

```bash
./reset.sh
```

Then bring the stack back up. Open a terminal and type in (what's between the ``` lines):

```bash
docker compose up --build -d
```

After changing any values, restart the stack. Open a terminal and type in (what's between the ``` lines):

```bash
docker compose down
docker compose up --build -d
```

## Updating the Custom Model Configuration

If you edit `jeeves-custom-model.json`, you need to copy it into the Open WebUI data volume so the container picks up the changes. Open a terminal and type in:

```bash
cp jeeves-custom-model.json volumes/open-webui/data/workspace-models.json
```

Then restart the stack:

```bash
docker compose down
docker compose up --build -d
```

## Customize the System Prompt

The system prompt is defined in [`Modelfile.template`](Modelfile.template) at the root of the project. This is the single source of truth used by both the container startup (`entrypoint.sh`) and the manual rebuild script (`create-jeevesgpt-model.sh`).

Edit the `SYSTEM """..."""` block in `Modelfile.template`, then either:
- Restart the stack: `docker compose down && docker compose up --build -d`
- Or hot-reload without restarting: `./create-jeevesgpt-model.sh`

The template supports these placeholders that are filled in at build time:
- `{{BASE_MODEL}}` — from `BASE_MODEL` in `.env`
- `{{ADMIN_NAME}}` — from `WEBUI_ADMIN_NAME` in `.env`
- `{{CURRENT_DATETIME}}` — auto-generated at model creation time

If you only want to change the name used in the prompt, set `WEBUI_ADMIN_NAME` in `.env` and restart.

## Troubleshooting

- If you get the following error "Cannot connect to the Docker daemon at unix:///Users/kkhemani/.docker/run/docker.sock. Is the docker daemon running?" make sure Docker is running
- If model pulls fail, verify Docker is running and your network allows access to model registries.
- If Open WebUI does not default to `jeevesgpt`, update the default model in the UI settings or recreate the account after a reset.
- Generated Modelfiles are stored in `./volumes/generated/` for inspection.