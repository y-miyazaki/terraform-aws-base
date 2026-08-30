# trivy:ignore:AVD-DS-0026
# Pinned to digest for repeatable builds
FROM node:24-slim@sha256:ba849c60be29959425b8734d57b8b4b7d56f98edd9504c9af091d5281095a71e

WORKDIR /app

# Accept module name as command line argument
ARG MODULE_NAME

# Copy necessary files (maintain directory structure)
COPY ${MODULE_NAME}/package.json ./
COPY ${MODULE_NAME}/index.mjs ./
COPY ${MODULE_NAME}/test-local.js ./
COPY ${MODULE_NAME}/test/ ./test/

# Install dependencies
RUN npm install --ignore-scripts

# Create non-root user for security
RUN groupadd -r nodeuser && useradd -r -g nodeuser nodeuser
RUN chown -R nodeuser:nodeuser /app
USER nodeuser

# Don't hardcode the module name
ENV MODULE_NAME=${MODULE_NAME}

# Set entrypoint and allow specifying test script via command line arguments
ENTRYPOINT ["node"]
CMD ["test-local.js"]
