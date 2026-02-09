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
if not exist "volumes\ollama" mkdir "volumes\ollama"

echo Pulling Ollama model: nomic-embed-text:latest...
echo This may take a few minutes on first run...
for /f %%i in ('cd') do set "WORKDIR=%%i"
docker run --rm -v "%WORKDIR%\volumes\ollama:/root/.ollama" ollama/ollama:latest ollama pull nomic-embed-text:latest

echo.
echo Model pull complete. Starting Docker containers with docker compose...
echo.
docker compose up

endlocal
