pipeline {

    agent {
        label 'docker-agent'
    }

    environment {
        IMAGE_NAME = 'jenkins-demo-app'
        CONTAINER_NAME = 'jenkins-demo-container'

        HOST_PORT = '5001'
        CONTAINER_PORT = '5000'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Environment') {
            steps {
                sh '''
                    echo "=== Agent ==="
                    hostname

                    echo "=== Python ==="
                    python3 --version

                    echo "=== Docker ==="
                    docker version
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    python3 -m venv venv

                    ./venv/bin/pip install \
                        --no-cache-dir \
                        -r requirements.txt

                    ./venv/bin/pytest -v
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                        -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                        .
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    sleep 3

                    curl -f \
                        http://host.docker.internal:${HOST_PORT}/health
                '''
            }
        }
    }

    post {

        success {
            echo '===================================='
            echo 'PIPELINE SUCCESS'
            echo '===================================='
        }

        failure {
            echo '===================================='
            echo 'PIPELINE FAILED'
            echo '===================================='
        }

        always {
            sh '''
                docker ps -a
            '''
        }
    }
}