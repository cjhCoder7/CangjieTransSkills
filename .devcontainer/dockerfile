# 使用官方 Python 3.11 镜像，底层系统为 Debian (自带普通用户 vscode)
FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye

# 切换到 root 用户，以便安装系统级依赖
USER root

# 更新系统源，安装 Node.js (Claude CLI 运行依赖)，并全局安装 Claude
RUN apt-get update && apt-get install -y curl gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g @anthropic-ai/claude-code \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# 【核心权限防御】强制切换回内置的普通用户 vscode
# 从此行往下，以及容器启动后的默认环境，都不再是 root
USER vscode