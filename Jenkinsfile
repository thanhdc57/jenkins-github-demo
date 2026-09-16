pipeline {

    agent any

    environment {
        IMAGE_NAME = 'jenkins-demo-app'
        CONTAINER_NAME = 'jenkins-demo-app'
        HOST_PORT = '5001'
        CONTAINER_PORT = '5000'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker run --rm \
                        -v "$WORKSPACE:/app" \
                        -w /app \
                        python:3.12-slim \
                        sh -c "
                            pip install --no-cache-dir -r requirements.txt &&
                            pytest -v
                        "
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
                    sleep 5

                    curl -f \
                        http://host.docker.internal:${HOST_PORT}/health

                    echo "Health check passed."
                '''
            }
        }
    }

    post {

        success {
            echo '===================================='
            echo 'PIPELINE SUCCESS'
            echo 'Application deployed successfully'
            echo '===================================='
        }

        failure {
            echo '===================================='
            echo 'PIPELINE FAILED'
            echo 'Check the stage logs'
            echo '===================================='
        }

        always {
            sh 'docker ps || true'
        }
    }
}