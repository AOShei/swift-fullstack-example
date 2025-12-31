#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

echo "📦 Resolving Dependencies..."
# Removes the build folder if it's in a bad state (optional, but safer)
# rm -rf .build
swift package resolve

echo "------------------------------------------------"
echo "🛠️  Building Backend (Vapor)..."
echo "   (Using --jobs 1 to save memory)"
echo "------------------------------------------------"
# We build the Backend explicitly to avoid building Frontend artifacts here
swift build --product Backend --jobs 1

echo "------------------------------------------------"
echo "🎨 Building Frontend (Tokamak/Wasm)..."
echo "------------------------------------------------"
# Carton handles the Wasm cross-compilation
carton bundle --product Frontend

echo "------------------------------------------------"
echo "✅ Project Built Successfully!"
echo "   - Run './run_backend.sh' to start the API"
echo "   - Run './run_frontend.sh' to start the Web Server"
echo "------------------------------------------------"