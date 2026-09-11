#!/usr/bin/env python3
"""安装 CangjieTransSkills 及其 LoopX 运行环境。"""

from __future__ import print_function

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import sysconfig
from datetime import datetime, timezone
from pathlib import Path


MIN_PYTHON = (3, 11)
MIN_NODE = (22, 6)
MIN_LOOPX = (1, 0, 2)
MAX_LOOPX_MAJOR = 2
LOOPX_REQUIREMENT = "loopx>=1.0.2,<2"
SKILL_IGNORE_PATTERNS = ("__pycache__", "*.pyc", ".DS_Store")

SOURCE_ROOT = Path(__file__).resolve().parents[1]
SOURCE_SKILLS = SOURCE_ROOT / ".claude" / "skills"
SOURCE_CLAUDE = SOURCE_ROOT / "CLAUDE.md"

CLAUDE_START = "<!-- >>> CangjieTransSkills managed instructions >>> -->"
CLAUDE_END = "<!-- <<< CangjieTransSkills managed instructions <<< -->"
IGNORE_START = "# >>> CangjieTransSkills managed ignores >>>"
IGNORE_END = "# <<< CangjieTransSkills managed ignores <<<"

IGNORE_BODY = """.env
.loopx/
.codex/goals/
.local/
ui_capture_output/
hm-docs/
*.log"""

ENV_TEMPLATE = """# CangjieTransSkills 环境配置模板
# 复制为 .env 后填写实际路径；安装器不会覆盖已有 .env。

# HarmonyOS 应用构建和 UI 检测必填
DEVECO_HOME=

# 仓颉 SDK 通用路径（可选；未设置时尝试自动检测）
CANGJIE_SDK_HOME=

# 按版本锁定的 SDK 路径（可选）
CANGJIE_SDK_HOME-8k=
CANGJIE_SDK_HOME-15k=
"""


def run(command):
    print("+ " + " ".join(str(part) for part in command))
    return subprocess.run([str(part) for part in command], check=False).returncode


def parse_version(text):
    match = re.search(r"(\d+)\.(\d+)(?:\.(\d+))?", text)
    if not match:
        return None
    return tuple(int(value or 0) for value in match.groups())


def resolve_loopx():
    scripts_dir = Path(sysconfig.get_path("scripts"))
    candidates = [
        scripts_dir / "loopx",
        scripts_dir / "loopx.exe",
        scripts_dir / "loopx.cmd",
    ]
    interpreter_entry = next(
        (candidate for candidate in candidates if candidate.is_file()), None
    )
    if interpreter_entry:
        return interpreter_entry

    executable = shutil.which("loopx")
    return Path(executable) if executable else None


def check_python():
    current = sys.version_info[:2]
    if current < MIN_PYTHON:
        print(
            (
                "错误：LoopX 需要 Python 3.11+，当前为 {}.{}。"
                "请使用 Python 3.11+ 重新运行。"
            ).format(current[0], current[1]),
            file=sys.stderr,
        )
        return False
    print("Python 检查通过：{}.{}".format(current[0], current[1]))
    return True


