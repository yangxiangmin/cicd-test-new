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
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [[$class: 'CleanBeforeCheckout']],
                    userRemoteConfigs: [[url: env.REPO_URL]]
                ])
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                mkdir -p ${BUILD_DIR}
                cd ${BUILD_DIR}
                cmake -DCMAKE_BUILD_TYPE=Release ..
                make -j$(nproc)
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                cd ${BUILD_DIR}
                ctest --output-on-failure --no-compress-output -T Test
                
                # 生成JUnit报告
                mkdir -p test-reports
                xsltproc -o test-reports/results.xml \
                    ../scripts/ctest-to-junit.xsl \
                    Testing/$(head -n1 Testing/TAG)/Test.xml
                '''
                junit 'test-reports/*.xml'
            }
            
            post {
                always {
                    publishHTML target: [
                        reportDir: 'test-reports',
                        reportFiles: 'results.xml',
                        reportName: 'Math Test Report'
                    ]
                }
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                mkdir -p ${ARTIFACTS_DIR}
                cp ${BUILD_DIR}/math_app ${ARTIFACTS_DIR}/
                cp -r src ${ARTIFACTS_DIR}/
                tar -czvf math_ops-$(date +%Y%m%d).tar.gz ${ARTIFACTS_DIR}
                '''
                archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
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
                                    removePrefix: '',
                                    remoteDirectory: '/opt/math_ops',
                                    execCommand: '''
                                    tar -xzvf /opt/math_ops/math_ops-*.tar.gz -C /opt/math_ops
                                    chmod +x /opt/math_ops/math_app
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
            emailext body: '''
            <h2>Build Failed</h2>
            <p>Project: ${JOB_NAME}</p>
            <p>Build: ${BUILD_NUMBER}</p>
            <p>Logs: <a href="${BUILD_URL}console">${BUILD_URL}</a></p>
            ''', 
            subject: '[CI] Math Ops Build Failure',
            to: 'dev@example.com'
        }
    }
}