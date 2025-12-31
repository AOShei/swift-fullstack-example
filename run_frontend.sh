#!/bin/bash

echo "🌍 Starting Frontend Dev Server on Port 8081..."
echo "   (Open the 'Ports' tab to view the site)"

# We use port 8081 because the Backend occupies 8080
# Added: --custom-index-page to use our fixed HTML file
carton dev --product Frontend --port 8081 --custom-index-page index.html