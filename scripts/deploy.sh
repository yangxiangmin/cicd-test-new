#!/bin/bash

set -e

ARTIFACT="math_operations.tar.gz"
TARGET_SERVER="user@example.com"
TARGET_PATH="/opt/math_operations"

# 打包
tar -czvf $ARTIFACT build/math_app src tests

# 部署到目标服务器
scp $ARTIFACT $TARGET_SERVER:$TARGET_PATH

# 在目标服务器上解压和设置
ssh $TARGET_SERVER "cd $TARGET_PATH && tar -xzvf $ARTIFACT && chmod +x math_app"