def check_node():
    executable = shutil.which("node")
    if not executable:
        print("错误：未找到 Node.js；LoopX 需要 Node.js 22.6+。", file=sys.stderr)
        return False

    result = subprocess.run(
        [executable, "--version"],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    version = parse_version(result.stdout)
    if result.returncode != 0 or version is None or version[:2] < MIN_NODE:
        observed = result.stdout.strip() or "未知"
        print(
            "错误：LoopX 需要 Node.js 22.6+，当前为 {}。".format(observed),
            file=sys.stderr,
        )
        return False
    print("Node.js 检查通过：{}".format(result.stdout.strip()))
    return True


def check_loopx_version(loopx):
    result = subprocess.run(
        [str(loopx), "--version"],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    version = parse_version(result.stdout)
    if (
        result.returncode != 0
        or version is None
        or version < MIN_LOOPX
        or version[0] >= MAX_LOOPX_MAJOR
    ):
        observed = result.stdout.strip() or "未知"
        print(
            (
                "错误：需要 LoopX >=1.0.2,<2，当前为 {}。"
                "请使用 --install 修复。"
            ).format(observed),
            file=sys.stderr,
        )
        return False
    print("LoopX 版本检查通过：{}".format(result.stdout.strip()))
    return True


def remove_path(path):
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.is_dir():
        shutil.rmtree(path)


def directory_digest(root):
    if root.is_symlink():
        raise RuntimeError("拒绝处理符号链接：{}".format(root))
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        if "__pycache__" in path.parts or path.name == ".DS_Store":
            continue
        if path.suffix == ".pyc":
            continue
        if path.is_symlink():
            raise RuntimeError("拒绝处理符号链接：{}".format(path))
        if not path.is_file():
            continue
        relative = path.relative_to(root).as_posix().encode("utf-8")
        digest.update(relative)
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def render_managed_block(start, body, end):
    return "{}\n{}\n{}".format(start, body.rstrip(), end)


def merge_managed_block(current, start, body, end):
    has_start = start in current
    has_end = end in current
    if has_start != has_end:
        raise RuntimeError("托管标记不完整：{} / {}".format(start, end))

    block = render_managed_block(start, body, end)
    if has_start:
        pattern = re.compile(re.escape(start) + r".*?" + re.escape(end), re.DOTALL)
        updated, count = pattern.subn(lambda _match: block, current)
        if count != 1:
            raise RuntimeError("发现重复托管块：{}".format(start))
        return updated if updated.endswith("\n") else updated + "\n"

    if not current:
        return block + "\n"
    separator = "\n" if current.endswith("\n") else "\n\n"
    return current + separator + block + "\n"


class InstallTransaction:
    def __init__(self, target_root):
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        self.target_root = target_root
        self.local_root = target_root / ".local"
        self.local_root_existed = self.local_root.exists()
        self.backup_root = (
            self.local_root
            / "cangjie-trans-skills"
            / "setup-backups"
            / "{}-{}".format(stamp, os.getpid())
        )
        self.records = []
        self.created_dirs = set()

    def _relative(self, path):
        try:
            return path.relative_to(self.target_root)
        except ValueError as exc:
            raise RuntimeError("安装目标越界：{}".format(path)) from exc

    def _prepare(self, path):
        relative = self._relative(path)
        if path.is_symlink():
            raise RuntimeError("拒绝覆盖符号链接：{}".format(path))

        backup = None
        if path.exists():
            if (self.target_root / ".local").is_symlink():
                raise RuntimeError("拒绝使用符号链接形式的 .local 备份目录")
            backup = self.backup_root / relative
            backup.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(path), str(backup))
        self.records.append((path, backup))

    def _make_parents(self, parent):
        missing = []
        current = parent
        while current != self.target_root and not current.exists():
            missing.append(current)
            current = current.parent
        if current.is_symlink():
            raise RuntimeError("拒绝通过符号链接目录写入：{}".format(current))
        parent.mkdir(parents=True, exist_ok=True)
        self.created_dirs.update(missing)

    def replace_text(self, path, content):
        if path.exists() and not path.is_file():
            raise RuntimeError("文本安装目标不是文件：{}".format(path))
        self._prepare(path)
        self._make_parents(path.parent)
        path.write_text(content, encoding="utf-8")

    def replace_directory(self, path, source):
        self._prepare(path)
        self._make_parents(path.parent)
        shutil.copytree(
            source,
            path,
            ignore=shutil.ignore_patterns(*SKILL_IGNORE_PATTERNS),
        )

    def rollback(self):
        for path, backup in reversed(self.records):
            remove_path(path)
            if backup is not None and backup.exists():
                path.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(backup), str(path))
        for path in sorted(self.created_dirs, key=lambda item: len(item.parts), reverse=True):
            try:
                path.rmdir()
            except (FileNotFoundError, OSError):
                pass
        if self.backup_root.exists():
            shutil.rmtree(self.backup_root)
        current = self.backup_root.parent
        while current != self.target_root:
            if current == self.local_root and self.local_root_existed:
                break
            try:
                current.rmdir()
            except (FileNotFoundError, OSError):
                break
            current = current.parent


