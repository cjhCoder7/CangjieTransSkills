# -*- coding: utf-8 -*-
"""HarmonyOS UI 状态采集 + 逐步交互脚本

用法:
    # 基础采集（截图 + 控件树）
    python ui_capture.py [--bundle BUNDLE] [--ability ABILITY] [--out DIR] [--no-launch]
    python ui_capture.py --emulator 5555

    # 单步动作（执行后重新采集截图）
    python ui_capture.py --emulator 5555 --no-launch --do click --target '{"text":"下一步"}'
    python ui_capture.py --emulator 5555 --no-launch --do input --target '{"hint":"Message"}' --input-text "Hello"

功能:
    1. 检测设备连接（支持 USB 物理设备和本地模拟器）
    2. 安装并启动应用（可选）
    3. 截屏 + dump 控件树
    4. 解析控件树输出结构化摘要
    5. 单步交互：点击/输入/滑动/返回，执行后立即重新采集

原理:
    直接调用 hdc 命令行工具完成采集与交互，不依赖 Hypium 测试框架
    hdc (HarmonyOS Device Connector) 是鸿蒙的设备调试桥，类似 Android 的 adb
    串联流程: 连接 → 启动 → 基线采集 → 交互 → 二次采集 → 差异分析
"""

import argparse
import json
import os
import re
import shlex
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Tuple



# 全局设备 target（-t 参数），为空时不加 -t
_device_target: Optional[str] = None


def _hdc_cmd(*args: str) -> List[str]:
    """构建 hdc 命令列表，自动加 -t <device> 前缀"""
    cmd = ["hdc"]
    if _device_target:
        cmd.extend(["-t", _device_target])
    cmd.extend(args)
    return cmd


def run(cmd: List[str], timeout: int = 30) -> str:
    """执行命令（列表形式，shell=False），返回合并的 stdout+stderr"""
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return (r.stdout + r.stderr).strip()
    except FileNotFoundError:
        return f"[ERROR] 命令未找到: {cmd[0]}"
    except subprocess.TimeoutExpired:
        return f"[ERROR] 命令超时 ({timeout}s): {' '.join(cmd)}"


def _ensure_hdc_in_path() -> None:
    """确保 hdc 可用，不在 PATH 时自动从 DevEco Studio 路径检测"""
    # 已经可用则直接返回
    if _is_cmd_available("hdc"):
        return

    # 搜索候选路径
    candidates = []

    # 1. 从项目 .env 读取 DEVECO_HOME
    env_file = Path.cwd() / ".env"
    if env_file.exists():
        for line in env_file.read_text(encoding="utf-8").splitlines():
            if line.strip().startswith("DEVECO_HOME"):
                val = line.split("=", 1)[1].strip().strip("'\"")
                hdc_path = Path(val) / "sdk" / "default" / "openharmony" / "toolchains"
                if hdc_path.exists():
                    candidates.append(str(hdc_path))

    # 2. macOS 常见路径
    mac_path = Path("/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains")
    if mac_path.exists():
        candidates.append(str(mac_path))

    # 3. 用户目录下的 SDK
    user_sdk = Path.home() / "Library" / "Huawei" / "Sdk" / "openharmony" / "toolchains"
    if user_sdk.exists():
        candidates.append(str(user_sdk))

    for candidate in candidates:
        hdc_bin = Path(candidate) / "hdc"
        if hdc_bin.exists():
            os.environ["PATH"] = candidate + os.pathsep + os.environ.get("PATH", "")
            print(f"[OK] 已自动检测 hdc: {hdc_bin}")
            return

    print("[ERROR] 未找到 hdc 命令。请确认 DevEco Studio 已安装，或将 hdc 所在目录加入 PATH。")
    print("  macOS 典型路径: /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/")
    sys.exit(1)


def _is_cmd_available(cmd: str) -> bool:
    """检查命令是否可执行"""
    try:
        subprocess.run([cmd, "version"], capture_output=True, timeout=5)
        return True
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def connect_emulator(addr: str) -> str:
    """通过 hdc tconn 连接本地模拟器，返回目标地址"""
    if addr.isdigit():
        addr = f"127.0.0.1:{addr}"
    elif ":" not in addr:
        addr = f"{addr}:5555"
    print(f"[INFO] 连接模拟器: {addr} ...")
    out = run(["hdc", "tconn", addr])
    print(f"  {out}")
    if "Connect OK" in out or "already connected" in out.lower():
        print(f"[OK] 模拟器已连接: {addr}")
        return addr
    targets_out = run(["hdc", "list", "targets"])
    if addr in targets_out:
        print(f"[OK] 模拟器已连接: {addr}")
        return addr
    print(f"[ERROR] 模拟器连接失败，hdc tconn 输出: {out}")
    sys.exit(1)


