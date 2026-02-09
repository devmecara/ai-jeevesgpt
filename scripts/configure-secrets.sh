#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo ".env not found at $ENV_FILE" >&2
  exit 1
fi

# Prompt for values
read -r -p "PGADMIN_DEFAULT_EMAIL: " PGADMIN_DEFAULT_EMAIL
read -r -s -p "PGADMIN_DEFAULT_PASSWORD: " PGADMIN_DEFAULT_PASSWORD
printf "\n"

read -r -p "WEBUI_ADMIN_EMAIL: " WEBUI_ADMIN_EMAIL
read -r -s -p "WEBUI_ADMIN_PASSWORD: " WEBUI_ADMIN_PASSWORD
printf "\n"

read -r -p "WEBUI_ADMIN_NAME: " WEBUI_ADMIN_NAME

# Generate new WEBUI_SECRET_KEY
if command -v openssl >/dev/null 2>&1; then
  WEBUI_SECRET_KEY="$(openssl rand -hex 32)"
else
  WEBUI_SECRET_KEY="$(python3 - <<'PY'
import secrets
print(secrets.token_hex(32))
PY
)"
fi

# Export variables before Python script
export PGADMIN_DEFAULT_EMAIL="$PGADMIN_DEFAULT_EMAIL"
export PGADMIN_DEFAULT_PASSWORD="$PGADMIN_DEFAULT_PASSWORD"
export WEBUI_ADMIN_EMAIL="$WEBUI_ADMIN_EMAIL"
export WEBUI_ADMIN_PASSWORD="$WEBUI_ADMIN_PASSWORD"
export WEBUI_ADMIN_NAME="$WEBUI_ADMIN_NAME"
export WEBUI_SECRET_KEY="$WEBUI_SECRET_KEY"
export ENV_FILE="$ENV_FILE"

# Update .env file with values that were provided (non-empty)
python3 << 'EOF'
from pathlib import Path
import re
import os

env_path = Path(os.environ["ENV_FILE"])
text = env_path.read_text()

# Only update fields that have values
updates = []
if os.environ.get("PGADMIN_DEFAULT_EMAIL"):
  updates.append(("PGADMIN_DEFAULT_EMAIL", os.environ["PGADMIN_DEFAULT_EMAIL"]))
if os.environ.get("PGADMIN_DEFAULT_PASSWORD"):
  updates.append(("PGADMIN_DEFAULT_PASSWORD", os.environ["PGADMIN_DEFAULT_PASSWORD"]))
if os.environ.get("WEBUI_ADMIN_EMAIL"):
  updates.append(("WEBUI_ADMIN_EMAIL", os.environ["WEBUI_ADMIN_EMAIL"]))
if os.environ.get("WEBUI_ADMIN_PASSWORD"):
  updates.append(("WEBUI_ADMIN_PASSWORD", os.environ["WEBUI_ADMIN_PASSWORD"]))
if os.environ.get("WEBUI_ADMIN_NAME"):
  updates.append(("WEBUI_ADMIN_NAME", os.environ["WEBUI_ADMIN_NAME"]))

# Always update WEBUI_SECRET_KEY
updates.append(("WEBUI_SECRET_KEY", os.environ["WEBUI_SECRET_KEY"]))

def set_key(key: str, value: str, content: str) -> str:
  pattern = re.compile(rf"^(\s*{re.escape(key)}=).*$", re.M)
  if pattern.search(content):
    return pattern.sub(lambda m: m.group(1) + value, content)
  return content.rstrip("\n") + f"\n{key}={value}\n"

for k, v in updates:
  text = set_key(k, v, text)

backup_path = env_path.with_suffix(env_path.suffix + ".bak")
backup_path.write_text(env_path.read_text())
env_path.write_text(text)

print("Updated .env and wrote backup to", backup_path)
EOF

printf "\nGenerated WEBUI_SECRET_KEY: %s\n" "$WEBUI_SECRET_KEY"
