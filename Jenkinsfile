pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/yangxiangmin/cicd-test-new.git'
        BUILD_DIR = 'build'
        ARTIFACTS_DIR = 'artifacts'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                     url: env.REPO_URL,
                     poll: true
            }
        }

        stage('Build') {
            steps {
                sh '''
                mkdir -p ${BUILD_DIR}
                cd ${BUILD_DIR}
                cmake -DCMAKE_CXX_STANDARD=11 ..
#                make -j$(nproc)
                make
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                # 确保在构建目录
                cd ${BUILD_DIR}
                
                # 清理旧报告
                rm -f test-results.xml
                
                # 执行测试（绝对路径+指定报告路径）
                ./tests/math_test --gtest_output="xml:${BUILD_DIR}/test-results.xml"
                
                # 验证报告
                if [ ! -f "test-results.xml" ]; then
                    echo "❌ 错误：测试报告未生成"
                    exit 1
                fi
                '''
                
                junit "${BUILD_DIR}/test-results.xml"
            }
        }

        stage('Package') {
            steps {
                sh '''
                mkdir -p ${ARTIFACTS_DIR}
                cp ${BUILD_DIR}/math_app ${ARTIFACTS_DIR}/
                tar -czvf math_ops-$(date +%Y%m%d).tar.gz ${ARTIFACTS_DIR}
                '''
                archiveArtifacts artifacts: '*.tar.gz'
            }
        }

        stage('Deploy') {
            when { branch 'main' }
            steps {
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'prod_server',
                            transfers: [
                                sshTransfer(
                                    sourceFiles: 'math_ops-*.tar.gz',
                                    remoteDirectory: '/opt/math_ops',
                                    execCommand: '''
                                    tar -xzvf /opt/math_ops/math_ops-*.tar.gz -C /opt/math_ops
                                    '''
                                )
                            ]
                        )
                    ]
                )
            }
        }
    }

    post {
        failure {
            emailext body: '构建失败，请检查日志：${BUILD_URL}console',
                     subject: '构建失败通知',
                     to: 'dev@example.com'
        }
    }
}