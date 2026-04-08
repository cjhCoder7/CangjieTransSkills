#!/usr/bin/env python3
"""跨平台 HarmonyOS 构建脚本，等效于 build.ps1。"""

from __future__ import annotations

import argparse
import os
import platform
import subprocess
import sys
from pathlib import Path


def load_env(env_file: Path) -> dict:
    """读取 .env 文件，返回键值对。"""
    env = {}
    if not env_file.exists():
        return env
    for line in env_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if "=" in line and not line.startswith("#"):
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip("'").strip('"').strip()
            env[key] = value
    return env


def detect_version(project_root: Path) -> str:
    """从 .openvk-version 读取版本，不存在时默认 8k 并写入文件。"""
    version_file = project_root / ".openvk-version"
    if version_file.exists():
        version = version_file.read_text(encoding="utf-8").strip()
        if version in ("8k", "15k"):
            return version
    # 默认 8k
    version_file.write_text("8k", encoding="utf-8")
    print("\033[33m未检测到有效版本，已默认写入 8k 到 .openvk-version\033[0m")
    return "8k"


def find_cangjie_sdk(version: str) -> str | None:
    """自动在 ~/.cangjie-sdk/ 下检测对应版本的仓颉 SDK 路径。"""
    base = Path.home() / ".cangjie-sdk"
    if not base.exists():
        return None

    # 按版本号倒序扫描（优先取最新）
    version_dirs = sorted(
        [d for d in base.iterdir() if d.is_dir()],
        key=lambda p: p.name,
        reverse=True,
    )

    for vd in version_dirs:
        if version == "8k":
            sdk_path = vd / "cangjie"
            if sdk_path.exists():
                return str(sdk_path)
        elif version == "15k":
            compat_dirs = sorted(vd.glob("compatibility-sdk-*"), reverse=True)
            for cd in compat_dirs:
                sdk_path = cd / "compatibility"
                if sdk_path.exists():
                    return str(sdk_path)
    return None


def run_cmd(cmd: list, env: dict, cwd: str | None = None):
    """执行命令并实时输出，失败时退出。"""
    print(f"\033[90m>>> {' '.join(str(c) for c in cmd)}\033[0m")
    result = subprocess.run(cmd, env=env, cwd=cwd)
    if result.returncode != 0:
        print(f"\033[31m命令失败，返回码: {result.returncode}\033[0m")
        sys.exit(result.returncode)


def capture_env_from_cangjie_setup(cangjie_sdk: str, env: dict) -> dict:
    """执行仓颉 SDK 的 envsetup 脚本并捕获环境变量变化。"""
    updated = dict(env)
    is_windows = platform.system() == "Windows"

    if is_windows:
        script = Path(cangjie_sdk) / "build-tools" / "envsetup.ps1"
        if not script.exists():
            return updated
        cmd = [
            "powershell",
            "-NoProfile",
            "-Command",
            f'. "{script}"; Get-ChildItem Env: | ForEach-Object {{ "$($_.Name)=$($_.Value)" }}',
        ]
    else:
        script = Path(cangjie_sdk) / "build-tools" / "envsetup.sh"
        if not script.exists():
            return updated
        cmd = ["bash", "-c", f'source "{script}" && env']

    result = subprocess.run(cmd, capture_output=True, text=True, env=env)
    if result.returncode == 0:
        for line in result.stdout.splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                updated[k] = v
    return updated