def validate_source_payload():
    if not SOURCE_SKILLS.is_dir() or not SOURCE_CLAUDE.is_file():
        raise RuntimeError("CangjieTransSkills 安装源不完整")
    skill_dirs = sorted(path for path in SOURCE_SKILLS.iterdir() if path.is_dir())
    if not skill_dirs:
        raise RuntimeError("未找到可安装的 Skill")
    for skill_dir in skill_dirs:
        if not (skill_dir / "SKILL.md").is_file():
            raise RuntimeError("Skill 缺少 SKILL.md：{}".format(skill_dir.name))
    return skill_dirs


def validate_target(target):
    target = target.expanduser().resolve()
    if not target.exists() or not target.is_dir():
        raise RuntimeError("目标项目目录不存在：{}".format(target))
    if target == Path(target.anchor) or target == Path.home().resolve():
        raise RuntimeError("拒绝将根目录或用户主目录作为目标项目")
    for relative in (Path(".claude"), Path(".claude/skills"), Path(".local")):
        if (target / relative).is_symlink():
            raise RuntimeError("拒绝写入符号链接目录：{}".format(relative))
    return target


def project_type(target):
    has_entry = (target / "entry").is_dir()
    has_module = any(target.glob("entry/**/module.json5"))
    has_app = (target / "AppScope" / "app.json5").is_file() or (
        target / "app.json5"
    ).is_file()
    if has_entry and has_module and has_app:
        return "HarmonyOS 应用"
    if (target / "cjpm.toml").is_file() and not has_entry:
        return "仓颉 cjpm 库"
    return "源项目或待判定项目"


def manifest_content(skill_dirs):
    payload = {
        "schema_version": "cangjie_trans_skills_install_v1",
        "loopx_requirement": LOOPX_REQUIREMENT,
        "skills": [path.name for path in skill_dirs],
        "skills_digest": directory_digest(SOURCE_SKILLS),
    }
    return json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def install_project_payload(target):
    skill_dirs = validate_source_payload()
    target = validate_target(target)

    if target == SOURCE_ROOT:
        print("目标是 CangjieTransSkills 源仓库；Skill 文件已就绪，跳过自身复制。")
        return {"target": target, "changed": [], "backup": None, "source_tree": True}

    transaction = InstallTransaction(target)
    changed = []
    target_skills = target / ".claude" / "skills"

    try:
        ignore_path = target / ".gitignore"
        if ignore_path.is_symlink():
            raise RuntimeError("拒绝覆盖符号链接：.gitignore")
        ignore_current = (
            ignore_path.read_text(encoding="utf-8") if ignore_path.is_file() else ""
        )
        ignore_updated = merge_managed_block(
            ignore_current, IGNORE_START, IGNORE_BODY, IGNORE_END
        )
        if ignore_updated != ignore_current:
            transaction.replace_text(ignore_path, ignore_updated)
            changed.append(".gitignore")

        for source_skill in skill_dirs:
            target_skill = target_skills / source_skill.name
            if target_skill.is_symlink():
                raise RuntimeError(
                    "拒绝覆盖符号链接 Skill：{}".format(source_skill.name)
                )
            if target_skill.is_dir() and directory_digest(target_skill) == directory_digest(
                source_skill
            ):
                continue
            transaction.replace_directory(target_skill, source_skill)
            changed.append(".claude/skills/{}".format(source_skill.name))

        claude_path = target / "CLAUDE.md"
        if claude_path.is_symlink():
            raise RuntimeError("拒绝覆盖符号链接：CLAUDE.md")
        claude_current = (
            claude_path.read_text(encoding="utf-8") if claude_path.is_file() else ""
        )
        claude_updated = merge_managed_block(
            claude_current,
            CLAUDE_START,
            SOURCE_CLAUDE.read_text(encoding="utf-8"),
            CLAUDE_END,
        )
        if claude_updated != claude_current:
            transaction.replace_text(claude_path, claude_updated)
            changed.append("CLAUDE.md")

        env_example = target / ".env.cangjie.example"
        if env_example.is_symlink():
            raise RuntimeError("拒绝覆盖符号链接：.env.cangjie.example")
        env_current = (
            env_example.read_text(encoding="utf-8") if env_example.is_file() else None
        )
        if env_current != ENV_TEMPLATE:
            transaction.replace_text(env_example, ENV_TEMPLATE)
            changed.append(".env.cangjie.example")

        manifest_path = target / ".claude" / "cangjie-trans-skills-install.json"
        if manifest_path.is_symlink():
            raise RuntimeError("拒绝覆盖符号链接：安装清单")
        expected_manifest = manifest_content(skill_dirs)
        manifest_current = (
            manifest_path.read_text(encoding="utf-8")
            if manifest_path.is_file()
            else None
        )
        if manifest_current != expected_manifest:
            transaction.replace_text(manifest_path, expected_manifest)
            changed.append(".claude/cangjie-trans-skills-install.json")

        for source_skill in skill_dirs:
            installed = target_skills / source_skill.name
            if not installed.is_dir() or directory_digest(installed) != directory_digest(
                source_skill
            ):
                raise RuntimeError("安装回读失败：{}".format(source_skill.name))
        if CLAUDE_START not in claude_path.read_text(encoding="utf-8"):
            raise RuntimeError("CLAUDE.md 托管规则回读失败")
        if IGNORE_START not in ignore_path.read_text(encoding="utf-8"):
            raise RuntimeError(".gitignore 托管规则回读失败")
        if manifest_path.read_text(encoding="utf-8") != expected_manifest:
            raise RuntimeError("安装清单回读失败")
    except Exception:
        transaction.rollback()
        raise

    backup = transaction.backup_root if transaction.backup_root.exists() else None
    return {
        "target": target,
        "changed": changed,
        "backup": backup,
        "source_tree": False,
    }


