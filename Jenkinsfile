pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/yangxiangmin/cicd-test-new.git'
        BUILD_DIR = 'build'
        ARTIFACTS_DIR = 'artifacts'
        ARTIFACT_NAME = "math_ops-${new Date().format('yyyyMMdd')}.tar.gz"
        STAGING_SERVER = "user@staging-server"
        PROD_SERVER = "user@prod-server"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                     url: env.REPO_URL
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
                tar -czvf ${ARTIFACT_NAME} ${ARTIFACTS_DIR}
                '''
                archiveArtifacts artifacts: '*.tar.gz'
            }
        }

        stage('Deploy to Staging') {
            when { branch 'main' }
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'staging-key', 
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh """
                    scp -i $SSH_KEY ${ARTIFACT_NAME} ${STAGING_SERVER}:/opt/cicd_test_project/
                    ssh -i $SSH_KEY ${STAGING_SERVER} "
                        tar -xzvf /opt/cicd_test_project/${ARTIFACT_NAME} -C /opt/cicd_test_project/
                        chmod +x /opt/cicd_test_project/math_app
                    "
                    """
                }
            }
        }

        stage('Deploy to Production') {
            when { branch 'main' }
            steps {
                input(
                    message: '确认部署到生产环境?', 
                    ok: 'Yes',
                    timeout: time(minutes: 30)
                )
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'prod-key', 
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh """
                    scp -i $SSH_KEY ${ARTIFACT_NAME} ${PROD_SERVER}:/opt/cicd_test_project/
                    ssh -i $SSH_KEY ${PROD_SERVER} "
                        tar -xzvf /opt/cicd_test_project/${ARTIFACT_NAME} -C /opt/cicd_test_project/
                        systemctl restart cicd_test_project.service
                    "
                    """
                }
            }
        }
    }

    post {
        success {
            emailext body: '构建成功，项目：${BUILD_URL}',
                     subject: '构建成功通知',
                     to: '13826273737@139.com'
        }
        failure {
            emailext body: '构建失败，请检查日志：${BUILD_URL}console',
                     subject: '构建失败通知',
                     to: '13826273737@139.com'
        }
    }
}
