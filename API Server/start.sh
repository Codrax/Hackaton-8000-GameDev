#!/bin/bash

# Go to the script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Create venv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Setting up Python virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install llama-cpp-python fastapi uvicorn
else
    echo "Using existing virtual environment..."
    source venv/bin/activate
fi

# Start server
python main.py
