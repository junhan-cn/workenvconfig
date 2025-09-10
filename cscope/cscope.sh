#!/bin/bash

# 用法: ./cscope.sh [源码路径]
SRC_PATH="${1:-$(pwd)}"
OUT_DIR="${SRC_PATH}/cscope_out"

mkdir -p "$OUT_DIR"

echo "正在搜索源码文件..."
find "$SRC_PATH" \
    -type f \( -name "*.h" -o -name "*.hpp" -o -name "*.c" -o -name "*.cc" -o -name "*.cpp" -o -name "*.S" \) \
    > "$OUT_DIR/cscope.files"

echo "正在生成 cscope 数据库..."
cscope -bkq -i "$OUT_DIR/cscope.files" -f "$OUT_DIR/cscope.out"

echo "正在生成 ctags 标签..."
ctags -R -f "$OUT_DIR/tags" "$SRC_PATH"

echo "完成！数据库和标签文件已生成