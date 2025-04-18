#!/bin/bash

# 严格模式
set -euo pipefail

# 参数处理
ARTIFACTS_DIR="${1:-artifacts}"
TARGET_SERVER="${2:-user@production-server}"
DEPLOY_PATH="${3:-/opt/math_operations}"

# 颜色定义
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function validate_ssh() {
    if ! ssh -q -o BatchMode=yes -o ConnectTimeout=5 "$TARGET_SERVER" exit; then
        echo -e "${RED}❌ SSH验证失败，无法连接到${TARGET_SERVER}${NC}"
        exit 1
    fi
}

echo -e "${BLUE}=== 部署配置 ===${NC}"
echo "发布物目录: $ARTIFACTS_DIR"
echo "目标服务器: $TARGET_SERVER"
echo "部署路径: $DEPLOY_PATH"

# 验证部署包
if [ ! -f "$ARTIFACTS_DIR/math_app" ]; then
    echo -e "${RED}❌ 错误：未找到可执行文件${NC}"
    exit 1
fi

# 验证SSH连接
echo -e "${BLUE}▶ 验证服务器连接...${NC}"
validate_ssh

# 创建部署包
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEPLOY_PACKAGE="math_ops_${TIMESTAMP}.tar.gz"

echo -e "${BLUE}▶ 创建部署包...${NC}"
tar -czvf "$DEPLOY_PACKAGE" -C "$ARTIFACTS_DIR" .

# 传输部署包
echo -e "${BLUE}▶ 传输到目标服务器...${NC}"
scp "$DEPLOY_PACKAGE" "$TARGET_SERVER:$DEPLOY_PATH"

# 执行远程部署
echo -e "${BLUE}▶ 执行远程部署...${NC}"
ssh "$TARGET_SERVER" "
    set -e
    echo '解压部署包...'
    cd '$DEPLOY_PATH'
    tar -xzvf '$DEPLOY_PACKAGE'
    
    echo '设置执行权限...'
    chmod +x math_app
    
    echo '验证版本...'
    ./math_app --version || true
    
    echo '清理旧部署包...'
    rm -f '$DEPLOY_PACKAGE'
    
    echo '! 部署完成 !'
"

echo -e "${GREEN}✔ 成功部署到 $TARGET_SERVER:$DEPLOY_PATH ${NC}"