#!/bin/bash

# 严格模式
set -euo pipefail

# 参数处理
BUILD_DIR="${1:-build}"
REPORT_DIR="${2:-test-results}"

# 颜色定义
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== 测试配置 ===${NC}"
echo "构建目录: $BUILD_DIR"
echo "报告目录: $REPORT_DIR"
echo "Google Test版本: $(gtest-config --version)"

# 准备测试环境
mkdir -p "$REPORT_DIR"

# 执行测试
echo -e "${YELLOW}▶ 运行测试套件...${NC}"
cd "$BUILD_DIR"

# 配置CTest生成JUnit报告
export GTEST_OUTPUT="xml:../$REPORT_DIR/"

ctest \
    --output-on-failure \
    --no-compress-output \
    -T Test \
    --test-output-size-passed=1024 \
    --test-output-size-failed=2048

# 生成HTML报告（可选）
echo -e "${YELLOW}▶ 生成HTML报告...${NC}"
xsltproc \
    ../scripts/ctest-to-junit.xsl \
    Testing/$(head -n 1 Testing/TAG)/Test.xml \
    > "../$REPORT_DIR/test-report.html"

# 测试结果摘要
echo -e "${YELLOW}=== 测试结果摘要 ===${NC}"
grep -E '\[(PASSED|FAILED)\]' Testing/Temporary/LastTest.log || true

if grep -q 'FAILED' Testing/Temporary/LastTest.log; then
    echo -e "${RED}❌ 测试失败！${NC}"
    exit 1
else
    echo -e "${GREEN}✔ 所有测试通过！${NC}"
fi