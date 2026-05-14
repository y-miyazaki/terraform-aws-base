#--------------------------------------------------------------
# base build image
#--------------------------------------------------------------
FROM mcr.microsoft.com/devcontainers/go:1.26@sha256:15829949b820e069ad968036f5fd645402965c32f690a9dddb72788a75af8f35
#--------------------------------------------------------------
# ARG
#--------------------------------------------------------------
# default
ARG TARGETARCH
ARG USER=vscode
ARG WORKDIR=/workspace

# version(base)
ARG AQUA_VERSION=v2.58.1 # https://github.com/aquaproj/aqua/releases
ARG AWSDAC_VERSION=v0.22.4 # https://github.com/awslabs/diagram-as-code/releases
ARG AWSP_VERSION=0.2.0 # https://www.npmjs.com/package/awsp
ARG AWS_MFA_VERSION=0.0.12 # https://pypi.org/project/aws-mfa/
ARG NODE_VERSION=24 # https://github.com/nodejs/node/releases

#--------------------------------------------------------------
# ENV
#--------------------------------------------------------------
# go
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOPATH=/go
ENV GOARCH=${TARGETARCH}

#--------------------------------------------------------------
# workdir
#--------------------------------------------------------------
RUN mkdir -p ${WORKDIR}
WORKDIR  ${WORKDIR}

#--------------------------------------------------------------
# for docker group access
#--------------------------------------------------------------
RUN groupadd -f docker && usermod -aG docker vscode

#--------------------------------------------------------------
# Install minimal apt/https tooling (avoid software-properties-common)
#--------------------------------------------------------------
# Remove problematic Yarn repository first
RUN rm -f /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    dirmngr \
    lsb-release

#--------------------------------------------------------------
# Install dependent packages
#--------------------------------------------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    make openssl git tar curl zip jq groff gcc bison python3 python3-dev python3-pip fish shellcheck shfmt bats yamllint

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nodejs

# Install npm packages
RUN npm install -g --ignore-scripts \
    markdownlint-cli@0.46.0 \
    markdown-link-check@3.14.2 \
    cspell@9.3.2 \
    textlint@15.4.0 \
    textlint-rule-preset-ja-technical-writing@12.0.2 \
    textlint-rule-no-dead-link@6.0.1

# Install aqua
RUN go install github.com/aquaproj/aqua/v2/cmd/aqua@${AQUA_VERSION}

#--------------------------------------------------------------
# Install for MCP Server
#--------------------------------------------------------------
# Install for vscode user
USER ${USER}
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Switch back to root for remaining operations
USER root

#--------------------------------------------------------------
# AWS environment
#--------------------------------------------------------------
# Install aws-mfa
# aws-mfa requires system-wide install in devcontainer
RUN pip3 install --break-system-packages aws-mfa==${AWS_MFA_VERSION} && \
    # Install awsp
    npm install -g --ignore-scripts awsp@${AWSP_VERSION} && \
    # Install Session Manager Plugin: choose package path by TARGETARCH
    if [ "${TARGETARCH}" = "arm64" ] || [ "${TARGETARCH}" = "aarch64" ]; then \
    SSM_ARCH=arm64; \
    else \
    # AWS uses '64bit' in the URL path for x86_64 packages
    SSM_ARCH=64bit; \
    fi && \
    curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${SSM_ARCH}/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    rm session-manager-plugin.deb

# Install awsdac
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    fonts-liberation && \
    go install github.com/awslabs/diagram-as-code/cmd/awsdac@${AWSDAC_VERSION} && \
    go install github.com/awslabs/diagram-as-code/cmd/awsdac-mcp-server@${AWSDAC_VERSION}

#--------------------------------------------------------------
# Fixed go owner
#--------------------------------------------------------------
RUN chown -R vscode:vscode /go

#--------------------------------------------------------------
# Clean up
#--------------------------------------------------------------
RUN rm -rf /tmp/tmp.* && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT []
CMD []
