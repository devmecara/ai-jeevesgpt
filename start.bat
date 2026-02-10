@echo off
setlocal enabledelayedexpansion

echo Starting JeevesGPT...
echo.

REM Check if Docker is running
docker info > nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running. Please start Docker and try again.
    exit /b 1
)

REM Create volumes directory if it doesn't exist
if not exist "volumes\ollama_data" mkdir "volumes\ollama_data"

REM Load model settings from .env if available
if exist ".env" (
    for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
        set "%%A=%%B"
    )
)

if not defined RAG_EMBEDDING_MODEL set "RAG_EMBEDDING_MODEL=nomic-embed-text:latest"
if not defined BASE_MODEL set "BASE_MODEL=mistral-nemo"

echo Pulling Ollama embedding model: %RAG_EMBEDDING_MODEL%...
echo This may take a few minutes on first run...
for /f %%i in ('cd') do set "WORKDIR=%%i"
docker run --rm -v "%WORKDIR%\volumes\ollama_data:/root/.ollama" ollama/ollama:latest ollama pull %RAG_EMBEDDING_MODEL%

echo Pulling Ollama base model: %BASE_MODEL%...
docker run --rm -v "%WORKDIR%\volumes\ollama_data:/root/.ollama" ollama/ollama:latest ollama pull %BASE_MODEL%

echo.
echo Model pull complete. Starting Docker containers with docker compose...
echo.
docker compose up

endlocal
