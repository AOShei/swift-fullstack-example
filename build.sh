#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

echo "📦 Resolving Dependencies..."
swift package resolve

echo "------------------------------------------------"
echo "🛠️  Building Backend (Vapor + Leaf Templates)..."
echo "   (Using --jobs 1 to save memory)"
echo "------------------------------------------------"
# Build the Backend with server-side rendering
swift build --product Backend --jobs 1

echo "------------------------------------------------"
echo "✅ Project Built Successfully!"
echo "   - Run './run_backend.sh' to start the server"
echo "   - Open http://localhost:8080 in your browser"
echo "------------------------------------------------"