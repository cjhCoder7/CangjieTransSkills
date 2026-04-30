#!/usr/bin/env python3
"""仓颉 cjpm 库构建脚本 — 库级别（非 HarmonyOS 应用）。

执行流程：
1. 解析库根目录（含 cjpm.toml）
2. 检测仓颉 SDK（.env 显式配置 → 自动扫描）
3. source envsetup 让 cjpm/cjc 进入 PATH
4. 可选 cjpm clean
5. 依次以 static / dynamic / executable 构建（executable 仅当有 main.cj 时）
6. 验证产物并恢复原始 output-type
7. 若库根含 src/*_test.cj、tests/ 或 cjpm.toml 含 [test]/[[test]] 段，则 cjpm test
"""

from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path


def load_env(env_file: Path) -> dict:
    env: dict = {}
    if not env_file.exists():
        return env
    for line in env_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if "=" in line and not line.startswith("#"):
            key, value = line.split("=", 1)
            env[key.strip()] = value.strip().strip("'").strip('"').strip()
    return env


def find_cangjie_sdk(version: str) -> str | None:
    base = Path.home() / ".cangjie-sdk"
    if not base.exists():
        return None
    version_dirs = sorted(
        [d for d in base.iterdir() if d.is_dir()],
        key=lambda p: p.name,
        reverse=True,
    )
    for vd in version_dirs:
        if version == "8k":
            sdk = vd / "cangjie"
            if sdk.exists():
                return str(sdk)
        elif version == "15k":
            for cd in sorted(vd.glob("compatibility-sdk-*"), reverse=True):
                sdk = cd / "compatibility"
                if sdk.exists():
                    return str(sdk)
    return None


