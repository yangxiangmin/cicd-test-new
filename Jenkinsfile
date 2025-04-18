pipeline {
    agent any
    
    environment {
        // 基础配置
        REPO_URL = 'https://github.com/yangxiangmin/cicd-test.git'
        SCRIPTS_DIR = "${WORKSPACE}/scripts"  // 使用绝对路径
        BUILD_DIR = "${WORKSPACE}/build"
        ARTIFACTS_DIR = "${WORKSPACE}/artifacts"
        
        // 部署配置（按需修改）
        DEPLOY_SERVER = 'user@production-server'
        DEPLOY_PATH = '/opt/math_operations'
    }
    
    stages {
        // 阶段1：初始化环境
        stage('Initialize') {
            steps {
                script {
                    echo "🔧 ==== 初始化环境 ===="
                    
                    // 检出代码
                    git branch: 'main', 
                         url: env.REPO_URL,
                         poll: true  // 启用SCM轮询
                    
                    // 调试：显示目录结构
                    sh '''
                        echo "当前工作目录: ${WORKSPACE}"
                        echo "目录内容:"
                        ls -la
                    '''
                    
                    // 安全设置脚本权限（兼容各种Shell）
                    sh '''
                        if [ -d "scripts" ]; then
                            echo "设置脚本可执行权限:"
                            find scripts/ -name "*.sh" -type f -exec chmod +x {} \\;
                            ls -l scripts/
                        else
                            echo "❌ 错误：缺少scripts目录"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        // 阶段2：构建项目
        stage('Build') {
            steps {
                script {
                    echo "🏗️ ==== 开始构建 ===="
                    sh '''
                        # 调用构建脚本并捕获错误
                        if ! ./scripts/build.sh "${BUILD_DIR}"; then
                            echo "❌ 构建失败"
                            exit 1
                        fi
                        
                        # 验证构建产物
                        if [ ! -f "${BUILD_DIR}/math_app" ]; then
                            echo "❌ 错误：未生成可执行文件"
                            exit 1
                        fi
                    '''
                }
            }
            
            post {
                success {
                    echo "✅ 构建成功！生成的可执行文件："
                    sh "ls -lh ${BUILD_DIR}/math_app"
                }
            }
        }
        
        // 阶段3：运行测试
        stage('Test') {
            steps {
                script {
                    echo "🧪 ==== 开始测试 ===="
                    sh '''
                        # 运行测试脚本
                        ./scripts/test.sh "${BUILD_DIR}"
                        
                        # 生成JUnit报告（需CTest支持）
                        mkdir -p test-reports
                        xsltproc -o test-reports/test-report.xml \
                            scripts/ctest-to-junit.xsl \
                            "${BUILD_DIR}/Testing/$(head -n1 ${BUILD_DIR}/Testing/TAG)/Test.xml"
                    '''
                    
                    // 收集测试结果
                    junit 'test-reports/*.xml'
                }
            }
            
            post {
                always {
                    // 发布HTML测试报告（可选）
                    publishHTML target: [
                        allowMissing: true,
                        reportDir: 'test-reports',
                        reportFiles: 'test-report.xml',
                        reportName: '单元测试报告'
                    ]
                }
            }
        }
        
        // 阶段4：打包制品
        stage('Package') {
            steps {
                script {
                    echo "📦 ==== 打包制品 ===="
                    sh '''
                        mkdir -p "${ARTIFACTS_DIR}"
                        cp "${BUILD_DIR}/math_app" "${ARTIFACTS_DIR}/"
                        cp -r src "${ARTIFACTS_DIR}/"
                        cp -r tests "${ARTIFACTS_DIR}/"
                        
                        # 创建带版本号的压缩包
                        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                        tar -czvf "math_ops_${TIMESTAMP}.tar.gz" "${ARTIFACTS_DIR}"
                    '''
                }
            }
            
            post {
                success {
                    // 存档制品
                    archiveArtifacts artifacts: "math_ops_*.tar.gz", 
                                    fingerprint: true,
                                    onlyIfSuccessful: true
                    
                    // 保存版本信息
                    sh '''
                        echo "BUILD_VERSION=${TIMESTAMP}" > version.env
                    '''
                    archiveArtifacts 'version.env'
                }
            }
        }
        
        // 阶段5：部署（仅main分支触发）
        stage('Deploy') {
            when {
                branch 'main'
                expression { 
                    return env.BUILD_RESULT == null || env.BUILD_RESULT == 'SUCCESS' 
                }
            }
            
            steps {
                script {
                    echo "🚀 ==== 开始部署 ===="
                    sh '''
                        # 获取最新的制品包
                        DEPLOY_PKG=$(ls -t math_ops_*.tar.gz | head -n1)
                        
                        # 调用部署脚本
                        ./scripts/deploy.sh \
                            "${ARTIFACTS_DIR}" \
                            "${DEPLOY_SERVER}" \
                            "${DEPLOY_PATH}" \
                            "${DEPLOY_PKG}"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "🏁 ==== 构建结果：${currentBuild.currentResult} ===="
                
                // 清理工作空间（保留制品和报告）
                cleanWs(
                    cleanWhenAborted: true,
                    cleanWhenFailure: true,
                    cleanWhenSuccess: true,
                    deleteDirs: true,
                    patterns: [
                        [pattern: 'artifacts/**', type: 'EXCLUDE'],
                        [pattern: 'test-reports/**', type: 'EXCLUDE'],
                        [pattern: 'math_ops_*.tar.gz', type: 'EXCLUDE']
                    ]
                )
            }
        }
        
        failure {
            // 邮件通知
            emailext body: '''
            <h2>❌ 构建失败</h2>
            <p><b>项目：</b> ${JOB_NAME}</p>
            <p><b>构建号：</b> ${BUILD_NUMBER}</p>
            <p><b>失败阶段：</b> ${STAGE_NAME}</p>
            <p><b>日志：</b> <a href="${BUILD_URL}console">查看完整日志</a></p>
            ''',
            subject: '[CI] 构建失败: ${JOB_NAME} #${BUILD_NUMBER}',
            to: 'devops@example.com',
            mimeType: 'text/html'
        }
        
        success {
            // 成功通知（可选）
            slackSend color: 'good',
                     message: "✅ 构建成功: ${JOB_NAME} #${BUILD_NUMBER}\n${BUILD_URL}"
        }
    }
}