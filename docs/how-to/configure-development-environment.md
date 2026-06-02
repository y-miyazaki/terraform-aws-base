<!-- omit in toc -->
# Terraform for Infrastructure

This repository contains [Terraform](https://developer.hashicorp.com/terraform) configurations for managing AWS infrastructure resources used in the project. It focuses on Infrastructure as Code (IaC) practices to ensure reproducible, version-controlled deployments.

The project is structured to manage multiple environments and components, including base infrastructure, management resources, and monitoring setups. It leverages reusable modules for AWS services such as IAM, KMS, CloudTrail, Security Hub, GuardDuty, CloudWatch, Lambda, S3, VPC, and more.

<!-- omit in toc -->
## Key Components

- **Base Infrastructure (`terraform/base/`)**  
  Manages core AWS resources essential for the project, including IAM roles and policies, KMS keys, CloudTrail for auditing, Security Hub for security compliance, GuardDuty for threat detection, Trusted Advisor recommendations, and resource groups for organization.
- **Management Resources (`terraform/management/`)**  
  Handles organizational-level configurations, divided into:
  - **Audit (`terraform/management/audit/`)**  
  - Focuses on security auditing tools like Chatbot for notifications, GuardDuty, and Security Hub.
  - **Root (`terraform/management/root/`)**
    Manages root-level resources such as budgets, Lambda functions, CloudTrail, and organizational policies.
- **Monitoring and Metrics (`terraform/monitor/`)**  
  Provides comprehensive monitoring solutions, including CloudWatch metrics and logs for various AWS services (e.g., EC2, RDS, Lambda, ELB (ALB/NLB), API Gateway, CloudFront, SES, SQS), Athena for query-based analytics, Synthetics Canary for endpoint monitoring, and EventBridge for event-driven automation.

<!-- omit in toc -->
## Table of Contents

- [Requirements](#requirements)
- [Directory Structure](#directory-structure)
- [Local development environment (devcontainer)](#local-development-environment-devcontainer)
  - [Setting](#setting)
  - [Create Local Development Environment](#create-local-development-environment)
- [Commands](#commands)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Getting Help](#getting-help)

## Requirements

- [Visual Studio Code](https://code.visualstudio.com/)
  - [Extension: Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker (choose one of the following options):
  - [Docker Desktop](https://www.docker.com/products/docker-desktop/) (recommended for Windows/macOS)
  - [Docker Engine](https://docs.docker.com/engine/) (for Linux)
  - [lima+](https://github.com/lima-vm/lima) (alternative for macOS/Linux, integrates with Docker)

## Directory Structure

| Directory/File          | Description                                                                                   |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| .github/                | GitHub Actions workflows and related configurations.                                          |
| .vscode/                | VS Code workspace settings and extensions.                                                    |
| env/                    | Contains environment-specific configurations and devcontainer settings for local development. |
| lambda/                 | Lambda function outputs and related files.                                                    |
| modules/                | Reusable Terraform modules for AWS services like EC2, S3, IAM, etc.                           |
| nodejs/                 | Node.js function outputs and related files.                                                   |
| scripts/                | Automation scripts for validation, deployment, and resource management.                       |
| terraform/              | Environment-specific Terraform configurations (e.g., application, base).                      |
| test/                   | Test configurations and resources.                                                            |
| .editorconfig           | Editor configuration for consistent coding styles.                                            |
| .gitignore              | Git ignore rules for the repository.                                                          |
| .gitleaks.toml          | Configuration for Gitleaks secret scanning.                                                   |
| .markdownlint.json      | Configuration for markdownlint.                                                               |
| .pre-commit-config.yaml | Configuration for pre-commit hooks.                                                           |
| .textlintrc.json        | Configuration for textlint.                                                                   |
| trivy-secret.yaml       | Configuration for Trivy secret scanning.                                                      |
| trivy.yaml              | Configuration for Trivy vulnerability scanning.                                               |

## Local development environment (devcontainer)

This section describes how to use a VS Code devcontainer to create a reproducible development environment. The devcontainer provides consistent tool versions and preconfigured mounts so contributors can work with the same development setup.

### Setting

Since there is a devcontainer setting in [env/example](../../env/example), modify this file and build the local environment.

### Create Local Development Environment

- Create devcontainer  

    ```bash
    mkdir -p .devcontainer
    mkdir -p env/common/tmp/.aws
    mkdir -p env/common/tmp/gh
    touch env/common/tmp/.gitconfig
    cp -p env/example/.devcontainer/devcontainer.json .devcontainer/devcontainer.json
    cp -p env/example/.aws/config env/common/tmp/.aws/config 
    ```

- Fix .aws/config  
    The following excerpt of code is a locally mounted file, so please change the mount settings according to your own environment.  
    You need to set up your AWS SSO configuration as shown below. Replace the `region` and `account_id` and `sso_start_url` and `sso_region` and `sso_account_id` and `sso_role_name` with your actual values.

    ```bash
    cat env/common/tmp/.aws/config
    ```

    ```
    [profile default]
    region = ap-northeast-1

    [profile dev]
    region = ap-northeast-1
    account_id = 123456789012
    sso_start_url = https://example.awsapps.com/start#/
    sso_region = ap-northeast-1
    sso_account_id = 123456789012
    sso_role_name = your sso role name

    [profile prd]
    region = ap-northeast-1
    account_id = 123456789012
    sso_start_url = https://example.awsapps.com/start#/
    sso_region = ap-northeast-1
    sso_account_id = 123456789012
    sso_role_name = your sso role name
    ```

- Fix .gitconfig  
    The following excerpt of code is a locally mounted file, so please change the mount settings according to your own environment.  
    you need to set up your git configuration like below. Please replace the user `name` and `email` with your own information.

    ```bash
    cat env/common/tmp/.gitconfig
    ```

    ```
    [user]
        name = Your Name
        email = your.email@example.com
    [init]
        defaultBranch = main
    [credential]
        helper = !gh auth git-credential
    [safe]
        directory = /workspace
    ```

- launch devcontainer from Visual Studio Code  
　  Open the command palette with `F1` or `Ctrl+Shift+P`, then
    `Dev Containers: Open folder in Container` or `Dev containers: Reopen in Container` or `Dev Containers: Rebuild Container`

- GitHub CLI login  
    After launching the devcontainer, run the following command to log in to [GitHub CLI](https://cli.github.com/).  
    If you have already logged in, you can skip this step.  
    If you are using 2FA, please set it up according to the instructions.  
    For more information, please refer to the official documentation: https://cli.github.com/manual/gh_auth_login

    ```bash
    gh auth login
    ```

- AWS SSO login  
    After launching the devcontainer, run the following command to log in to AWS SSO.  
    If you have already logged in, you can skip this step.  
    For more information, please refer to the official documentation: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

    ```bash
      vscode ➜ (no) ➜ /workspace (develop ✗) $ awsp
      AWS Profile Switcher
      ? Choose a profile dev

      The SSO session associated with this profile has expired or is otherwise invalid. To refresh this SSO session run aws sso login with the corresponding profile.    

      vscode ➜ dev ➜ /workspace (develop ✗) $ aws sso login
      Attempting to automatically open the SSO authorization page in your default browser.
      If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

      https://example.awsapps.com/start/#/device

      Then enter the code:

      ****-****
    ```

## Commands

  ```bash
  # e.g., environment dev, prd
  export ENV=<environment>

  # Initialize Terraform
  terraform init -reconfigure -backend-config=terraform.${ENV}.tfbackend

  # Validate configuration files
  terraform validate

  # Format configuration files
  terraform fmt --recursive

  # Generate and show an execution plan
  terraform plan -lock=false -var-file=terraform.${ENV}.tfvars

  # Apply changes required to reach the desired state of the configuration
  terraform apply -var-file=terraform.${ENV}.tfvars
  ```

## Troubleshooting

### Common Issues

- **Devcontainer fails to start**  
  Ensure Docker is running and you have sufficient permissions. Check the mount paths in `devcontainer.json` match your local directory structure.
- **AWS SSO login fails**  
  Verify your SSO configuration in `.aws/config`. Ensure the `sso_role_name` matches your assigned role. If the session expires, run `aws sso login` again.
- **GitHub CLI login issues**  
  If 2FA is enabled, follow the prompts to authenticate. Check your internet connection and GitHub access.
- **Terraform errors**  
  Run `terraform validate` to check syntax. Ensure your AWS credentials are correct and have the necessary permissions.

### Getting Help

If you encounter issues not covered here, check the GitHub Issues page or contact the development team.
