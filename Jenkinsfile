pipeline {
    agent any
    
    environment {
        // 基础配置
        REPO_URL = 'https://github.com/yangxiangmin/cicd-test.git'
        SCRIPTS_DIR = 'scripts'
        BUILD_DIR = 'build'
        ARTIFACTS_DIR = 'artifacts'
        
        // 部署配置（实际使用时替换为真实值）
        DEPLOY_SERVER = 'user@production-server'
        DEPLOY_PATH = '/opt/math_operations'
    }
    
    stages {
        stage('Initialize') {
            steps {
                script {
                    echo "▄︻デ══━ 启动 CI/CD 流程 ══━︻▄"
                    echo "工作目录: ${WORKSPACE}"
                }
                
                // 检出代码并设置脚本权限
                git branch: 'main', url: env.REPO_URL
                sh 'chmod +x ${SCRIPTS_DIR}/*.sh'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "▄︻デ══━ 构建阶段开始 ══━︻▄"
                    sh './${SCRIPTS_DIR}/build.sh ${BUILD_DIR}'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "▄︻デ══━ 测试阶段开始 ══━︻▄"
                    sh './${SCRIPTS_DIR}/test.sh ${BUILD_DIR}'
                    
                    // 收集测试结果（需确保CTest生成JUnit报告）
                    junit allowEmptyResults: true, 
                        testResults: '${BUILD_DIR}/Testing/**/Test.xml'
                }
            }
            
            post {
                always {
                    // 生成HTML测试报告（可选）
                    publishHTML target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '${BUILD_DIR}/Testing/html',
                        reportFiles: 'index.html',
                        reportName: 'GTest Report'
                    ]
                }
            }
        }
        
        stage('Package') {
            steps {
                script {
                    echo "▄︻デ══━ 打包阶段开始 ══━︻▄"
                    sh '''
                    mkdir -p ${ARTIFACTS_DIR}
                    cp ${BUILD_DIR}/math_app ${ARTIFACTS_DIR}/
                    cp -r src ${ARTIFACTS_DIR}/
                    cp -r tests ${ARTIFACTS_DIR}/
                    tar -czvf math_operations.tar.gz ${ARTIFACTS_DIR}
                    '''
                }
            }
            
            post {
                success {
                    archiveArtifacts artifacts: 'math_operations.tar.gz', 
                                    fingerprint: true,
                                    onlyIfSuccessful: true
                }
            }
        }
        
        stage('Deploy') {
            when {
                // 只有main分支触发部署
                branch 'main'
            }
            steps {
                script {
                    echo "▄︻デ══━ 部署阶段开始 ══━︻▄"
                    sh './${SCRIPTS_DIR}/deploy.sh ${ARTIFACTS_DIR} ${DEPLOY_SERVER} ${DEPLOY_PATH}'
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "▄︻デ══━ 构建结果: ${currentBuild.currentResult} ══━︻▄"
                
                // 清理工作空间（保留关键文件）
                cleanWs(
                    cleanWhenAborted: true,
                    cleanWhenFailure: true,
                    cleanWhenNotBuilt: true,
                    cleanWhenSuccess: true,
                    deleteDirs: true,
                    patterns: [
                        [pattern: '.gitignore', type: 'INCLUDE'],
                        [pattern: 'artifacts/', type: 'EXCLUDE'],
                        [pattern: 'build/', type: 'EXCLUDE']
                    ]
                )
            }
        }
        
        failure {
            emailext body: '''
            <h2>❌ 构建失败</h2>
            <p>项目: ${JOB_NAME}</p>
            <p>构建号: ${BUILD_NUMBER}</p>
            <p>原因: ${currentBuild.result}</p>
            <p>详情: <a href="${BUILD_URL}">${BUILD_URL}</a></p>
            ''', 
            subject: '🚨 CI/CD 失败告警: ${JOB_NAME} #${BUILD_NUMBER}',
            to: 'dev-team@example.com',
            mimeType: 'text/html'
        }
    }
}