def capture_env_from_cangjie_setup(cangjie_sdk: str, env: dict) -> dict:
    updated = dict(env)
    is_windows = platform.system() == "Windows"
    if is_windows:
        script = Path(cangjie_sdk) / "build-tools" / "envsetup.ps1"
        if not script.exists():
            return updated
        cmd = [
            "powershell", "-NoProfile", "-Command",
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


def locate_cjpm(cangjie_sdk: str, env: dict) -> str | None:
    cjpm_in_path = shutil.which("cjpm", path=env.get("PATH"))
    if cjpm_in_path:
        return cjpm_in_path
    is_windows = platform.system() == "Windows"
    suffix = ".exe" if is_windows else ""
    sdk = Path(cangjie_sdk)
    for c in (
        sdk / "bin" / f"cjpm{suffix}",
        sdk / "tools" / "bin" / f"cjpm{suffix}",
        sdk / "build-tools" / "bin" / f"cjpm{suffix}",
        sdk / "build-tools" / "tools" / "bin" / f"cjpm{suffix}",
    ):
        if c.exists():
            return str(c)
    return None


def run_cmd(cmd: list, env: dict, cwd: str) -> int:
    print(f"\033[90m>>> {' '.join(str(c) for c in cmd)}  (cwd={cwd})\033[0m")
    result = subprocess.run(cmd, env=env, cwd=cwd)
    if result.returncode != 0 and result.stderr:
        for line in result.stderr.splitlines():
            print(f"\033[31m{line}\033[0m")
    return result.returncode


def detect_version(*candidates: Path) -> str:
    for c in candidates:
        if not c:
            continue
        f = c / ".openvk-version"
        if f.exists():
            v = f.read_text(encoding="utf-8").strip()
            if v in ("8k", "15k"):
                return v
    return "8k"


def has_tests(lib_root: Path) -> bool:
    # src/ 下的 *_test.cj 文件（cjpm 官方约定）
    src_dir = lib_root / "src"
    if src_dir.is_dir() and any(src_dir.rglob("*_test.cj")):
        return True
    if (lib_root / "tests").is_dir():
        return True
    toml = lib_root / "cjpm.toml"
    if toml.exists():
        text = toml.read_text(encoding="utf-8", errors="ignore")
        if "[[test]]" in text or "[test]" in text:
            return True
    return False


OUTPUT_TYPES = ("static", "dynamic", "executable")


def read_toml_output_type(toml_path: Path) -> str | None:
    if not toml_path.exists():
        return None
    for line in toml_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        stripped = line.strip()
        if stripped.startswith("output-type") and "=" in stripped:
            val = stripped.split("=", 1)[1].strip().strip('"').strip("'")
            if val in OUTPUT_TYPES:
                return val
    return None


def set_toml_output_type(toml_path: Path, new_type: str) -> None:
    text = toml_path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("output-type") and "=" in stripped:
            indent = line[: len(line) - len(line.lstrip())]
            lines[i] = f'{indent}output-type = "{new_type}"'
            break
    toml_path.write_text("\n".join(lines), encoding="utf-8")
    if text.endswith("\n"):
        with open(toml_path, "a", encoding="utf-8") as f:
            f.write("\n")


def read_toml_name(toml_path: Path) -> str | None:
    if not toml_path.exists():
        return None
    for line in toml_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        stripped = line.strip()
        if stripped.startswith("name") and "=" in stripped:
            val = stripped.split("=", 1)[1].strip().strip('"').strip("'")
            if val:
                return val
    return None


def collect_artifacts(lib_root: Path, pkg_name: str) -> list[Path]:
    """扫描 target/release/ 下所有有意义的构建产物。"""
    target = lib_root / "target" / "release"
    if not target.exists():
        return []
    found: list[Path] = []
    # 可执行文件: target/release/bin/
    bin_dir = target / "bin"
    if bin_dir.exists():
        found.extend(p for p in bin_dir.iterdir() if p.is_file())
    # 库产物: target/release/<pkg_name>/
    pkg_dir = target / pkg_name
    if pkg_dir.exists():
        lib_exts = {".a", ".lib", ".so", ".dylib", ".dll"}
        found.extend(p for p in pkg_dir.iterdir()
                     if p.is_file() and (p.suffix in lib_exts or p.name.endswith(".cjo")))
    return sorted(found)


def main():
    parser = argparse.ArgumentParser(description="仓颉 cjpm 库构建脚本")
    parser.add_argument("lib_path", nargs="?", default=".",
                        help="库根目录（含 cjpm.toml），默认当前目录")
    parser.add_argument("-v", "--version", choices=["8k", "15k"], default=None,
                        help="仓颉 SDK 版本，未指定时从 .openvk-version 读取，默认 8k")
    parser.add_argument("--no-test", action="store_true", help="跳过 cjpm test")
    parser.add_argument("--clean", action="store_true", help="构建前先 cjpm clean")
    args = parser.parse_args()

    lib_root = Path(args.lib_path).resolve()
    if not lib_root.exists():
        print(f"\033[31m错误: 路径不存在: {lib_root}\033[0m")
        sys.exit(2)
    if not (lib_root / "cjpm.toml").exists():
        print(f"\033[31m错误: 未在 {lib_root} 找到 cjpm.toml；请确认这是 cjpm 库根目录\033[0m")
        sys.exit(2)
    print(f"\033[32m库根目录: {lib_root}\033[0m")

    project_root = Path(__file__).resolve().parent.parent.parent.parent

    # .env 优先看库根，其次回退到项目根；两边都不存在则空配置（仍可走自动检测）
    env_config = load_env(lib_root / ".env")
    if not env_config:
        env_config = load_env(project_root / ".env")

    version = args.version or detect_version(lib_root, project_root)
    print(f"\033[36m仓颉 SDK 版本: {version}\033[0m")

    # SDK 检测优先级：版本专用键 → 通用键 → 自动扫描
    sdk_key = f"CANGJIE_SDK_HOME-{version}"
    env_override = env_config.get(sdk_key)
    if env_override and Path(env_override).exists():
        cangjie_sdk = env_override
        print(f"\033[36m使用 .env 中 {sdk_key}: {cangjie_sdk}\033[0m")
    else:
        env_override = env_config.get("CANGJIE_SDK_HOME")
        if env_override and Path(env_override).exists():
            cangjie_sdk = env_override
            print(f"\033[36m使用 .env 中 CANGJIE_SDK_HOME: {cangjie_sdk}\033[0m")
        else:
            cangjie_sdk = find_cangjie_sdk(version)
            if cangjie_sdk:
                print(f"\033[36m已自动检测仓颉 SDK [{version}]: {cangjie_sdk}\033[0m")
    if not cangjie_sdk:
        print(f"\033[31m错误: 未找到版本 [{version}] 对应的仓颉 SDK\033[0m")
        print(f"请确认 SDK 已安装在 ~/.cangjie-sdk/，或在 .env 中设置 CANGJIE_SDK_HOME 或 {sdk_key}")
        sys.exit(1)

    env = os.environ.copy()
    env["CANGJIE_SDK_HOME"] = cangjie_sdk
    env = capture_env_from_cangjie_setup(cangjie_sdk, env)
    print("\033[36m已加载仓颉 envsetup\033[0m")

    cjpm = locate_cjpm(cangjie_sdk, env)
    if not cjpm:
        print(f"\033[31m错误: 未在 SDK ({cangjie_sdk}) 中找到 cjpm 可执行文件\033[0m")
        sys.exit(1)
    print(f"\033[36mcjpm: {cjpm}\033[0m")

    cwd = str(lib_root)

    if args.clean:
        print("\033[35m清理...\033[0m")
        rc = run_cmd([cjpm, "clean"], env=env, cwd=cwd)
        if rc != 0:
            print(f"\033[33m警告: cjpm clean 返回 {rc}，继续构建\033[0m")

    toml_path = lib_root / "cjpm.toml"
    original_type = read_toml_output_type(toml_path) or "static"
    pkg_name = read_toml_name(toml_path) or lib_root.name

    # 依次以 static / dynamic / executable 构建，生成全部产物
    # executable 仅在有 main 入口时尝试（纯库无 main 会编译失败）
    has_main = any((lib_root / "src").rglob("main.cj"))
    build_types = list(OUTPUT_TYPES) if has_main else ["static", "dynamic"]
    build_failed = False
    for ot in build_types:
        print(f"\033[35m构建 output-type={ot}...\033[0m")
        set_toml_output_type(toml_path, ot)
        rc = run_cmd([cjpm, "build"], env=env, cwd=cwd)
        if rc != 0:
            print(f"\033[31m构建失败 output-type={ot} (rc={rc})\033[0m")
            build_failed = True
            break

    # 无论成败都恢复原始 output-type
    set_toml_output_type(toml_path, original_type)
    print(f"\033[36m已恢复 output-type={original_type}\033[0m")

    if build_failed:
        sys.exit(1)

    target_dir = lib_root / "target"
    if target_dir.exists():
        print(f"\033[32m产物目录: {target_dir}\033[0m")

    artifacts = collect_artifacts(lib_root, pkg_name)
    if artifacts:
        for a in artifacts:
            print(f"\033[32m产物: {a}\033[0m")
    else:
        print(f"\033[33m警告: 未在 target/release/ 下找到任何二进制产物\033[0m")

    if args.no_test:
        print("\033[36m已跳过测试\033[0m")
    elif has_tests(lib_root):
        print("\033[35m运行测试...\033[0m")
        rc = run_cmd([cjpm, "test"], env=env, cwd=cwd)
        if rc != 0:
            print(f"\033[31m测试失败 (rc={rc})\033[0m")
            sys.exit(rc)
    else:
        print("\033[36m未检测到 tests/ 或测试段，跳过 cjpm test\033[0m")

    print("\033[32m完成\033[0m")


if __name__ == "__main__":
    main()
