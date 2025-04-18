#!/bin/bash

# 严格模式
set -euo pipefail

# 参数处理
BUILD_DIR="${1:-build}"
BUILD_TYPE="${2:-Release}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function cleanup() {
    echo -e "${RED}⚠️ 构建过程被中断，正在清理...${NC}"
    rm -rf "$BUILD_DIR"
    exit 1
}

trap cleanup SIGINT SIGTERM

echo -e "${GREEN}=== 构建配置 ===${NC}"
echo "构建目录: $BUILD_DIR"
echo "构建类型: $BUILD_TYPE"
echo "CMake版本: $(cmake --version | head -n 1)"
echo "g++版本: $(g++ --version | head -n 1)"

# 创建构建目录
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${GREEN}▶ 创建构建目录...${NC}"
    mkdir -p "$BUILD_DIR"
fi

# 执行构建
echo -e "${GREEN}▶ 执行CMake配置...${NC}"
cd "$BUILD_DIR"
cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" ..

echo -e "${GREEN}▶ 编译项目...${NC}"
make -j$(nproc)

# 验证构建结果
if [ -f "math_app" ]; then
    echo -e "${GREEN}✔ 构建成功！生成的可执行文件:${NC}"
    ls -lh math_app
else
    echo -e "${RED}❌ 构建失败，未找到可执行文件${NC}"
    exit 1
fi