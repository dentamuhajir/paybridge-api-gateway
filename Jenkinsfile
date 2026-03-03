pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy Gateway') {
            steps {
                sh "docker network create paybridge_network || true"

                sh "docker rm -f paybridge-gateway-svc || true"
                sh "docker rm -f swagger-ui || true"

                sh "docker compose down || true"
                sh "docker compose pull"
                sh "docker compose up -d"
            }
        }

        stage('Verification') {
            steps {
                echo "======== Verifying Gateway ========"
                sh "docker compose ps"
            }
        }
    }

    post {
        success {
            echo "Gateway Deployment Successful!"
        }
        failure {
            echo "Gateway Deployment Failed. Checking logs..."
            sh "docker compose logs --tail=20"
        }
    }
}