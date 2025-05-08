#!/bin/bash

# Allow specifying the module to test via argument
# If no argument is provided, use kinesis_data_firehose_cloudwatch_logs_processor as default
MODULE_NAME=${1:-"kinesis_data_firehose_cloudwatch_logs_processor"}

# Function to display usage instructions
show_usage() {
  echo "Usage: $0 [module_name]"
  echo "Available modules:"
  echo "  - kinesis_data_firehose_cloudwatch_logs_processor (default)"
  echo "  - s3_notification_s3_object_created_for_athena"
}

# Show help
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  show_usage
  exit 0
fi

# Check if module exists
if [ ! -d "/workspace/nodejs/${MODULE_NAME}" ]; then
  echo "Error: Module '${MODULE_NAME}' not found"
  echo ""
  show_usage
  exit 1
fi

echo "Running tests for module '${MODULE_NAME}'..."

# Change to nodejs directory
cd /workspace/nodejs

# Set image name based on module name
IMAGE_NAME="${MODULE_NAME}-test"

# Build image using the common Dockerfile
echo "Building Docker image '${IMAGE_NAME}'..."
docker build -t ${IMAGE_NAME} --build-arg MODULE_NAME=${MODULE_NAME} .

# Run tests
echo "Running tests..."
docker run --rm ${IMAGE_NAME}

# Save exit code
TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo "Tests completed successfully"
else
  echo "Tests failed (exit code: $TEST_EXIT_CODE)"
fi

exit $TEST_EXIT_CODE
