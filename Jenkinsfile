pipeline {

    agent any

    environment {
        IMAGE_NAME = "jenkins-demo-app"
        TEST_IMAGE = "jenkins-demo-app-test"
        CONTAINER_NAME = "jenkins-demo-container"

        HOST_PORT = "5001"
        CONTAINER_PORT = "5000"
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
                    docker build \
                        -t ${TEST_IMAGE}:${BUILD_NUMBER} \
                        --target test \
                        .

                    docker run --rm \
                        ${TEST_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }


        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                        -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                        -t ${IMAGE_NAME}:latest \
                        --target runtime \
                        .
                '''
            }
        }


        stage('Run Container') {
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

                    docker exec ${CONTAINER_NAME} \
                        python -c "
import urllib.request
response = urllib.request.urlopen(
    'http://localhost:${CONTAINER_PORT}/health'
)
print(response.read().decode())
"
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