def check_device(emulator_addr: Optional[str] = None) -> str:
    """检查 hdc 设备连接，返回设备 SN / 地址

    若指定 emulator_addr，先执行 tconn 连接模拟器
    """
    if emulator_addr:
        return connect_emulator(emulator_addr)
    out = run(["hdc", "list", "targets"])
    targets = [t.strip() for t in out.splitlines() if t.strip() and "Empty" not in t]
    if not targets:
        print("[ERROR] 未检测到已连接的 HarmonyOS 设备。")
        print("  物理设备: 请确认 USB 连接和 hdc 环境")
        print("  模拟器:   请使用 --emulator <port> 参数（如 --emulator 5555）")
        sys.exit(1)
    sn = targets[0]
    print(f"[OK] 设备已连接: {sn}")
    return sn


def install_hap(hap_path: str):
    """安装 hap 包到设备，检查安装结果"""
    if hap_path and os.path.isfile(hap_path):
        print(f"[INFO] 安装 {hap_path} ...")
        out = run(_hdc_cmd("install", "-r", hap_path))
        print(f"  {out}")
        if "Success" in out or "success" in out.lower():
            print("[OK] 安装成功")
        elif "error" in out.lower() or "fail" in out.lower():
            print(f"[WARN] 安装可能失败，请检查输出")


def launch_app(bundle: str, ability: str):
    """启动应用"""
    print(f"[INFO] 启动 {bundle}/{ability} ...")
    run(_hdc_cmd("shell", "aa", "start", "-a", ability, "-b", bundle))
    time.sleep(3)


def capture_screenshot(out_dir: str) -> str:
    """截取设备屏幕并拉取到本地，依次尝试多种截图方式"""
    # 截图前等待 1 秒，避免动画/过渡未完成导致截图状态不稳定
    time.sleep(1)
    local_path = os.path.join(out_dir, "screenshot.png")
    device_path = "/data/local/tmp/_ui_capture_screen.png"

    # (方法名, hdc 命令列表, 是否在输出含 error 时跳过)
    methods = [
        ("snapshot_display", _hdc_cmd("shell", "snapshot_display", "-f", device_path), True),
        ("uitest screenCap", _hdc_cmd("shell", "uitest", "screenCap", "-p", device_path), False),
        ("screencap", _hdc_cmd("shell", "screencap", "-p", device_path), False),
    ]
    for name, cmd, skip_on_error in methods:
        out = run(cmd)
        if skip_on_error and "error" in out.lower():
            continue
        run(_hdc_cmd("file", "recv", device_path, local_path))
        run(_hdc_cmd("shell", "rm", "-f", device_path))
        if os.path.isfile(local_path) and os.path.getsize(local_path) > 0:
            print(f"[OK] 截图已保存({name}): {local_path}")
            return local_path

    print("[WARN] 截图拉取失败（已尝试 snapshot_display / uitest screenCap / screencap）")
    return local_path


def dump_layout(out_dir: str) -> str:
    """Dump 控件树并拉取到本地"""
    device_json = "/data/local/tmp/_ui_capture_layout.json"
    local_path = os.path.join(out_dir, "layout.json")
    run(_hdc_cmd("shell", "uitest", "dumpLayout", "-p", device_json))
    run(_hdc_cmd("file", "recv", device_json, local_path))
    run(_hdc_cmd("shell", "rm", device_json))
    if os.path.isfile(local_path):
        print(f"[OK] 控件树已保存: {local_path}")
    else:
        print("[WARN] 控件树拉取失败")
    return local_path


def detect_project_info(project_dir: str) -> tuple:
    """从鸿蒙项目目录自动检测 bundleName 和 abilityName

    搜索 AppScope/app.json5 获取 bundleName，
    搜索 entry/src/main/module.json5 获取第一个 ability 的 name
    返回 (bundle_name, ability_name)，检测失败返回 (None, None)
    """
    bundle_name = None
    ability_name = None

    # 读取 bundleName
    app_json = os.path.join(project_dir, "AppScope", "app.json5")
    if os.path.isfile(app_json):
        try:
            content = Path(app_json).read_text(encoding="utf-8")
            # json5 可能有注释和尾逗号，用正则提取
            m = re.search(r'"bundleName"\s*:\s*"([^"]+)"', content)
            if m:
                bundle_name = m.group(1)
                print(f"[OK] 检测到 bundleName: {bundle_name}")
        except Exception as e:
            print(f"[WARN] 读取 {app_json} 失败: {e}")

    # 读取 abilityName
    module_json = os.path.join(project_dir, "entry", "src", "main", "module.json5")
    if os.path.isfile(module_json):
        try:
            content = Path(module_json).read_text(encoding="utf-8")
            m = re.search(r'"name"\s*:\s*"(\w*Ability\w*)"', content)
            if m:
                ability_name = m.group(1)
                print(f"[OK] 检测到 abilityName: {ability_name}")
        except Exception as e:
            print(f"[WARN] 读取 {module_json} 失败: {e}")

    return bundle_name, ability_name


