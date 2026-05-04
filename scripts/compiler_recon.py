#!/usr/bin/env python3
"""仓颉物理编译环境侦察脚本。

用途：
1. 扫描资源目录中的 DevEco / Cangjie 插件压缩包；
2. 识别其中嵌套的 harmonyos-cangjie-sdk-*.zip；
3. 探测 `cjc`、`cjpm`、标准库与运行时库路径；
4. 判断工具链二进制格式与当前宿主机是否兼容；
5. 可选把 SDK（或最小工具链文件集）提取到本地目录，供后续 verifier 接入；
6. 可选进入 Deep Dig 模式，从插件文本资源与小型嵌套归档中挖掘 URL 线索；
7. 可选进入 Bytecode Sniff 模式，扫描 JAR/.class 常量池中的可打印字符串，提取高置信度 URL 与邻近上下文。
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import platform
import re
import stat
import string
import zipfile
from dataclasses import asdict, dataclass, field
from io import BufferedReader, BytesIO
from pathlib import Path
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Set, Tuple

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_RESOURCE_DIR = PROJECT_ROOT / "资源"
DEFAULT_OUTPUT = PROJECT_ROOT / "artifacts" / "compiler_recon" / "phase03-compiler-recon.json"
DEFAULT_LINUX_URL_OUTPUT = PROJECT_ROOT / "artifacts" / "compiler_recon" / "linux_sdk_urls.txt"
DEFAULT_JAR_URL_OUTPUT = PROJECT_ROOT / "artifacts" / "compiler_recon" / "jar_extracted_urls.json"

OUTER_ARCHIVE_RE = re.compile(r"devecostudio-cangjie-plugin-(?P<platform>[^/\\]+?)-(?P<version>\d+\.\d+\.\d+\.\d+)\.zip$")
SDK_ARCHIVE_RE = re.compile(r"harmonyos-cangjie-sdk-(?P<platform>[^/\\]+)\.zip$")
URL_RE = re.compile(r"https?://[A-Za-z0-9._~:/?#\[\]@!$&'()*+,;=%-]+")

TEXT_SUFFIXES = {
    ".js",
    ".json",
    ".xml",
    ".properties",
    ".txt",
    ".md",
    ".yaml",
    ".yml",
    ".html",
    ".ts",
}
NESTED_ARCHIVE_SUFFIXES = {".jar", ".zip"}
TEXT_URL_HINTS = (
    "linux",
    "x64",
    "x86_64",
    "amd64",
    "cangjie",
    "sdk",
    "download",
    ".tar.gz",
    ".zip",
    "harmonyos",
)
BYTECODE_URL_HINTS = (
    ".json",
    "manifest",
    "sdk-versions",
    "api/",
    "update/",
    "cangjie",
    "download",
    "release",
)
CONTEXT_HINTS = (
    "manifest",
    ".json",
    "api",
    "update",
    "release",
    "download",
    "linux",
    "x64",
    "x86_64",
    "amd64",
    "sdk",
    "cangjie",
    "harmonyos",
    "version",
)
ASCII_PRINTABLE_BYTES = {ord(ch) for ch in string.printable if ch not in "\x0b\x0c\r\n\t"}

MINIMAL_EXTRACTION_PREFIXES = (
    "cangjie/build-tools/bin/",
    "cangjie/build-tools/tools/bin/",
    "cangjie/oh-uni-package.json",
)

EXPANDED_EXTRACTION_PREFIXES = (
    "cangjie/build-tools/bin/",
    "cangjie/build-tools/tools/bin/",
    "cangjie/build-tools/runtime/lib/",
    "cangjie/build-tools/modules/",
    "cangjie/oh-uni-package.json",
)


@dataclass
class HostInfo:
    system: str
    release: str
    machine: str
    python_version: str


@dataclass
class BinaryProbe:
    path: str
    size_bytes: int
    magic_hex: str
    binary_format: str
    inferred_platform: str
    compatible_with_host: bool
    note: str = ""


@dataclass
class SdkProbe:
    source_archive: str
    source_archive_version: str
    nested_sdk_archive: str
    sdk_platform: str
    sdk_root: str
    compiler_executable: str = ""
    compiler_frontend: str = ""
    package_manager: str = ""
    stdlib_paths: List[str] = field(default_factory=list)
    runtime_lib_paths: List[str] = field(default_factory=list)
    tool_bin_paths: List[str] = field(default_factory=list)
    manifest_files: List[str] = field(default_factory=list)
    binary_probes: List[BinaryProbe] = field(default_factory=list)
    host_compatible: bool = False
    env_hints: Dict[str, str] = field(default_factory=dict)
    blockers: List[str] = field(default_factory=list)


@dataclass
class UrlHit:
    url: str
    source_archive: str
    entry_path: str
    depth: int
    matched_hints: List[str] = field(default_factory=list)


@dataclass
class BytecodeUrlHit:
    url: str
    source_archive: str
    jar_path: str
    class_path: str
    depth: int
    matched_hints: List[str] = field(default_factory=list)
    neighbor_strings: List[str] = field(default_factory=list)
    raw_string: str = ""


@dataclass
class DeepDigReport:
    enabled: bool = False
    url_output_path: str = ""
    scanned_entries: int = 0
    scanned_archives: int = 0
    skipped_large_entries: int = 0
    skipped_large_archives: int = 0
    all_urls: List[UrlHit] = field(default_factory=list)
    candidate_urls: List[UrlHit] = field(default_factory=list)
    notes: List[str] = field(default_factory=list)


@dataclass
class BytecodeDigReport:
    enabled: bool = False
    output_path: str = ""
    scanned_archives: int = 0
    scanned_jar_files: int = 0
    scanned_class_files: int = 0
    skipped_large_archives: int = 0
    skipped_large_classes: int = 0
    all_http_hits: List[BytecodeUrlHit] = field(default_factory=list)
    candidate_urls: List[BytecodeUrlHit] = field(default_factory=list)
    notes: List[str] = field(default_factory=list)


@dataclass
class ReconReport:
    generated_at: str
    resource_dir: str
    host: HostInfo
    archives_scanned: List[str]
    sdk_probes: List[SdkProbe]
    recommended_sdk: Optional[str]
    blockers: List[str]
    extraction: Dict[str, object] = field(default_factory=dict)
    deep_dig: DeepDigReport = field(default_factory=DeepDigReport)
    bytecode_dig: BytecodeDigReport = field(default_factory=BytecodeDigReport)


class ReconError(RuntimeError):
    pass


# -----------------------------
# 基础工具
# -----------------------------

def utc_now() -> str:
    return dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def detect_binary_format(data: bytes) -> Tuple[str, str, str]:
    if data.startswith(b"\x7fELF"):
        return "ELF", "linux", "ELF 可执行文件"
    if data.startswith(b"MZ"):
        return "PE", "windows", "PE/COFF 可执行文件"
    if data.startswith((b"\xcf\xfa\xed\xfe", b"\xfe\xed\xfa\xcf", b"\xca\xfe\xba\xbe")):
        return "Mach-O", "darwin", "Mach-O 可执行文件"
    if data.startswith(b"#!"):
        return "script", "portable", "脚本入口"
    if data[:16].isalpha():
        return "text", "portable", "文本入口"
    return "unknown", "unknown", "未知格式"


def host_platform_tag(system: str) -> str:
    lowered = system.lower()
    if lowered.startswith("darwin") or lowered.startswith("mac"):
        return "darwin"
    if lowered.startswith("win"):
        return "windows"
    if lowered.startswith("linux"):
        return "linux"
    return lowered


def is_platform_compatible(host_system: str, binary_platform: str) -> bool:
    host = host_platform_tag(host_system)
    if binary_platform == "portable":
        return True
    return host == binary_platform


def parse_outer_archive_name(path: Path) -> Tuple[str, str]:
    match = OUTER_ARCHIVE_RE.search(path.name)
    if not match:
        return "unknown", "unknown"
    return match.group("platform"), match.group("version")


def iter_outer_archives(resource_dir: Path) -> Iterable[Path]:
    for path in sorted(resource_dir.glob("*.zip")):
        if "cangjie-plugin" in path.name:
            yield path


def find_nested_sdk_archives(outer_zip: zipfile.ZipFile) -> List[str]:
    return [name for name in outer_zip.namelist() if SDK_ARCHIVE_RE.search(name)]


def exact_match(names: Sequence[str], *candidates: str) -> str:
    for candidate in candidates:
        if candidate in names:
            return candidate
    return ""


def normalize_url(url: str) -> str:
    return url.rstrip('"\'.,;)]}>')


# -----------------------------
# SDK 结构侦察
# -----------------------------

def probe_binary(sdk_zip: zipfile.ZipFile, host: HostInfo, path: str) -> Optional[BinaryProbe]:
    if not path:
        return None
    try:
        data = sdk_zip.read(path)
    except KeyError:
        return None
    binary_format, inferred_platform, note = detect_binary_format(data[:64])
    return BinaryProbe(
        path=path,
        size_bytes=len(data),
        magic_hex=data[:16].hex(),
        binary_format=binary_format,
        inferred_platform=inferred_platform,
        compatible_with_host=is_platform_compatible(host.system, inferred_platform),
        note=note,
    )


def select_preferred_runtime_path(probe: SdkProbe) -> str:
    if not probe.runtime_lib_paths:
        return ""
    sdk_platform = probe.sdk_platform.lower()
    if "mac" in sdk_platform or "darwin" in sdk_platform:
        for path in probe.runtime_lib_paths:
            if "/darwin_" in path:
                return path
    if "windows" in sdk_platform:
        for path in probe.runtime_lib_paths:
            if "/windows_" in path:
                return path
    if "linux" in sdk_platform:
        for path in probe.runtime_lib_paths:
            if "/linux_" in path and "/linux_ohos_" not in path:
                return path
    return probe.runtime_lib_paths[0]


def build_env_hints(probe: SdkProbe) -> Dict[str, str]:
    compiler_home = probe.sdk_root
    build_tools_root = f"{compiler_home}/build-tools"
    runtime_path = select_preferred_runtime_path(probe)
    tool_bin = probe.tool_bin_paths[0] if probe.tool_bin_paths else ""
    hints = {
        "DEVECO_CANGJIE_PATH": compiler_home,
        "CANGJIE_HARMONY_SDK_PATH": compiler_home,
        "PATH_PREPEND": ":".join(filter(None, [f"{build_tools_root}/bin", tool_bin])),
    }
    if runtime_path:
        hints["LD_LIBRARY_PATH_APPEND"] = runtime_path
        hints["DYLD_LIBRARY_PATH_APPEND"] = runtime_path
    return hints


def inspect_nested_sdk(*, outer_archive: Path, host: HostInfo, nested_name: str, nested_bytes: bytes) -> SdkProbe:
    outer_platform, outer_version = parse_outer_archive_name(outer_archive)
    with zipfile.ZipFile(BytesIO(nested_bytes)) as sdk_zip:
        names = sdk_zip.namelist()
        sdk_root = "cangjie"
        compiler_executable = exact_match(names, "cangjie/build-tools/bin/cjc", "cangjie/build-tools/bin/cjc.exe")
        compiler_frontend = exact_match(names, "cangjie/build-tools/bin/cjc-frontend", "cangjie/build-tools/bin/cjc-frontend.exe")
        package_manager = exact_match(names, "cangjie/build-tools/tools/bin/cjpm", "cangjie/build-tools/tools/bin/cjpm.exe")
        stdlib_paths = sorted({str(Path(name).parent) for name in names if "/build-tools/modules/" in name and str(Path(name).parent).endswith("/std")})
        runtime_lib_paths = sorted({str(Path(name).parent) for name in names if "/build-tools/runtime/lib/" in name and not name.endswith("/")})
        tool_bin_paths = sorted({str(Path(name).parent) for name in names if name.startswith("cangjie/build-tools/tools/bin/") and not name.endswith("/")})
        manifest_files = [name for name in names if name.endswith("uni-package.json")]
        sdk_match = SDK_ARCHIVE_RE.search(Path(nested_name).name)
        sdk_platform = sdk_match.group("platform") if sdk_match else outer_platform
        binary_probes = [
            probe
            for probe in [
                probe_binary(sdk_zip, host, compiler_executable),
                probe_binary(sdk_zip, host, package_manager),
            ]
            if probe is not None
        ]
        host_compatible = any(item.compatible_with_host for item in binary_probes)
        probe = SdkProbe(
            source_archive=str(outer_archive),
            source_archive_version=outer_version,
            nested_sdk_archive=nested_name,
            sdk_platform=sdk_platform,
            sdk_root=sdk_root,
            compiler_executable=compiler_executable,
            compiler_frontend=compiler_frontend,
            package_manager=package_manager,
            stdlib_paths=stdlib_paths,
            runtime_lib_paths=runtime_lib_paths,
            tool_bin_paths=tool_bin_paths,
            manifest_files=manifest_files,
            binary_probes=binary_probes,
            host_compatible=host_compatible,
        )
        probe.env_hints = build_env_hints(probe)
        if not compiler_executable:
            probe.blockers.append("未在 SDK 中发现 cjc 可执行入口")
        if not package_manager:
            probe.blockers.append("未在 SDK 中发现 cjpm 可执行入口")
        if not host_compatible:
            probe.blockers.append(f"SDK 平台为 {sdk_platform}，但当前宿主机为 {host.system}/{host.machine}，二进制不可直接执行")
        if not stdlib_paths:
            probe.blockers.append("未发现标准库 std 路径")
        return probe


def choose_recommended_sdk(probes: Sequence[SdkProbe], host: HostInfo) -> Tuple[Optional[str], List[str]]:
    blockers: List[str] = []
    for probe in probes:
        if probe.host_compatible and probe.compiler_executable:
            return probe.nested_sdk_archive, blockers
    if probes:
        blockers.append(f"已发现 {len(probes)} 个 SDK，但当前宿主机 {host.system}/{host.machine} 与现有 SDK 平台均不兼容")
    else:
        blockers.append("资源目录中未发现 harmonyos-cangjie-sdk-*.zip")
    return None, blockers


def inspect_resource_dir(resource_dir: Path) -> ReconReport:
    host = HostInfo(
        system=platform.system(),
        release=platform.release(),
        machine=platform.machine(),
        python_version=platform.python_version(),
    )
    archives = list(iter_outer_archives(resource_dir))
    sdk_probes: List[SdkProbe] = []
    for archive in archives:
        with zipfile.ZipFile(archive) as outer_zip:
            for nested_name in find_nested_sdk_archives(outer_zip):
                sdk_probes.append(
                    inspect_nested_sdk(
                        outer_archive=archive,
                        host=host,
                        nested_name=nested_name,
                        nested_bytes=outer_zip.read(nested_name),
                    )
                )
    recommended_sdk, blockers = choose_recommended_sdk(sdk_probes, host)
    return ReconReport(
        generated_at=utc_now(),
        resource_dir=str(resource_dir),
        host=host,
        archives_scanned=[str(path) for path in archives],
        sdk_probes=sdk_probes,
        recommended_sdk=recommended_sdk,
        blockers=blockers,
    )


def matches_extraction_scope(name: str, extraction_scope: str) -> bool:
    prefixes = EXPANDED_EXTRACTION_PREFIXES if extraction_scope == "toolchain" else MINIMAL_EXTRACTION_PREFIXES
    return any(name.startswith(prefix) if prefix.endswith("/") else name == prefix for prefix in prefixes)


def set_executable_bits(path: Path) -> None:
    if path.is_file():
        mode = path.stat().st_mode
        path.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def extract_nested_sdk(
    *,
    report: ReconReport,
    output_dir: Path,
    sdk_substring: Optional[str],
    extraction_scope: str,
) -> Dict[str, object]:
    if not report.sdk_probes:
        raise ReconError("没有可提取的 SDK")
    probe = report.sdk_probes[0]
    if sdk_substring:
        matched = next((item for item in report.sdk_probes if sdk_substring in item.nested_sdk_archive), None)
        if matched is None:
            raise ReconError(f"未找到匹配 {sdk_substring!r} 的 SDK")
        probe = matched
    outer_archive = Path(probe.source_archive)
    output_dir.mkdir(parents=True, exist_ok=True)
    extracted_files: List[str] = []
    with zipfile.ZipFile(outer_archive) as outer_zip:
        nested_bytes = outer_zip.read(probe.nested_sdk_archive)
    with zipfile.ZipFile(BytesIO(nested_bytes)) as sdk_zip:
        for name in sdk_zip.namelist():
            if name.endswith("/"):
                continue
            if not matches_extraction_scope(name, extraction_scope):
                continue
            destination = output_dir / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            with sdk_zip.open(name) as src, destination.open("wb") as dst:
                dst.write(src.read())
            if destination.name in {"cjc", "cjpm", "cjc-frontend", "cjc.exe", "cjpm.exe", "cjc-frontend.exe"}:
                set_executable_bits(destination)
            extracted_files.append(str(destination))
    extracted_root = output_dir / probe.sdk_root
    return {
        "selected_sdk": probe.nested_sdk_archive,
        "scope": extraction_scope,
        "output_dir": str(output_dir),
        "sdk_root": str(extracted_root),
        "compiler_executable": str(output_dir / probe.compiler_executable) if probe.compiler_executable else "",
        "package_manager": str(output_dir / probe.package_manager) if probe.package_manager else "",
        "extracted_file_count": len(extracted_files),
    }


# -----------------------------
# Deep Dig：文本/轻归档 URL 侦察
# -----------------------------

def extract_printable_strings_from_bytes(data: bytes, *, min_length: int = 10) -> List[str]:
    current: List[str] = []
    results: List[str] = []
    for byte in data:
        if byte in ASCII_PRINTABLE_BYTES:
            current.append(chr(byte))
            continue
        if len(current) >= min_length:
            results.append("".join(current))
        current = []
    if len(current) >= min_length:
        results.append("".join(current))
    return results


def decode_text_payload(data: bytes, *, suffix: str) -> str:
    if suffix == ".class":
        return "\n".join(extract_printable_strings_from_bytes(data, min_length=10))
    for encoding in ("utf-8", "utf-16", "latin1"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            continue
    return data.decode("latin1", errors="ignore")


def should_scan_as_text(entry_name: str, *, size: int, max_text_entry_bytes: int) -> bool:
    suffix = Path(entry_name).suffix.lower()
    if suffix == ".class":
        return size <= min(max_text_entry_bytes, 1024 * 1024)
    return suffix in TEXT_SUFFIXES and size <= max_text_entry_bytes


def should_descend_into_archive(entry_name: str, *, size: int, max_nested_archive_bytes: int) -> bool:
    suffix = Path(entry_name).suffix.lower()
    if suffix not in NESTED_ARCHIVE_SUFFIXES:
        return False
    if SDK_ARCHIVE_RE.search(Path(entry_name).name):
        return False
    return size <= max_nested_archive_bytes


def matched_text_url_hints(url: str) -> List[str]:
    lowered = url.lower()
    return [hint for hint in TEXT_URL_HINTS if hint in lowered]


def is_text_candidate_url(url: str) -> bool:
    lowered = url.lower()
    platform_hints = ("linux", "x64", "x86_64", "amd64")
    packaging_hints = ("download", "sdk", ".tar.gz", ".zip")
    product_hints = ("cangjie", "harmonyos")
    has_platform = any(hint in lowered for hint in platform_hints)
    has_packaging = any(hint in lowered for hint in packaging_hints)
    has_product = any(hint in lowered for hint in product_hints)
    harmony_sdk_pattern = re.search(r"harmonyos[-_/].*cangjie.*(linux|x64|x86_64|amd64)", lowered)
    cangjie_sdk_pattern = re.search(r"cangjie.*(sdk|download).*(linux|x64|x86_64|amd64)", lowered)
    return bool(harmony_sdk_pattern or cangjie_sdk_pattern or (has_platform and has_packaging and has_product))


def record_text_url_hit(report: DeepDigReport, *, url: str, source_archive: str, entry_path: str, depth: int, seen: Set[Tuple[str, str]]) -> None:
    normalized = normalize_url(url)
    key = (normalized, entry_path)
    if key in seen:
        return
    seen.add(key)
    hit = UrlHit(
        url=normalized,
        source_archive=source_archive,
        entry_path=entry_path,
        depth=depth,
        matched_hints=matched_text_url_hints(normalized),
    )
    report.all_urls.append(hit)
    if is_text_candidate_url(normalized):
        report.candidate_urls.append(hit)


def scan_archive_for_text_urls(
    archive: zipfile.ZipFile,
    *,
    source_archive: str,
    report: DeepDigReport,
    seen: Set[Tuple[str, str]],
    depth: int,
    max_text_entry_bytes: int,
    max_nested_archive_bytes: int,
    max_depth: int,
) -> None:
    report.scanned_archives += 1
    for info in archive.infolist():
        if info.is_dir():
            continue
        report.scanned_entries += 1
        entry_name = info.filename
        suffix = Path(entry_name).suffix.lower()
        if should_scan_as_text(entry_name, size=info.file_size, max_text_entry_bytes=max_text_entry_bytes):
            data = archive.read(entry_name)
            text = decode_text_payload(data, suffix=suffix)
            for url in URL_RE.findall(text):
                record_text_url_hit(report, url=url, source_archive=source_archive, entry_path=entry_name, depth=depth, seen=seen)
            continue
        if suffix in TEXT_SUFFIXES and info.file_size > max_text_entry_bytes:
            report.skipped_large_entries += 1
            continue
        if depth >= max_depth:
            continue
        if should_descend_into_archive(entry_name, size=info.file_size, max_nested_archive_bytes=max_nested_archive_bytes):
            try:
                nested_bytes = archive.read(entry_name)
                with zipfile.ZipFile(BytesIO(nested_bytes)) as nested_zip:
                    scan_archive_for_text_urls(
                        nested_zip,
                        source_archive=source_archive,
                        report=report,
                        seen=seen,
                        depth=depth + 1,
                        max_text_entry_bytes=max_text_entry_bytes,
                        max_nested_archive_bytes=max_nested_archive_bytes,
                        max_depth=max_depth,
                    )
            except zipfile.BadZipFile:
                report.notes.append(f"跳过非标准归档：{source_archive}!{entry_name}")
            continue
        if suffix in NESTED_ARCHIVE_SUFFIXES and info.file_size > max_nested_archive_bytes:
            report.skipped_large_archives += 1


def write_linux_url_candidates(report: DeepDigReport, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        f"# generated_at={utc_now()}",
        f"# candidate_count={len(report.candidate_urls)} all_url_count={len(report.all_urls)}",
    ]
    if report.candidate_urls:
        lines.append("# [candidate_urls]")
        for hit in report.candidate_urls:
            hint_text = ",".join(hit.matched_hints) if hit.matched_hints else "-"
            lines.append(f"{hit.url}\tarchive={hit.source_archive}\tentry={hit.entry_path}\thints={hint_text}")
    else:
        lines.append("# [candidate_urls] none")
    generic_urls = [hit for hit in report.all_urls if hit not in report.candidate_urls]
    if generic_urls:
        lines.append("# [generic_urls]")
        for hit in generic_urls[:50]:
            lines.append(f"{hit.url}\tarchive={hit.source_archive}\tentry={hit.entry_path}")
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def run_deep_dig(*, resource_dir: Path, max_text_entry_bytes: int, max_nested_archive_bytes: int, max_depth: int, url_output_path: Path) -> DeepDigReport:
    report = DeepDigReport(enabled=True, url_output_path=str(url_output_path))
    seen: Set[Tuple[str, str]] = set()
    for archive_path in iter_outer_archives(resource_dir):
        try:
            with zipfile.ZipFile(archive_path) as archive:
                scan_archive_for_text_urls(
                    archive,
                    source_archive=str(archive_path),
                    report=report,
                    seen=seen,
                    depth=0,
                    max_text_entry_bytes=max_text_entry_bytes,
                    max_nested_archive_bytes=max_nested_archive_bytes,
                    max_depth=max_depth,
                )
        except zipfile.BadZipFile:
            report.notes.append(f"坏压缩包，已跳过：{archive_path}")
    write_linux_url_candidates(report, url_output_path)
    if not report.candidate_urls:
        report.notes.append("未在可扫描文本资源中发现明确指向 Linux SDK 的下载 URL")
    return report


# -----------------------------
# Bytecode Sniff：JAR/.class 字节码嗅探
# -----------------------------

def iter_ascii_strings_from_stream(stream: BufferedReader, *, min_length: int, chunk_size: int = 65536) -> Iterator[str]:
    current: List[str] = []
    while True:
        chunk = stream.read(chunk_size)
        if not chunk:
            break
        for byte in chunk:
            if byte in ASCII_PRINTABLE_BYTES:
                current.append(chr(byte))
                continue
            if len(current) >= min_length:
                yield "".join(current)
            current = []
    if len(current) >= min_length:
        yield "".join(current)


def matched_bytecode_url_hints(url: str) -> List[str]:
    lowered = url.lower()
    return [hint for hint in BYTECODE_URL_HINTS if hint in lowered]


def suspicious_context_strings(strings: Sequence[str], index: int, *, window: int) -> List[str]:
    values: List[str] = []
    for offset in range(max(0, index - window), min(len(strings), index + window + 1)):
        if offset == index:
            continue
        candidate = strings[offset].strip()
        if not candidate or len(candidate) < 4:
            continue
        lowered = candidate.lower()
        if any(hint in lowered for hint in CONTEXT_HINTS):
            values.append(candidate[:240])
    deduped: List[str] = []
    seen: Set[str] = set()
    for item in values:
        if item in seen:
            continue
        seen.add(item)
        deduped.append(item)
    return deduped


def is_high_confidence_bytecode_url(url: str, neighbors: Sequence[str]) -> bool:
    lowered = url.lower()
    url_hints = matched_bytecode_url_hints(url)
    if url_hints:
        return True
    return any(any(hint in neighbor.lower() for hint in CONTEXT_HINTS) for neighbor in neighbors)


def record_bytecode_hit(
    report: BytecodeDigReport,
    *,
    source_archive: str,
    jar_path: str,
    class_path: str,
    depth: int,
    raw_string: str,
    strings: Sequence[str],
    string_index: int,
    seen: Set[Tuple[str, str, str]],
    context_window: int,
) -> None:
    for url in URL_RE.findall(raw_string):
        normalized = normalize_url(url)
        key = (normalized, jar_path, class_path)
        if key in seen:
            continue
        seen.add(key)
        neighbors = suspicious_context_strings(strings, string_index, window=context_window)
        hit = BytecodeUrlHit(
            url=normalized,
            source_archive=source_archive,
            jar_path=jar_path,
            class_path=class_path,
            depth=depth,
            matched_hints=matched_bytecode_url_hints(normalized),
            neighbor_strings=neighbors,
            raw_string=raw_string[:500],
        )
        report.all_http_hits.append(hit)
        if is_high_confidence_bytecode_url(normalized, neighbors):
            report.candidate_urls.append(hit)


def scan_class_file_for_urls(
    archive: zipfile.ZipFile,
    *,
    source_archive: str,
    jar_path: str,
    class_path: str,
    report: BytecodeDigReport,
    seen: Set[Tuple[str, str, str]],
    depth: int,
    min_length: int,
    context_window: int,
    max_class_bytes: int,
) -> None:
    info = archive.getinfo(class_path)
    if info.file_size > max_class_bytes:
        report.skipped_large_classes += 1
        return
    report.scanned_class_files += 1
    with archive.open(class_path, "r") as handle:
        strings = list(iter_ascii_strings_from_stream(handle, min_length=min_length))
    for index, raw_string in enumerate(strings):
        if "http" not in raw_string.lower():
            continue
        record_bytecode_hit(
            report,
            source_archive=source_archive,
            jar_path=jar_path,
            class_path=class_path,
            depth=depth,
            raw_string=raw_string,
            strings=strings,
            string_index=index,
            seen=seen,
            context_window=context_window,
        )


def scan_archive_for_bytecode(
    archive: zipfile.ZipFile,
    *,
    source_archive: str,
    container_path: str,
    report: BytecodeDigReport,
    seen: Set[Tuple[str, str, str]],
    depth: int,
    max_nested_archive_bytes: int,
    max_depth: int,
    min_string_length: int,
    context_window: int,
    max_class_bytes: int,
    count_as_jar: bool,
) -> None:
    report.scanned_archives += 1
    if count_as_jar:
        report.scanned_jar_files += 1
    for info in archive.infolist():
        if info.is_dir():
            continue
        entry_name = info.filename
        suffix = Path(entry_name).suffix.lower()
        if suffix == ".class":
            scan_class_file_for_urls(
                archive,
                source_archive=source_archive,
                jar_path=container_path,
                class_path=entry_name,
                report=report,
                seen=seen,
                depth=depth,
                min_length=min_string_length,
                context_window=context_window,
                max_class_bytes=max_class_bytes,
            )
            continue
        if depth >= max_depth:
            continue
        if suffix not in NESTED_ARCHIVE_SUFFIXES:
            continue
        if info.file_size > max_nested_archive_bytes:
            report.skipped_large_archives += 1
            continue
        try:
            nested_bytes = archive.read(entry_name)
            with zipfile.ZipFile(BytesIO(nested_bytes)) as nested_zip:
                nested_container = f"{container_path}!{entry_name}"
                scan_archive_for_bytecode(
                    nested_zip,
                    source_archive=source_archive,
                    container_path=nested_container,
                    report=report,
                    seen=seen,
                    depth=depth + 1,
                    max_nested_archive_bytes=max_nested_archive_bytes,
                    max_depth=max_depth,
                    min_string_length=min_string_length,
                    context_window=context_window,
                    max_class_bytes=max_class_bytes,
                    count_as_jar=suffix == ".jar",
                )
        except zipfile.BadZipFile:
            report.notes.append(f"跳过非标准字节码归档：{source_archive}!{entry_name}")


def write_bytecode_candidates(report: BytecodeDigReport, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_at": utc_now(),
        "output_path": str(output_path),
        "scanned_archives": report.scanned_archives,
        "scanned_jar_files": report.scanned_jar_files,
        "scanned_class_files": report.scanned_class_files,
        "skipped_large_archives": report.skipped_large_archives,
        "skipped_large_classes": report.skipped_large_classes,
        "all_http_hit_count": len(report.all_http_hits),
        "candidate_count": len(report.candidate_urls),
        "candidates": [asdict(item) for item in report.candidate_urls],
        "notes": report.notes,
    }
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def run_bytecode_sniff(
    *,
    resource_dir: Path,
    output_path: Path,
    max_nested_archive_bytes: int,
    max_depth: int,
    min_string_length: int,
    context_window: int,
    max_class_bytes: int,
) -> BytecodeDigReport:
    report = BytecodeDigReport(enabled=True, output_path=str(output_path))
    seen: Set[Tuple[str, str, str]] = set()
    for archive_path in iter_outer_archives(resource_dir):
        try:
            with zipfile.ZipFile(archive_path) as archive:
                scan_archive_for_bytecode(
                    archive,
                    source_archive=str(archive_path),
                    container_path=str(archive_path),
                    report=report,
                    seen=seen,
                    depth=0,
                    max_nested_archive_bytes=max_nested_archive_bytes,
                    max_depth=max_depth,
                    min_string_length=min_string_length,
                    context_window=context_window,
                    max_class_bytes=max_class_bytes,
                    count_as_jar=False,
                )
        except zipfile.BadZipFile:
            report.notes.append(f"坏压缩包，已跳过：{archive_path}")
    if not report.candidate_urls:
        report.notes.append("未在 JAR/.class 常量池中发现高置信度 Linux SDK 下载 URL")
    write_bytecode_candidates(report, output_path)
    return report


# -----------------------------
# 输出与 CLI
# -----------------------------

def write_report(report: ReconReport, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    payload = asdict(report)
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def print_summary(report: ReconReport) -> None:
    print(f"[compiler-recon] host={report.host.system}/{report.host.machine} archives={len(report.archives_scanned)} sdk_candidates={len(report.sdk_probes)}")
    for probe in report.sdk_probes:
        compiler = probe.compiler_executable or "(missing)"
        package_manager = probe.package_manager or "(missing)"
        formats = ", ".join(f"{item.path}:{item.binary_format}/{item.inferred_platform}" for item in probe.binary_probes) or "(none)"
        print(
            "[compiler-recon] "
            f"sdk={Path(probe.nested_sdk_archive).name} platform={probe.sdk_platform} compatible={probe.host_compatible} "
            f"cjc={compiler} cjpm={package_manager} formats={formats}"
        )
        for blocker in probe.blockers:
            print(f"[compiler-recon][blocker] {blocker}")
    if report.recommended_sdk:
        print(f"[compiler-recon] recommended_sdk={report.recommended_sdk}")
    else:
        print("[compiler-recon] recommended_sdk=(none)")
    for blocker in report.blockers:
        print(f"[compiler-recon][global-blocker] {blocker}")
    if report.extraction:
        print(f"[compiler-recon] extraction={json.dumps(report.extraction, ensure_ascii=False)}")
    if report.deep_dig.enabled:
        print(
            "[compiler-recon] "
            f"deep_dig scanned_archives={report.deep_dig.scanned_archives} scanned_entries={report.deep_dig.scanned_entries} "
            f"candidate_urls={len(report.deep_dig.candidate_urls)} all_urls={len(report.deep_dig.all_urls)} output={report.deep_dig.url_output_path}"
        )
        for note in report.deep_dig.notes[:5]:
            print(f"[compiler-recon][deep-dig-note] {note}")
    if report.bytecode_dig.enabled:
        print(
            "[compiler-recon] "
            f"bytecode_dig scanned_archives={report.bytecode_dig.scanned_archives} scanned_jars={report.bytecode_dig.scanned_jar_files} "
            f"scanned_classes={report.bytecode_dig.scanned_class_files} candidate_urls={len(report.bytecode_dig.candidate_urls)} output={report.bytecode_dig.output_path}"
        )
        for note in report.bytecode_dig.notes[:5]:
            print(f"[compiler-recon][bytecode-note] {note}")


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="探测 Cangjie 物理编译环境")
    parser.add_argument("--resource-dir", default=str(DEFAULT_RESOURCE_DIR), help="资源目录路径")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="侦察结果 JSON 输出路径")
    parser.add_argument("--extract-sdk-to", help="可选：把发现的 SDK 提取到指定目录")
    parser.add_argument("--sdk-substring", help="提取时按嵌套 SDK 文件名子串选择，例如 mac-arm")
    parser.add_argument(
        "--extract-scope",
        choices=["minimal", "toolchain"],
        default="minimal",
        help="SDK 提取范围：minimal 仅提取 cjc/cjpm 等入口；toolchain 提取更完整的 build-tools/runtime/modules",
    )
    parser.add_argument("--deep-dig", action="store_true", help="深挖插件文本资源与小型嵌套归档，猎取 Linux SDK 下载 URL")
    parser.add_argument("--linux-url-output", default=str(DEFAULT_LINUX_URL_OUTPUT), help="Deep Dig 发现的 URL 输出文件")
    parser.add_argument("--deep-dig-max-text-bytes", type=int, default=2 * 1024 * 1024, help="Deep Dig 单个文本条目最大扫描字节数")
    parser.add_argument("--deep-dig-max-archive-bytes", type=int, default=16 * 1024 * 1024, help="Deep Dig 单个嵌套归档最大扫描字节数")
    parser.add_argument("--deep-dig-max-depth", type=int, default=2, help="Deep Dig 递归扫描归档的最大深度")
    parser.add_argument("--bytecode-sniff", action="store_true", help="扫描 JAR/.class 常量池字符串，提取高置信度 URL")
    parser.add_argument("--jar-url-output", default=str(DEFAULT_JAR_URL_OUTPUT), help="Bytecode Sniff 输出 JSON 路径")
    parser.add_argument("--bytecode-max-archive-bytes", type=int, default=8 * 1024 * 1024, help="Bytecode Sniff 单个嵌套归档最大扫描字节数")
    parser.add_argument("--bytecode-max-depth", type=int, default=3, help="Bytecode Sniff 递归扫描归档最大深度")
    parser.add_argument("--bytecode-min-string-length", type=int, default=8, help="提取 .class 可打印字符串的最小长度")
    parser.add_argument("--bytecode-context-window", type=int, default=3, help="命中 URL 时回看相邻字符串的窗口大小")
    parser.add_argument("--bytecode-max-class-bytes", type=int, default=2 * 1024 * 1024, help="单个 .class 最大扫描字节数")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = parse_args(argv)
    resource_dir = Path(args.resource_dir).resolve()
    if not resource_dir.exists():
        raise SystemExit(f"资源目录不存在：{resource_dir}")
    report = inspect_resource_dir(resource_dir)
    if args.extract_sdk_to:
        report.extraction = extract_nested_sdk(
            report=report,
            output_dir=Path(args.extract_sdk_to).resolve(),
            sdk_substring=args.sdk_substring,
            extraction_scope=args.extract_scope,
        )
    if args.deep_dig:
        report.deep_dig = run_deep_dig(
            resource_dir=resource_dir,
            max_text_entry_bytes=args.deep_dig_max_text_bytes,
            max_nested_archive_bytes=args.deep_dig_max_archive_bytes,
            max_depth=args.deep_dig_max_depth,
            url_output_path=Path(args.linux_url_output).resolve(),
        )
    if args.bytecode_sniff:
        report.bytecode_dig = run_bytecode_sniff(
            resource_dir=resource_dir,
            output_path=Path(args.jar_url_output).resolve(),
            max_nested_archive_bytes=args.bytecode_max_archive_bytes,
            max_depth=args.bytecode_max_depth,
            min_string_length=args.bytecode_min_string_length,
            context_window=args.bytecode_context_window,
            max_class_bytes=args.bytecode_max_class_bytes,
        )
    write_report(report, Path(args.output).resolve())
    print_summary(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
