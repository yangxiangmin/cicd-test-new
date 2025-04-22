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
                echo "✅ 已完成代码检出！"
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
                echo "✅ 已完成编译！"
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
                echo "✅ 已完成测试！"
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
                echo "✅ 已完成打包！"
            }
        }

        stage('Deploy-Test') {
            // when { branch 'main' }
            steps {
            	sh 'echo "当前分支是：$(git rev-parse --abbrev-ref HEAD)"'
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'testenv', 
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
                echo "✅ 已部署到预发布环境！"
            }
        }

        stage('Deploy-Pro') {
            // when { branch 'main' }
            steps {
                sh 'echo "当前分支是：$(git rev-parse --abbrev-ref HEAD)"'
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'proenv', 
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
                echo "✅ 已部署到生产环境！"
            }
        }

/*
        stage('Deploy-Pro') {
            // 1. 添加 input 步骤，让用户确认是否部署
            steps {
                script {
                    // 显示当前分支（调试用）
                    sh 'echo "当前分支是：$(git rev-parse --abbrev-ref HEAD)"'

                    // 用户选择是否继续部署
                    def deployConfirm = input(
                        id: 'DeployConfirm',
                        message: '是否部署到生产环境？',
                        parameters: [
                            choice(
                                name: 'ACTION',
                                choices: ['no', 'yes'],
                                description: '选择操作'
                            )
                        ]
                    )

                    // 如果用户选择"确认部署"，则执行 sshPublisher
                    if (deployConfirm == 'yes') {
                        sshPublisher(
                            publishers: [
                                sshPublisherDesc(
                                    configName: 'proenv',
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
                        echo "✅ 已部署到生产环境！"
                    } else {
                        echo "❌ 用户取消部署到生产环境。"
                    }
                }
            }
        }
*/
    }

    post {
        failure {
            emailext body: '构建失败，请检查日志：${BUILD_URL}console',
                     subject: '构建失败通知',
                     to: '13826273737@139.com'
        }
    }
}