def find_project_dir() -> Optional[str]:
    """向上搜索鸿蒙项目根目录（含 AppScope/ 的目录）

    从当前工作目录开始，逐级向上查找
    """
    cwd = Path.cwd()
    # 先检查当前目录
    if (cwd / "AppScope").is_dir():
        return str(cwd)
    # 向上最多搜索 10 级
    for parent in list(cwd.parents)[:10]:
        if (parent / "AppScope").is_dir():
            return str(parent)
    return None


def filter_tree_by_bundle(tree: dict, bundle: str) -> list:
    """从完整控件树中提取属于指定 bundleName 的子树"""
    results = []
    children = tree.get("children", []) if isinstance(tree, dict) else tree
    for child in children:
        attrs = child.get("attributes", {})
        if attrs.get("bundleName") == bundle:
            results.append(child)
        else:
            # 递归查找（系统窗口可能包裹应用窗口）
            results.extend(filter_tree_by_bundle(child, bundle))
    return results


def summarize_layout(layout_path: str, out_dir: str, bundle: Optional[str] = None) -> str:
    """解析控件树 JSON，生成可读文本摘要

    若指定 bundle，只分析属于该应用的子树
    """
    summary_path = os.path.join(out_dir, "ui_summary.md")
    if not os.path.isfile(layout_path):
        return summary_path

    with open(layout_path, "r", encoding="utf-8") as f:
        try:
            tree = json.load(f)
        except json.JSONDecodeError:
            print("[WARN] 控件树 JSON 解析失败")
            return summary_path

    # 按 bundle 过滤，只分析目标应用的控件
    if bundle:
        app_trees = filter_tree_by_bundle(tree, bundle)
        if app_trees:
            print(f"[OK] 已过滤控件树，仅保留 {bundle} 的 {len(app_trees)} 个窗口")
        else:
            print(f"[WARN] 未找到 bundleName={bundle} 的控件，将分析全量控件树")
            app_trees = [tree] if isinstance(tree, dict) else tree
    else:
        app_trees = [tree] if isinstance(tree, dict) else tree

    lines = [f"# UI 控件树摘要\n"]
    if bundle:
        lines.append(f"**应用**: `{bundle}`\n")
    stats = {"total": 0, "types": {}, "texts": [], "keys": [], "hints": [],
             "clickable": 0, "scrollable": 0, "max_depth": 0,
             "element_sizes": [], "clickable_sizes": [],
             "text_element_sizes": [], "sibling_gaps": [],
             "screen_bounds": None}

    def walk(node, depth=0):
        attrs = _get_attrs(node)

        stats["total"] += 1
        if depth > stats["max_depth"]:
            stats["max_depth"] = depth

        comp_type = attrs.get("type", "") or "Unknown"
        stats["types"][comp_type] = stats["types"].get(comp_type, 0) + 1

        text = attrs.get("text", "")
        key = attrs.get("key", "")
        hint = attrs.get("hint", "")
        if text:
            stats["texts"].append(text)
        if key:
            stats["keys"].append(key)
        if hint:
            stats["hints"].append(hint)
        if attrs.get("clickable") == "true":
            stats["clickable"] += 1
        if attrs.get("scrollable") == "true":
            stats["scrollable"] += 1

        # 解析 bounds 提取尺寸信息
        bounds = _parse_bounds(attrs.get("bounds", ""))
        size_label = ""
        if bounds:
            x1, y1, x2, y2 = bounds
            w, h = x2 - x1, y2 - y1
            if w > 0 and h > 0:
                stats["element_sizes"].append((comp_type, w, h))
                size_label = f" {w}×{h}"
        # 记录屏幕级边界
                if stats["screen_bounds"] is None:
                    stats["screen_bounds"] = (x1, y1, x2, y2)
                else:
                    sb = stats["screen_bounds"]
                    stats["screen_bounds"] = (
                        min(sb[0], x1), min(sb[1], y1),
                        max(sb[2], x2), max(sb[3], y2))
                # 可点击控件尺寸
                if attrs.get("clickable") == "true":
                    stats["clickable_sizes"].append((comp_type, w, h, text or key or hint))
                # 有文本的控件尺寸，用于字体大小推断
                if text:
                    stats["text_element_sizes"].append((text, w, h))

        indent = "  " * depth
        label = comp_type
        if size_label:
            label += size_label
        if text:
            label += f' text="{text}"'
        if hint:
            label += f' hint="{hint}"'
        if key:
            label += f' key="{key}"'
        if attrs.get("clickable") == "true":
            label += " [clickable]"
        lines.append(f"{indent}- {label}")

        # 计算同级子元素间的间距
        children = node.get("children", [])
        child_bounds_list = []
        for child in children:
            child_attrs = _get_attrs(child)
            cb = _parse_bounds(child_attrs.get("bounds", ""))
            if cb:
                child_bounds_list.append(cb)
        # 按纵向排序，计算相邻元素垂直间距
        child_bounds_list.sort(key=lambda b: b[1])
        for i in range(1, len(child_bounds_list)):
            gap = child_bounds_list[i][1] - child_bounds_list[i - 1][3]
            if gap >= 0:  # 只记录非重叠的间距
                stats["sibling_gaps"].append(gap)

        for child in children:
            walk(child, depth + 1)

    for subtree in app_trees:
        walk(subtree)

    lines.append(f"\n## 统计")
    lines.append(f"- 控件总数: {stats['total']}")
    lines.append(f"- 可点击: {stats['clickable']}")
    lines.append(f"- 可滚动: {stats['scrollable']}")
    lines.append(f"- 最大嵌套深度: {stats['max_depth']}")
    lines.append(f"- 控件类型分布:")
    for t, c in sorted(stats["types"].items(), key=lambda x: -x[1]):
        lines.append(f"  - {t}: {c}")
    if stats["texts"]:
        lines.append(f"- 文本内容: {stats['texts']}")
    if stats["hints"]:
        lines.append(f"- Hint 提示: {stats['hints']}")
    if stats["keys"]:
        lines.append(f"- Key 标识: {stats['keys']}")

    # === 视觉审美量化数据 ===
    lines.append(f"\n## 视觉审美分析数据")

    # 屏幕利用率
    if stats["screen_bounds"] and stats["element_sizes"]:
        sb = stats["screen_bounds"]
        screen_w = sb[2] - sb[0]
        screen_h = sb[3] - sb[1]
        screen_area = screen_w * screen_h
        lines.append(f"\n### 屏幕信息")
        lines.append(f"- 屏幕尺寸: {screen_w}×{screen_h} px")
        if screen_area > 0:
            # 叶子节点面积粗估
            leaf_area = sum(w * h for _, w, h in stats["element_sizes"]
                           if w < screen_w and h < screen_h)
            utilization = min(leaf_area / screen_area * 100, 100)
            lines.append(f"- 屏幕利用率（估算）: {utilization:.1f}%")

    # 可点击控件尺寸检查
    if stats["clickable_sizes"]:
        lines.append(f"\n### 可点击控件尺寸")
        small_touch = []
        for comp_type, w, h, identifier in stats["clickable_sizes"]:
            if w < 48 or h < 48:
                small_touch.append(f"{comp_type}({identifier}) {w}×{h}")
        if small_touch:
            lines.append(f"- ⚠️ 触控区域过小（<48px）: {small_touch}")
        else:
            lines.append(f"- OK all clickable controls size >= 48px")
        sizes_summary = [(f"{ct}({ident})", w, h)
                         for ct, w, h, ident in stats["clickable_sizes"]]
        lines.append(f"- 尺寸列表: {sizes_summary}")

    # 文本控件尺寸（辅助判断字体大小）
    if stats["text_element_sizes"]:
        lines.append(f"\n### 文本控件尺寸")
        tiny_text = []
        for text_val, w, h in stats["text_element_sizes"]:
            if h < 20:  # 高度过小的文本区域，可能字体过小
                tiny_text.append(f'"{text_val}" h={h}')
        if tiny_text:
            lines.append(f"- ⚠️ 高度过小的文本控件（h<20px，可能字体过小）: {tiny_text}")
        else:
            lines.append(f"- OK all text controls height >= 20px")
        lines.append(f"- 文本控件高度分布: {sorted(set(h for _, _, h in stats['text_element_sizes']))}")

    # 间距一致性分析
    if stats["sibling_gaps"]:
        gaps = stats["sibling_gaps"]
        avg_gap = sum(gaps) / len(gaps)
        min_gap = min(gaps)
        max_gap = max(gaps)
        lines.append(f"\n### 间距分析")
        lines.append(f"- 同级元素垂直间距: 最小={min_gap}px, 最大={max_gap}px, 平均={avg_gap:.1f}px")
        if max_gap > 0 and min_gap >= 0:
            if min_gap == 0 and max_gap > 0:
                lines.append(f"- ⚠️ 间距不一致: 存在 0px 间距与 {max_gap}px 间距并存")
            elif max_gap > min_gap * 3 and min_gap > 0:
                lines.append(f"- ⚠️ 间距差异较大: 最大/最小比值 = {max_gap / min_gap:.1f}x")
            else:
                lines.append(f"- OK spacing looks consistent")
        # 大间距区域（可能是过度留白）
        large_gaps = [g for g in gaps if g > 100]
        if large_gaps:
            lines.append(f"- ⚠️ 存在 {len(large_gaps)} 处大间距（>100px）: {sorted(large_gaps, reverse=True)[:5]}")

    # 控件尺寸分布
    if stats["element_sizes"]:
        widths = [w for _, w, _ in stats["element_sizes"] if w > 0]
        heights = [h for _, _, h in stats["element_sizes"] if h > 0]
        if widths and heights:
            lines.append(f"\n### 控件尺寸分布")
            lines.append(f"- 宽度范围: {min(widths)}–{max(widths)}px, 中位数={sorted(widths)[len(widths)//2]}px")
            lines.append(f"- 高度范围: {min(heights)}–{max(heights)}px, 中位数={sorted(heights)[len(heights)//2]}px")

    with open(summary_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"[OK] 摘要已保存: {summary_path}")
    return summary_path


