#!/bin/bash
sudo chown -R $(id -u):$(id -g) /home/vscode/.aws
sudo chown -R $(id -u):$(id -g) /home/vscode/.gitconfig
sudo chown -R $(id -u):$(id -g) /home/vscode/.ssh
chmod 600 /home/vscode/.ssh/id_rsa
pre-commit install
