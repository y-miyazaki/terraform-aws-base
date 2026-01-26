#--------------------------------------------------------------
# base build image
#--------------------------------------------------------------
FROM mcr.microsoft.com/vscode/devcontainers/go:1.25@sha256:ade3e38a521ce356bc5b2d55ed87b4c908e2a1b04fd921fc6b264dc5a9cdccc9
#--------------------------------------------------------------
# ARG
#--------------------------------------------------------------
# default
ARG USER=vscode
ARG WORKDIR=/workspace
# version(base)
ARG NODE_VERSION=24 # https://github.com/nodejs/node/releases
ARG AQUA_VERSION=v2.55.2 # https://github.com/aquaproj/aqua/releases

# x86_64
# ARG ARCH_BASE=amd64
# ARG ARCH_SESSION_MANAGER_PLUGIN=64bit

# arm64
ARG ARCH_BASE=arm64
ARG ARCH_SESSION_MANAGER_PLUGIN=arm64

#--------------------------------------------------------------
# ENV
#--------------------------------------------------------------
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOPATH=/go
# x_86_64
# ENV GOARCH=amd64
# arm_64
ENV GOARCH=arm64

#--------------------------------------------------------------
# workdir
#--------------------------------------------------------------
RUN mkdir -p ${WORKDIR}
WORKDIR  ${WORKDIR}

#--------------------------------------------------------------
# for docker group access
#--------------------------------------------------------------
RUN groupadd -f docker && sudo usermod -aG docker vscode

#--------------------------------------------------------------
# Install minimal apt/https tooling (avoid software-properties-common)
#--------------------------------------------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    dirmngr \
    apt-transport-https \
    lsb-release

#--------------------------------------------------------------
# Install dependent packages
#--------------------------------------------------------------
RUN apt update && \
    apt -y install make openssl git tar curl zip jq groff gcc bison python3 python3-dev python3-pip fish shellcheck shfmt bats

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -E - && \
    apt-get install -y nodejs=${NODE_VERSION}.0.0-1nodesource1

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
RUN pip3 install --break-system-packages aws-mfa==0.0.12 && \
    # Install awsp
    npm install -g --ignore-scripts awsp@0.2.0 && \
    # Install Session Manager Plugin
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${ARCH_SESSION_MANAGER_PLUGIN}/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    # TODO: Add checksum verification:
    # echo "EXPECTED_SHA256  session-manager-plugin.deb" | sha256sum -c - || exit 1
    dpkg -i session-manager-plugin.deb && \
    rm session-manager-plugin.deb

# Install awsdac
RUN apt update && \
    apt -y install fonts-liberation && \
    go install github.com/awslabs/diagram-as-code/cmd/awsdac@latest && \
    go install github.com/awslabs/diagram-as-code/cmd/awsdac-mcp-server@latest

RUN chown -R vscode:golang /go && \
    chmod -R g+w /go

#--------------------------------------------------------------
# Other tools
#--------------------------------------------------------------
RUN npm install -g --ignore-scripts @github/copilot@0.0.365

#--------------------------------------------------------------
# Clean up
#--------------------------------------------------------------
RUN rm -rf /tmp/tmp.* && \
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT []
CMD []
