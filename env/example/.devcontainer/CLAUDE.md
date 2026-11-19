# CLAUDE.md

## Devcontainer security (MUST)

Applies to `.devcontainer/devcontainer.json` and `env/example/.devcontainer/{vscode,cursor}/devcontainer.json`. Copy the example for your editor to `.devcontainer/devcontainer.json` as is: paths such as `dockerFile` are written relative to `.devcontainer/`. Opening a devcontainer runs its commands and mounts with the developer's host privileges, so a change here is a security change.

- **DooD is the accepted baseline.** The `docker-outside-of-docker` feature is intentional because scripts here call `docker build` / `docker run`. It exposes the host Docker socket, which is effectively host root, so open only trusted repositories and branches in this devcontainer.
- **Do not add further host access** without explicit user approval: `privileged`, `--cap-add`, `--security-opt`, `--net=host` / `--pid=host`, a direct `docker.sock` mount, or bind mounts of host paths outside the workspace and `env/common/tmp/`.
- **Pin what runs on open:** image by digest, extensions and features by version. The VS Code and Cursor examples differ only in `customizations.vscode.extensions`: VS Code installs from the Visual Studio Marketplace and Cursor from Open VSX, so the Cursor example pins Open VSX versions and omits extensions not published there. Change every other key in both files together; update the pins with `scripts/editor/pin_vscode_extensions.sh` (default: the VS Code example) and `scripts/editor/pin_vscode_extensions.sh --registry openvsx` (the Cursor example); never run it for one example with the other registry. Review `initializeCommand` and the `*Command` hooks like any script that runs on the host or at container start.
- **No secrets** in `containerEnv`, `remoteEnv`, or the Dockerfile. Credentials arrive through the `env/common/tmp/` bind mounts, which stay git-ignored.
- **Trivy and the Dockerfile:** `trivy.yaml` skips `env/`. If `env/common/Dockerfile` is scanned directly, DS-0002 (no `USER`; `remoteUser` is `vscode`) and DS-0026 (`HEALTHCHECK`) are accepted false positives for a devcontainer.
