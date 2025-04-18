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
                make -j$(nproc)
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                cd ${BUILD_DIR}
                # 生成报告并验证
                ./math_test --gtest_output="xml:test-results.xml"
                ls -l test-results.xml || echo "❌ 错误：测试报告未生成"
                '''
                // 使用绝对路径收集报告
                junit '${BUILD_DIR}/test-results.xml'
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