def main():
    parser = argparse.ArgumentParser(description="HarmonyOS 跨平台构建脚本")
    parser.add_argument(
        "-v",
        "--version",
        choices=["8k", "15k"],
        default=None,
        help="构建版本（8k 或 15k），未指定时从 .openvk-version 读取",
    )
    args = parser.parse_args()

    # --- 项目根目录（脚本位于 .claude/skills/build/ 下，向上 4 级） ---
    project_root = Path(__file__).resolve().parent.parent.parent.parent
    os.chdir(project_root)
    print(f"\033[32m已切换至项目根目录: {project_root}\033[0m")

    # --- 版本检测 ---
    version = args.version or detect_version(project_root)
    print(f"\033[36m当前构建版本: {version}\033[0m")

    # --- 读取 .env ---
    env_config = load_env(project_root / ".env")
    deveco_home_str = env_config.get("DEVECO_HOME", "")
    if not deveco_home_str:
        print("\033[31m错误: .env 文件中未配置 DEVECO_HOME\033[0m")
        sys.exit(1)
    deveco_home = Path(deveco_home_str)
    if not deveco_home.exists():
        print(f"\033[31m错误: DEVECO_HOME 路径不存在: {deveco_home}\033[0m")
        sys.exit(1)

    # --- 自动检测仓颉 SDK（.env 显式配置可覆盖） ---
    sdk_key = f"CANGJIE_SDK_HOME-{version}"
    env_override = env_config.get(sdk_key)

    cangjie_sdk = find_cangjie_sdk(version)
    if env_override and Path(env_override).exists():
        cangjie_sdk = env_override
        print(f"\033[36m使用 .env 中显式配置的仓颉 SDK: {cangjie_sdk}\033[0m")
    elif cangjie_sdk:
        print(f"\033[36m已自动检测仓颉 SDK [{version}]: {cangjie_sdk}\033[0m")
    else:
        print(f"\033[31m错误: 未找到版本 [{version}] 对应的仓颉 SDK\033[0m")
        print(f"请确认 SDK 已安装在 ~/.cangjie-sdk/ 目录下")
        sys.exit(1)

    # --- 验证 DevEco SDK ---
    deveco_sdk = deveco_home / "sdk"
    if not deveco_sdk.exists():
        print(f"\033[31m错误: SDK 路径不存在: {deveco_sdk}\033[0m")
        sys.exit(1)
    print(f"\033[32mSDK 路径验证成功: {deveco_sdk}\033[0m")

    # --- 构建运行环境 ---
    env = os.environ.copy()
    env["DEVECO_HOME"] = str(deveco_home)
    env["DEVECO_SDK_HOME"] = str(deveco_sdk)
    env["CANGJIE_SDK_HOME"] = cangjie_sdk
    env["DEVECO_CANGJIE_PATH"] = cangjie_sdk

    # 执行仓颉 envsetup 脚本
    env = capture_env_from_cangjie_setup(cangjie_sdk, env)
    print(f"\033[36m已执行仓颉 SDK 环境配置\033[0m")

    # 注入 Java 环境
    java_home = deveco_home / "jbr"
    if java_home.exists():
        env["JAVA_HOME"] = str(java_home)
        java_bin = str(java_home / "bin")
        env["PATH"] = java_bin + os.pathsep + env.get("PATH", "")
        print(f"\033[36m已注入 Java 环境: {java_home}\033[0m")
    else:
        print(f"\033[33m警告: 未找到 Java 运行时: {java_home}\033[0m")

    # --- 工具路径（跨平台） ---
    is_windows = platform.system() == "Windows"
    ohpm = deveco_home / "tools" / "ohpm" / "bin" / ("ohpm.bat" if is_windows else "ohpm")
    node = deveco_home / "tools" / "node" / "bin" / ("node.exe" if is_windows else "node")
    hvigorw = deveco_home / "tools" / "hvigor" / "bin" / "hvigorw.js"

    # --- 执行构建流程 ---
    print("\033[35m开始安装依赖...\033[0m")
    if ohpm.exists():
        run_cmd(
            [str(ohpm), "install", "--all",
             "--registry", "https://ohpm.openharmony.cn/ohpm/",
             "--strict_ssl", "true"],
            env=env,
        )

    print("\033[35m执行 SyncCangjieResource...\033[0m")
    run_cmd(
        [str(node), str(hvigorw),
         "--mode", "module", "-p", "module=entry@default",
         "SyncCangjieResource",
         "--analyze=normal", "--parallel", "--incremental", "--no-daemon"],
        env=env,
    )

    print("\033[35m执行 assembleHap...\033[0m")
    run_cmd(
        [str(node), str(hvigorw),
         "--mode", "module", "-p", "product=default",
         "assembleHap",
         "--analyze=normal", "--parallel", "--incremental", "--no-daemon"],
        env=env,
    )

    print("\033[32m构建完成！\033[0m")


if __name__ == "__main__":
    main()
