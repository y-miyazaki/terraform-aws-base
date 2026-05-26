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
ARG MISE_VERSION=v2026.5.15 # https://github.com/jdx/mise/releases

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

# Install mise to a system-wide path so remoteUser=vscode can always resolve it
RUN curl -fsSL https://mise.run | MISE_VERSION=${MISE_VERSION} MISE_INSTALL_PATH=/usr/local/bin/mise sh && \
    /usr/local/bin/mise --version

#--------------------------------------------------------------
# AWS environment
#--------------------------------------------------------------
# Install Session Manager Plugin: choose package path by TARGETARCH
RUN if [ "${TARGETARCH}" = "arm64" ] || [ "${TARGETARCH}" = "aarch64" ]; then \
    SSM_ARCH=arm64; \
    else \
    # AWS uses '64bit' in the URL path for x86_64 packages
    SSM_ARCH=64bit; \
    fi && \
    curl -fsSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${SSM_ARCH}/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    rm session-manager-plugin.deb

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
