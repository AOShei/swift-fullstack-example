#!/bin/bash

echo "🚀 Starting Backend Server on Port 8080..."
echo "   (Press Ctrl+C to stop)"

# We use --skip-build because we assume 'build.sh' was run, 
# or that we want a fast restart if the binary exists.
swift run --skip-build Backend