def setup_loopx(install, no_deep):
    if not check_python() or not check_node():
        return 2

    if install:
        if (
            run(
                [
                    sys.executable,
                    "-m",
                    "pip",
                    "install",
                    "--upgrade",
                    LOOPX_REQUIREMENT,
                ]
            )
            != 0
        ):
            return 3

    loopx = resolve_loopx()
    if loopx is None:
        print(
            "错误：未找到 loopx。请使用 `./setup.sh <目标项目>` 安装。",
            file=sys.stderr,
        )
        return 4

    if not check_loopx_version(loopx):
        return 5

    if install:
        if (
            run(
                [
                    loopx,
                    "slash-commands",
                    "--install",
                    "--surface",
                    "claude-code",
                    "--cli-bin",
                    loopx,
                ]
            )
            != 0
        ):
            return 6

    doctor_command = [loopx, "doctor"]
    if not no_deep:
        doctor_command.append("--deep")
    if run(doctor_command) != 0:
        return 7

    print("LoopX 已就绪。")
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--install",
        action="store_true",
        help="安装或升级 LoopX，并安装 Claude Code 的 /loopx 命令入口",
    )
    parser.add_argument(
        "--target-project",
        type=Path,
        help="安装 CangjieTransSkills 的目标项目目录",
    )
    parser.add_argument(
        "--skip-loopx",
        action="store_true",
        help="仅安装项目 Skill；用于 LoopX 已由外部环境管理的场景",
    )
    parser.add_argument(
        "--no-deep",
        action="store_true",
        help="只运行普通 doctor，不启动深度运行时检查",
    )
    args = parser.parse_args()

    if args.skip_loopx and not args.target_project:
        parser.error("--skip-loopx 必须与 --target-project 一起使用")

    if not args.skip_loopx:
        status = setup_loopx(args.install, args.no_deep)
        if status != 0:
            return status

    if args.target_project:
        try:
            result = install_project_payload(args.target_project)
        except Exception as exc:
            print("错误：CangjieTransSkills 安装失败：{}".format(exc), file=sys.stderr)
            return 8

        print("目标项目：{}".format(result["target"]))
        print("项目类型：{}".format(project_type(result["target"])))
        if result["changed"]:
            print("已安装/更新：{}".format(", ".join(result["changed"])))
        else:
            print("CangjieTransSkills 已是最新状态，无需更新。")
        if result["backup"]:
            print("已有内容备份：{}".format(result["backup"]))
        if not (result["target"] / ".env").is_file():
            print("下一步：参考 .env.cangjie.example 创建并填写 .env。")

    print("安装完成；重新启动 Claude Code 后即可使用仓颉操作型 Skill。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
