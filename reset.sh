#!/bin/bash

# Reset script for JeevesGPT - removes containers and clears user data volumes

echo "Stopping and removing containers..."
docker compose down

echo "Removing volume directories..."
rm -rf ./volumes/postgres/data
rm -rf ./volumes/pgadmin
rm -rf ./volumes/open-webui

echo "Reset complete. You can now run 'docker compose up -d' to start fresh."
