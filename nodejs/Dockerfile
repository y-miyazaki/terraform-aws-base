# trivy:ignore:AVD-DS-0026
# Pinned to digest for repeatable builds
FROM node:22-slim@sha256:813a7480f28fdadac1f7f5c824bcdad435b5bc1322a5968bbbdef8d058f9dff4

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
