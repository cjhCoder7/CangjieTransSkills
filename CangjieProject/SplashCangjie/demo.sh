#!/bin/bash
# Splash 仓颉版 CLI 工具使用演示
# 用法: bash demo.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 查找仓颉运行时
RUNTIME_DIR="$(find "$HOME/.cangjie-sdk" -path "*/runtime/lib/darwin_aarch64_cjnative" 2>/dev/null | head -1)"
if [ -z "$RUNTIME_DIR" ]; then
    echo "错误: 未找到仓颉运行时库，请确认已安装仓颉 SDK"
    exit 1
fi
export DYLD_LIBRARY_PATH="$RUNTIME_DIR:$DYLD_LIBRARY_PATH"
export SDKROOT=$(xcrun --show-sdk-path 2>/dev/null || echo "")

# 查找 cjpm
CJPM="$(find "$HOME/.cangjie-sdk" -name "cjpm" -path "*/build-tools/tools/bin/cjpm" 2>/dev/null | head -1)"
if [ -z "$CJPM" ]; then
    echo "错误: 未找到 cjpm"
    exit 1
fi

# 构建
echo "正在构建..."
source "$(find "$HOME/.cangjie-sdk" -name "envsetup.sh" -path "*/build-tools/envsetup.sh" 2>/dev/null | head -1)" 2>/dev/null
cd "$SCRIPT_DIR" && cjpm build
echo "构建完成"
echo ""

BIN_DIR="$SCRIPT_DIR/target/release/bin"

# ========== splash_html_gen ==========
echo "===== splash_html_gen ====="

# 基本高亮
echo '$ splash_html_gen "class MyClass: Protocol { func hello() -> Int { return 7 } }"'
"$BIN_DIR/splash_html_gen" "class MyClass: Protocol { func hello() -> Int { return 7 } }"
echo ""

# import 语句
echo '$ splash_html_gen "import UIKit"'
"$BIN_DIR/splash_html_gen" "import UIKit"
echo ""

# 字符串和数字
echo '$ splash_html_gen "let name = \"Hello\""'
"$BIN_DIR/splash_html_gen" 'let name = "Hello"'
echo ""

# 注释
echo '$ splash_html_gen "// this is a comment"'
"$BIN_DIR/splash_html_gen" "// this is a comment"
echo ""

# 泛型类型
echo '$ splash_html_gen "Array<String>"'
"$BIN_DIR/splash_html_gen" "Array<String>"
echo ""

# ========== splash_tokenizer ==========
echo "===== splash_tokenizer ====="

# 函数声明
echo '$ splash_tokenizer "func hello(world: String) -> Int"'
"$BIN_DIR/splash_tokenizer" "func hello(world: String) -> Int"
echo ""

# 注释
echo '$ splash_tokenizer "// TODO: fix this"'
"$BIN_DIR/splash_tokenizer" "// TODO: fix this"
echo ""

# 属性和类型
echo '$ splash_tokenizer "object.property = Value()"'
"$BIN_DIR/splash_tokenizer" "object.property = Value()"
echo ""

# ========== splash_markdown ==========
echo "===== splash_markdown ====="

# 创建临时 Markdown 文件
TMPFILE=$(mktemp /tmp/splash_demo_XXXXXX.md)
cat > "$TMPFILE" <<'EOF'
# Swift 示例

下面是一段 Swift 代码：

```
struct Hello {
    var name: String
    func greet() -> String {
        return "Hi!"
    }
}
```

也可以跳过高亮：

```no-highlight
let x = 10
```
EOF

echo '$ splash_markdown <markdown文件路径>'
"$BIN_DIR/splash_markdown" "$TMPFILE"
rm -f "$TMPFILE"
echo ""

echo "===== 完成 ====="
