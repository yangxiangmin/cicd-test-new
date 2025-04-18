pipeline {
    agent any
    
    environment {
        REPO_URL = 'https://github.com/yangxiangmin/cicd-test.git'
        BUILD_DIR = 'build'
        ARTIFACTS_DIR = 'artifacts'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: env.REPO_URL
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                mkdir -p ${BUILD_DIR}
                cd ${BUILD_DIR}
                cmake ..
                make
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                cd ${BUILD_DIR}
                ctest --output-on-failure
                '''
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                mkdir -p ${ARTIFACTS_DIR}
                cp ${BUILD_DIR}/math_app ${ARTIFACTS_DIR}/
                cp -r src ${ARTIFACTS_DIR}/
                cp -r tests ${ARTIFACTS_DIR}/
                tar -czvf math_operations.tar.gz ${ARTIFACTS_DIR}
                '''
            }
            
            post {
                success {
                    archiveArtifacts artifacts: 'math_operations.tar.gz', fingerprint: true
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                # 这里可以添加部署脚本，例如：
                # scp math_operations.tar.gz user@server:/path/to/deploy
                # 或者使用Docker构建和推送镜像
                echo "Deployment would happen here"
                
                # 简单示例 - 本地运行
                ./${BUILD_DIR}/math_app
                '''
            }
        }
    }
    
    post {
        always {
            junit '**/test-results.xml'  # 如果有生成JUnit格式的测试报告
            cleanWs()  # 清理工作空间
        }
        failure {
            emailext body: '构建失败，请检查: ${BUILD_URL}', subject: 'CI/CD Pipeline Failed', to: 'admin@example.com'
        }
    }
}