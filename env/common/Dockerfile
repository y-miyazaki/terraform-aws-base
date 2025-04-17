#--------------------------------------------------------------
# base build image
#--------------------------------------------------------------
FROM mcr.microsoft.com/vscode/devcontainers/go:1.20
#--------------------------------------------------------------
# ARG
#--------------------------------------------------------------
ARG USER=vscode
ARG WORKDIR=/workspace
ARG TERRAFORM_DOCS_VERSION=0.16.0
ARG TRIVY_VERSION=0.59.1
ARG SOPS_VERSION=3.7.3
ARG GH_VERSION=2.21.1
ARG GITLEAKS_VERSION=8.18.0

# x86_64
ARG ARCH_BASE=amd64
ARG ARCH_GITLEAKS=x64
ARG ARCH_AWS_CLI=x86_64
ARG ARCH_SESSION_MANAGER_PLUGIN=64bit
ARG ARCH_TRIVY=64bit

# arm64
# ARG ARCH_BASE=arm64
# ARG ARCH_GITLEAKS=arm64
# ARG ARCH_AWS_CLI=aarch64
# ARG ARCH_SESSION_MANAGER_PLUGIN=arm64
# ARG ARCH_TRIVY=ARM

ENV TFLINT_VERSION=v0.45.0
ENV GO111MODULE=on

#--------------------------------------------------------------
# workdir
#--------------------------------------------------------------
RUN mkdir -p ${WORKDIR}
WORKDIR  ${WORKDIR}

#--------------------------------------------------------------
# Install software-properties-common
#--------------------------------------------------------------
RUN sudo apt update && \
    sudo apt -y install software-properties-common

#--------------------------------------------------------------
# Install dependent packages
#--------------------------------------------------------------
RUN sudo apt update && \
    apt -y install make openssl git tar curl zip jq groff gcc npm bison python3 python3-dev python3-pip
# Install docker
# curl -fsSL https://get.docker.com -o get-docker.sh && \
# sh ./get-docker.sh && \
# rm -f get-docker.sh && \
# Install pre-commit
RUN pip3 install pre-commit --break-system-packages --ignore-installed distlib

# Install gitleaks
RUN curl -sLO https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS}.tar.gz && \
    mkdir -p ./gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS} && \
    tar -zxvf gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS}.tar.gz -C ./gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS} && \
    chmod +x ./gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS}/gitleaks && \
    mv ./gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS}/gitleaks /usr/local/bin/gitleaks && \
    rm -rf gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS}.tar.gz ./gitleaks_${GITLEAKS_VERSION}_linux_${ARCH_GITLEAKS} && \
    # Install tfenv
    git clone https://github.com/kamatama41/tfenv.git /home/${USER}/.tfenv && \
    chown -R ${USER} /home/${USER}/.tfenv && \
    chgrp -R ${USER} /home/${USER}/.tfenv && \
    ln -s /home/${USER}/.tfenv/bin/* /usr/local/bin && \
    # Install tflint
    curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash && \
    # Install trivy
    wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${ARCH_TRIVY}.deb && \
    dpkg -i trivy_${TRIVY_VERSION}_Linux-${ARCH_TRIVY}.deb && \
    # Install terraform-docs
    curl -OL https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH_BASE}.tar.gz && \
    mkdir terraform-docs && \
    tar -zxvf terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH_BASE}.tar.gz -C ./terraform-docs && \
    mv terraform-docs/terraform-docs /usr/local/bin/terraform-docs && \
    chmod +x /usr/local/bin/terraform-docs && \
    rm -rf terraform-docs* && \
    # Install sops
    go install go.mozilla.org/sops/v3/cmd/sops@v3.7.3

#--------------------------------------------------------------
# gh
#--------------------------------------------------------------
RUN wget https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH_BASE}.tar.gz && \
    tar -xvf gh_${GH_VERSION}_linux_${ARCH_BASE}.tar.gz && \
    sudo cp -riv gh_${GH_VERSION}_linux_${ARCH_BASE} /usr/local/bin/ && \
    echo 'export PATH="/usr/local/bin/gh_${GH_VERSION}_linux_${ARCH_BASE}/bin:$PATH"' >> /home/${USER}/.bashrc && \
    rm -rf gh_${GH_VERSION}_linux_${ARCH_BASE}.tar.gz gh_${GH_VERSION}_linux_${ARCH_BASE}

#--------------------------------------------------------------
# AWS environment
#--------------------------------------------------------------
# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH_AWS_CLI}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -rf awscliv2.zip
# Install aws-mfa
RUN  pip3 install --break-system-packages aws-mfa && \
    # Install awsp
    npm install -g awsp && \
    echo 'alias awsp="source _awsp"' >> /home/${USER}/.bashrc && \
    # Install aws-sam-cli
    # curl -sSOL https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip && \
    # unzip aws-sam-cli-linux-x86_64.zip -d sam-installation && \
    # ./sam-installation/install && \
    # Install Session Manager Plugin
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${ARCH_SESSION_MANAGER_PLUGIN}/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    sudo dpkg -i session-manager-plugin.deb

# Clean up
RUN rm -rf /tmp/tmp.* && \
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT []
CMD []