# ============================================================
# 公共工具
# ============================================================

def _get_attrs(node: dict) -> dict:
    """从节点提取属性字典，兼容 hdc dumpLayout 两种格式"""
    attrs = node.get("attributes", {})
    if not attrs and "type" in node:
        return node
    return attrs


def _flatten_tree(node: dict) -> List[dict]:
    """将嵌套控件树扁平化为节点列表"""
    nodes = [_get_attrs(node)]
    for child in node.get("children", []):
        nodes.extend(_flatten_tree(child))
    return nodes


def _parse_bounds(bounds_str: str) -> Optional[Tuple[int, int, int, int]]:
    """解析 bounds 字符串 '[x1,y1][x2,y2]' → (x1, y1, x2, y2)"""
    m = re.findall(r'\[(\d+),(\d+)\]', bounds_str or "")
    if len(m) == 2:
        return int(m[0][0]), int(m[0][1]), int(m[1][0]), int(m[1][1])
    return None


def _center_of(bounds: Tuple[int, int, int, int]) -> Tuple[int, int]:
    """返回 bounds 的中心坐标"""
    return (bounds[0] + bounds[2]) // 2, (bounds[1] + bounds[3]) // 2


def _safe_load_flat(path: str) -> List[dict]:
    """安全加载 JSON 控件树并扁平化为节点列表"""
    if not os.path.isfile(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        tree = json.load(f)
    return _flatten_tree(tree)


# ============================================================
# 交互引擎
# ============================================================


def find_target_node(flat_nodes: List[dict], target: dict) -> Optional[dict]:
    """从扁平节点列表中根据 target 描述查找匹配节点

    target 支持的匹配键（按优先级）:
    - x, y: 直接坐标，不做节点查找
    - key: 精确匹配控件 key
    - text: 精确匹配或包含匹配控件 text
    - type + index: 按控件类型 + 索引（默认 0）
    - hint: 精确匹配 hint 文本
    """
    if "x" in target and "y" in target:
        return {"_direct_coords": (int(target["x"]), int(target["y"]))}

    # 按 key 匹配
    if "key" in target:
        for n in flat_nodes:
            if n.get("key") == target["key"]:
                return n

    # 按 text 匹配
    if "text" in target:
        t = target["text"]
        # 先精确匹配
        for n in flat_nodes:
            if n.get("text") == t:
                return n
        # 再包含匹配
        for n in flat_nodes:
            if t in (n.get("text") or ""):
                return n

    # 按 type + index 匹配
    if "type" in target:
        idx = target.get("index", 0)
        matches = [n for n in flat_nodes if n.get("type") == target["type"]]
        if 0 <= idx < len(matches):
            return matches[idx]

    # 按 hint 匹配
    if "hint" in target:
        for n in flat_nodes:
            if n.get("hint") == target["hint"]:
                return n

    return None


def _get_node_coords(node: dict) -> Optional[Tuple[int, int]]:
    """从节点获取中心点坐标"""
    if not node:
        return None
    if "_direct_coords" in node:
        return node["_direct_coords"]
    bounds = _parse_bounds(node.get("bounds", ""))
    if bounds:
        return _center_of(bounds)
    return None


def _get_screen_size(flat_nodes: List[dict]) -> Tuple[int, int]:
    """从控件树推断屏幕尺寸"""
    max_x, max_y = 1080, 2340  # 默认值
    for n in flat_nodes:
        bounds = _parse_bounds(n.get("bounds", ""))
        if bounds:
            max_x = max(max_x, bounds[2])
            max_y = max(max_y, bounds[3])
    return max_x, max_y


def _swipe_coords(direction: str, screen_w: int, screen_h: int
                  ) -> Tuple[int, int, int, int]:
    """根据方向关键字计算滑动起止坐标"""
    cx, cy = screen_w // 2, screen_h // 2
    dist = screen_h // 3
    mapping = {
        "up":    (cx, cy + dist, cx, cy - dist),
        "down":  (cx, cy - dist, cx, cy + dist),
        "left":  (cx + dist, cy, cx - dist, cy),
        "right": (cx - dist, cy, cx + dist, cy),
    }
    return mapping.get(direction, mapping["up"])


def execute_step(step: dict, flat_nodes: List[dict], screen_w: int, screen_h: int,
                 out_dir: str, step_idx: int, bundle: Optional[str] = None) -> dict:
    """执行单个交互步骤，返回执行结果"""
    action = step.get("action", "")
    result = {"action": action, "success": False, "detail": "", "snapshot": None}

    if action == "wait":
        seconds = step.get("seconds", 2)
        print(f"  [STEP {step_idx}] 等待 {seconds}s ...")
        time.sleep(seconds)
        result["success"] = True
        result["detail"] = f"等待 {seconds}s"
        return result

    if action == "back":
        print(f"  [STEP {step_idx}] 模拟返回键")
        out = run(_hdc_cmd("shell", "uitest", "uiInput", "keyEvent", "2"))
        result["success"] = True
        result["detail"] = f"返回键: {out}"
        return result

    if action == "home":
        print(f"  [STEP {step_idx}] 模拟 Home 键")
        out = run(_hdc_cmd("shell", "uitest", "uiInput", "keyEvent", "1"))
        result["success"] = True
        result["detail"] = f"Home 键: {out}"
        return result

    if action == "snapshot":
        label = step.get("label", f"step_{step_idx}")
        snap_dir = os.path.join(out_dir, f"snapshot_{label}")
        os.makedirs(snap_dir, exist_ok=True)
        capture_screenshot(snap_dir)
        layout_path = dump_layout(snap_dir)
        summarize_layout(layout_path, snap_dir, bundle=bundle)
        print(f"  [STEP {step_idx}] 中间快照: {snap_dir}")
        result["success"] = True
        result["detail"] = f"快照保存至 {snap_dir}"
        result["snapshot"] = snap_dir
        return result

    # 需要目标坐标的操作
    target = step.get("target", {})

    if action in ("swipe", "fling"):
        if "from" in step and "to" in step:
            x1, y1 = int(step["from"]["x"]), int(step["from"]["y"])
            x2, y2 = int(step["to"]["x"]), int(step["to"]["y"])
        elif "direction" in step:
            x1, y1, x2, y2 = _swipe_coords(step["direction"], screen_w, screen_h)
        else:
            result["detail"] = "swipe/fling 需要 direction 或 from/to"
            return result
        speed = step.get("speed", 600)
        if action == "fling":
            step_len = step.get("stepLen", 50)
            cmd = _hdc_cmd("shell", "uitest", "uiInput", "fling", str(x1), str(y1), str(x2), str(y2), str(step_len), str(speed))
        else:
            cmd = _hdc_cmd("shell", "uitest", "uiInput", "swipe", str(x1), str(y1), str(x2), str(y2), str(speed))
        print(f"  [STEP {step_idx}] {action}: ({x1},{y1}) → ({x2},{y2})")
        out = run(cmd)
        result["success"] = True
        result["detail"] = f"{action} ({x1},{y1})→({x2},{y2}): {out}"
        return result

    if action in ("click", "long_click", "double_click", "input"):
        node = find_target_node(flat_nodes, target)
        if not node:
            result["detail"] = f"未找到目标控件: {target}"
            print(f"  [STEP {step_idx}] FAIL {result['detail']}")
            return result
        coords = _get_node_coords(node)
        if not coords:
            result["detail"] = f"无法获取控件坐标: {target}"
            print(f"  [STEP {step_idx}] FAIL {result['detail']}")
            return result
        x, y = coords

        cmd = []

        if action == "click":
            cmd = _hdc_cmd("shell", "uitest", "uiInput", "click", str(x), str(y))
            print(f"  [STEP {step_idx}] 点击 ({x}, {y}) target={target}")
        elif action == "double_click":
            cmd = _hdc_cmd("shell", "uitest", "uiInput", "dblClick", str(x), str(y))
            print(f"  [STEP {step_idx}] 双击 ({x}, {y}) target={target}")
        elif action == "long_click":
            duration = step.get("duration", 1500)
            cmd = _hdc_cmd("shell", "uitest", "uiInput", "longClick", str(x), str(y), str(duration))
            print(f"  [STEP {step_idx}] 长按 ({x}, {y}) duration={duration}ms target={target}")
        elif action == "input":
            text = step.get("text", "")
            # 先点击激活输入框，再输入文本
            run(_hdc_cmd("shell", "uitest", "uiInput", "click", str(x), str(y)))
            time.sleep(0.5)
            cmd = _hdc_cmd("shell", "uitest", "uiInput", "inputText", text)
            print(f"  [STEP {step_idx}] 输入 \"{text}\" @ ({x}, {y}) target={target}")

        out = run(cmd)
        result["success"] = True
        result["detail"] = f"{action} ({x},{y}): {out}"
        return result

    result["detail"] = f"未知操作: {action}"
    print(f"  [STEP {step_idx}] FAIL {result['detail']}")
    return result


def _refresh_step_layout(out_dir: str) -> tuple:
    """重新 dump 控件树并返回 (flat_nodes, screen_w, screen_h)"""
    device_json = "/data/local/tmp/_ui_interact_layout.json"
    local_tmp = os.path.join(out_dir, "_tmp_layout.json")
    run(_hdc_cmd("shell", "uitest", "dumpLayout", "-p", device_json))
    run(_hdc_cmd("file", "recv", device_json, local_tmp))
    run(_hdc_cmd("shell", "rm", "-f", device_json))

    flat_nodes = []
    screen_w, screen_h = 1080, 2340
    if os.path.isfile(local_tmp):
        try:
            with open(local_tmp, "r", encoding="utf-8") as f:
                tree = json.load(f)
            flat_nodes = _flatten_tree(tree)
            screen_w, screen_h = _get_screen_size(flat_nodes)
        except json.JSONDecodeError:
            print("  [WARN] 控件树解析失败，使用默认屏幕尺寸")
    return flat_nodes, screen_w, screen_h


def find_latest_hap(project_dir: str) -> Optional[str]:
    """在项目构建产物目录中查找最新的 .hap 文件"""
    search_dir = Path(project_dir) / "entry" / "build"
    if not search_dir.exists():
        return None
    haps = sorted(search_dir.rglob("*.hap"), key=lambda p: p.stat().st_mtime, reverse=True)
    if haps:
        print(f"[OK] 自动发现 HAP: {haps[0]}")
        return str(haps[0])
    return None


def capture_hilog(out_dir: str, bundle: str, duration: int = 5) -> str:
    """捕获 HiLog 日志并保存"""
    log_path = os.path.join(out_dir, "hilog.txt")
    print(f"[INFO] 捕获 HiLog ({duration}s)...")
    out = run(_hdc_cmd("shell", "hilog", "-T", f"'{bundle}'", "-t", str(duration)), timeout=duration + 10)
    if "[ERROR]" in out or not out:
        # 降级：不过滤，直接抓全部日志
        out = run(_hdc_cmd("shell", "hilog", "-x"), timeout=duration + 10)
    with open(log_path, "w", encoding="utf-8") as f:
        f.write(out)
    print(f"[OK] HiLog 已保存: {log_path}")
    return log_path


def main():
    parser = argparse.ArgumentParser(description="HarmonyOS UI 状态采集 + 自动交互验证")
    parser.add_argument("--project", default=None, help="鸿蒙项目目录（含 AppScope/），不指定则自动向上搜索")
    parser.add_argument("--bundle", default=None, help="应用包名（不指定则从项目目录自动检测）")
    parser.add_argument("--ability", default=None, help="Ability 名称（不指定则从项目目录自动检测）")
    parser.add_argument("--hap", default="", help="HAP 安装包路径（可选）")
    parser.add_argument("--auto-hap", action="store_true", help="自动搜索项目构建产物中最新的 .hap 文件并安装")
    parser.add_argument("--out", default="./ui_capture_output", help="输出目录")
    parser.add_argument("--no-launch", action="store_true", help="跳过启动应用（已在前台时使用）")
    parser.add_argument("--wait", type=int, default=3, help="启动后等待秒数")
    parser.add_argument("--emulator", default=None, metavar="ADDR",
                        help="模拟器地址（端口号如 5555，或完整地址如 127.0.0.1:5555）")
    parser.add_argument("--device", "-t", default=None, metavar="SN",
                        help="指定目标设备 SN（多设备连接时使用）")
    parser.add_argument("--do", default=None, metavar="ACTION",
                        help="执行单个动作后重新采集截图（click/input/swipe/fling/back/home/long_click/double_click）")
    parser.add_argument("--target", default=None, metavar="JSON",
                        help="--do 的目标控件，JSON 字符串，如 '{\"text\":\"下一步\"}' 或 '{\"type\":\"TextInput\",\"index\":0}'")
    parser.add_argument("--input-text", default=None, metavar="TEXT",
                        help="--do input 时要输入的文本")
    parser.add_argument("--swipe-dir", default=None, metavar="DIR",
                        help="--do swipe/fling 的方向（up/down/left/right）")
    parser.add_argument("--wait-after", type=float, default=1.5, metavar="SEC",
                        help="--do 执行后等待秒数（默认 1.5），让界面完成刷新再采集")
    parser.add_argument("--hilog", action="store_true", help="采集期间同时抓取 HiLog 日志")
    parser.add_argument("--timestamp", action="store_true", help="输出目录名追加时间戳，防止覆盖")
    parser.add_argument("--no-screenshot", action="store_true",
                        help="跳过截图采集，仅产出控件树与文本摘要（纯文本模型或不需要视觉确认时使用）")
    args = parser.parse_args()

    # === 确保 hdc 可用 ===
    _ensure_hdc_in_path()

    # === 设备选择 ===
    global _device_target
    if args.device:
        _device_target = args.device

    # === 输出目录时间戳 ===
    if args.timestamp:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        args.out = f"{args.out}_{ts}"

    # === 自动检测项目信息 ===
    project_dir = args.project
    if not project_dir:
        project_dir = find_project_dir()
    if project_dir:
        print(f"[OK] 鸿蒙项目目录: {project_dir}")
        detected_bundle, detected_ability = detect_project_info(project_dir)
        if not args.bundle and detected_bundle:
            args.bundle = detected_bundle
        if not args.ability and detected_ability:
            args.ability = detected_ability
    else:
        print("[WARN] 未找到鸿蒙项目目录（AppScope/），将使用命令行参数")

    if not args.bundle:
        print("[ERROR] 无法确定应用包名。请用 --bundle 指定，或在鸿蒙项目目录下运行。")
        sys.exit(1)
    if not args.ability:
        print("[ERROR] 无法确定 Ability 名称。请用 --ability 指定。")
        sys.exit(1)

    print(f"[INFO] 目标应用: {args.bundle} / {args.ability}")

    os.makedirs(args.out, exist_ok=True)
    check_device(args.emulator)

    # === HAP 安装 ===
    hap_path = args.hap
    if not hap_path and args.auto_hap and project_dir:
        hap_path = find_latest_hap(project_dir)
    if hap_path:
        install_hap(hap_path)

    if not args.no_launch:
        launch_app(args.bundle, args.ability)
        if args.wait > 0:
            print(f"[INFO] 等待 {args.wait}s 界面加载...")
            time.sleep(args.wait)

    # === Phase 1: 基线采集（交互前） ===
    print(f"\n{'='*50}")
    print("Phase 1: 基线采集")
    print(f"{'='*50}")
    if args.no_screenshot:
        print("[INFO] --no-screenshot 启用，跳过截图采集（纯文本模式）")
        screenshot_path = None
    else:
        screenshot_path = capture_screenshot(args.out)
    layout_path = dump_layout(args.out)
    summary_path = summarize_layout(layout_path, args.out, bundle=args.bundle)

    # HiLog 采集
    if args.hilog:
        capture_hilog(args.out, args.bundle)

    print(f"\n  采集完成: {args.out}")
    if screenshot_path:
        print(f"    截图: {screenshot_path}")
    print(f"    控件树: {layout_path}")
    print(f"    摘要: {summary_path}")

    # === 单步动作模式（--do） ===
    exit_code = 0
    if args.do:
        action = args.do
        step: dict = {"action": action}
        if args.target:
            try:
                step["target"] = json.loads(args.target)
            except json.JSONDecodeError as e:
                print(f"[ERROR] --target 不是合法 JSON: {e}")
                sys.exit(1)
        if args.input_text:
            step["text"] = args.input_text
        if args.swipe_dir:
            step["direction"] = args.swipe_dir

        print(f"\n{'='*50}")
        print(f"执行单步动作: {action}")
        print(f"{'='*50}")

        flat_nodes, screen_w, screen_h = _refresh_step_layout(args.out)
        r = execute_step(step, flat_nodes, screen_w, screen_h, args.out, 1, bundle=args.bundle)

        if r["success"]:
            print(f"[OK] {action}: {r['detail']}")
        else:
            print(f"[FAIL] {action}: {r['detail']}")
            exit_code = 1

        if action not in ("wait", "snapshot", "back", "home"):
            print(f"[INFO] 等待 {args.wait_after}s 界面刷新...")
            time.sleep(args.wait_after)

        print(f"\n{'='*50}")
        print("执行后采集")
        print(f"{'='*50}")
        if not args.no_screenshot:
            capture_screenshot(args.out)
        new_layout = dump_layout(args.out)
        summarize_layout(new_layout, args.out, bundle=args.bundle)

        tmp_file = os.path.join(args.out, "_tmp_layout.json")
        if os.path.isfile(tmp_file):
            os.remove(tmp_file)

        print(f"\n{'='*50}")
        print(f"单步完成！结果: {'成功' if r['success'] else '失败'}")
        if not args.no_screenshot:
            print(f"  截图: {args.out}/screenshot.png")
        print(f"  控件树: {args.out}/layout.json")
        print(f"  摘要: {args.out}/ui_summary.md")
        print(f"{'='*50}")
        sys.exit(exit_code)

    print(f"\n{'='*50}")
    print(f"基础采集完成！")
    print(f"{'='*50}")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
