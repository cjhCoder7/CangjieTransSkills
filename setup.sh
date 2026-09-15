#!/bin/sh

set -eu

print_usage() {
    printf '%s\n' \
        "用法: ./setup.sh [--no-deep] [--skip-loopx] [目标项目路径]" \
        "" \
        "安装 LoopX，并将 CangjieTransSkills 安装到目标项目。" \
        "目标项目缺省为当前工作目录。" \
        "" \
        "环境变量:" \
        "  CANGJIE_SETUP_PYTHON  指定 Python 3.11+ 解释器"
}

setup_no_deep=0
setup_skip_loopx=0
setup_target=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            print_usage
            exit 0
            ;;
        --no-deep)
            setup_no_deep=1
            ;;
        --skip-loopx)
            setup_skip_loopx=1
            ;;
        --)
            shift
            if [ "$#" -gt 0 ]; then
                setup_target="$1"
                shift
            fi
            if [ "$#" -gt 0 ]; then
                printf '%s\n' "错误：只能指定一个目标项目路径。" >&2
                exit 2
            fi
            break
            ;;
        -*)
            printf '%s\n' "错误：未知参数 $1" >&2
            print_usage >&2
            exit 2
            ;;
        *)
            if [ -n "$setup_target" ]; then
                printf '%s\n' "错误：只能指定一个目标项目路径。" >&2
                exit 2
            fi
            setup_target="$1"
            ;;
    esac
    shift
done

if [ -z "$setup_target" ]; then
    setup_target="$PWD"
fi

setup_dir=$(dirname "$0")
case "$setup_dir" in
    /*) ;;
    *) setup_dir="./$setup_dir" ;;
esac
setup_root=$(CDPATH= cd "$setup_dir" && pwd -P)
setup_python="${CANGJIE_SETUP_PYTHON:-}"

is_supported_python() {
    "$1" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)' \
        >/dev/null 2>&1
}

if [ -n "$setup_python" ]; then
    if ! is_supported_python "$setup_python"; then
        printf '%s\n' \
            "错误：CANGJIE_SETUP_PYTHON 必须指向可用的 Python 3.11+ 解释器。" >&2
        exit 3
    fi
else
    for setup_candidate in python3.13 python3.12 python3.11 python3; do
        setup_candidate_path=$(command -v "$setup_candidate" 2>/dev/null || true)
        if [ -n "$setup_candidate_path" ] && is_supported_python "$setup_candidate_path"; then
            setup_python="$setup_candidate_path"
            break
        fi
    done
fi

if [ -z "$setup_python" ]; then
    printf '%s\n' "错误：未找到 Python 3.11+。" >&2
    printf '%s\n' \
        "安装后重试，或设置 CANGJIE_SETUP_PYTHON=/path/to/python3.11。" >&2
    exit 3
fi

if [ "$setup_skip_loopx" -eq 1 ]; then
    exec "$setup_python" "$setup_root/scripts/setup_loopx.py" \
        --skip-loopx \
        --target-project "$setup_target"
fi

if [ "$setup_no_deep" -eq 1 ]; then
    exec "$setup_python" "$setup_root/scripts/setup_loopx.py" \
        --install \
        --target-project "$setup_target" \
        --no-deep
fi

exec "$setup_python" "$setup_root/scripts/setup_loopx.py" \
    --install \
    --target-project "$setup_target"
