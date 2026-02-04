#!/bin/bash

set -e

NODEJS_DIR="/workspace/nodejs"
OUTPUT_DIR="/workspace/lambda/outputs"

echo "Building Node.js Lambda functions..."

for dir in "$NODEJS_DIR"/*; do
    if [ -d "$dir" ]; then
        project_name=$(basename "$dir")
        echo "Building $project_name..."

        cd "$dir"

        # Clean and install dependencies (only if package.json exists)
        if [ -f "package.json" ]; then
            rm -rf node_modules package-lock.json
            npm install --omit=dev --silent
        else
            # For Synthetics projects, clean any root-level artifacts
            rm -rf node_modules package-lock.json
        fi

        # Create zip file
        # Check if this is a Synthetics Canary project (starts with synthetics_canary_)
        if [[ "$project_name" == synthetics_canary_* ]]; then
            # For Synthetics Canary projects (syn-nodejs-puppeteer-11.0+)
            # Package structure: index.js at root level
            echo "  Creating Synthetics Canary zip from root directory..."
            rm -f "$OUTPUT_DIR/nodejs_${project_name}.zip"
            zip -r "$OUTPUT_DIR/nodejs_${project_name}.zip" index.js -q
        else
            # For regular Lambda projects
            echo "  Creating zip from root directory..."
            rm -f "$OUTPUT_DIR/nodejs_${project_name}.zip"
            zip -r "$OUTPUT_DIR/nodejs_${project_name}.zip" . -x "test/*" "test-local.js" "package-lock.json" -q
        fi

        echo "✓ $project_name built successfully"
    fi
done

echo "All Node.js projects built successfully!"
