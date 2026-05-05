#!/bin/bash
# opendockercli.sh - NSFWFetch Docker CLI Terminal Access
# This script opens an interactive terminal session in the Docker container

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not installed. Please install docker-compose first."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_ROOT"

print_status "NSFWFetch Docker CLI Terminal Access"
print_status "======================================"

# Check if image exists, if not build it
if ! docker image inspect nsfwfetch:latest &> /dev/null; then
    print_status "Building Docker image... (first time only)"
    docker-compose build
    print_status "Docker image built successfully!"
else
    print_status "Using existing Docker image"
fi

# Create downloads directory if it doesn't exist
if [ ! -d "$PROJECT_ROOT/downloads" ]; then
    print_status "Creating downloads directory..."
    mkdir -p "$PROJECT_ROOT/downloads"
fi

print_status "Starting Docker container and opening terminal..."
print_status "Type 'exit' to close the terminal session"
echo ""

# Open interactive terminal
docker-compose run --rm nsfwfetch bash

print_status "Terminal session closed"
echo ""
