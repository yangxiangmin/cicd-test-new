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
                make
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                cd ${BUILD_DIR}
                ./tests/math_test --gtest_output="xml:${WORKSPACE}/${BUILD_DIR}/test-results.xml"
                ls -l "${WORKSPACE}/${BUILD_DIR}/test-results.xml" || echo "❌ 报告生成失败"
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
                sh 'ls -l *.tar.gz'  // 检查文件是否生成
                archiveArtifacts artifacts: '*.tar.gz'
            }
        }

        stage('Deploy') {
#            when { branch 'main' }
            steps {
            	sh 'echo "当前分支是：$(git rev-parse --abbrev-ref HEAD)"'
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'outer-test', 
                            transfers: [
                                sshTransfer(
                                    sourceFiles: 'math_ops-*.tar.gz',
                                    removePrefix: '',
                                    remoteDirectory: '/opt/math_ops',
                                    execCommand: '''
                                        cd /opt/math_ops && \
                                        tar -xzvf math_ops-*.tar.gz && \
                                        rm -f math_ops-*.tar.gz
                                    '''
                                )
                            ],
                            usePromotionTimestamp: false,
                            useWorkspaceInPromotion: false,
                            verbose: true
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
                     to: '13826273737@139.com'
        }
    }
}
