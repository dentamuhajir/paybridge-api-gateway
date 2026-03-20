pipeline { 
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_NAME = "dentamuhajir/paybridge-gateway-svc"
        IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        
        GITHUB_CREDENTIALS = credentials('github-credentials')
        MANIFEST_REPO_NAME = "paybridge-k8s-manifests"
        DEPLOYMENT_FILE = "base/applications/paybridge-api-gateway/deployment.yaml"
    }

    stages {
        // ==========================================
        // STAGE 1: Checkout Source Code
        // ==========================================
        stage('Checkout') {
            steps {
                echo "======== Checking out source code ========"
                checkout scm
            }
        }

        // ==========================================
        // STAGE 2: Build Docker Image
        // ==========================================
        stage('Build Image') {
            steps {
                echo "======== Building Docker Image with Tag: ${IMAGE_TAG} ========"
                sh """
                    DOCKER_BUILDKIT=1 docker build \
                        --no-cache \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest .
                """
            }
        }

        // ==========================================
        // STAGE 3: Push to Docker Hub
        // ==========================================
        stage('Push Image') {
            steps {
                echo "======== Pushing Image to Docker Hub ========"
                sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
                echo "======== Image pushed: ${IMAGE_NAME}:${IMAGE_TAG} ========"
            }
        }

        // ==========================================
        // STAGE 4: Update Manifest Repository
        // ==========================================
        stage('Update Manifest') {
            steps {
                echo "======== Updating manifest repository via Paybridge Bot ========"
                sh """
                    rm -rf ${MANIFEST_REPO_NAME}
                    git clone https://${GITHUB_CREDENTIALS_USR}:${GITHUB_CREDENTIALS_PSW}@github.com/dentamuhajir/paybridge-k8s-manifests.git
                    cd ${MANIFEST_REPO_NAME}

                    # Detect current branch (master/main)
                    CURRENT_BRANCH=\$(git rev-parse --abbrev-ref HEAD)

                    # Update image tag in the gateway deployment YAML
                    sed -i "s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" ${DEPLOYMENT_FILE}

                    # Configure Paybridge Bot (Linked to your Gravatar email)
                    git config user.email "bot@paybridge.dev"
                    git config user.name "Paybridge Bot"
                    
                    git add ${DEPLOYMENT_FILE}
                    
                    git commit -m "ci(deploy): bump paybridge-api-gateway image to ${IMAGE_TAG} [build #${BUILD_NUMBER}] [skip ci]"
                    
                    git push origin \$CURRENT_BRANCH
                    echo "======== Manifest updated to ${IMAGE_TAG} and pushed! ========"
                """
            }
        }
    }

    post {
        success {
            echo "======== CI Successful for Gateway! ========"
            echo "Deployment Version : ${IMAGE_TAG}"
        }
        failure {
            echo "======== CI Failed! Check the logs above. ========"
        }
        always {
            // Cleanup to save disk space on Jenkins node
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
            sh "docker rmi ${IMAGE_NAME}:latest || true"
            sh "docker logout || true"
            sh "rm -rf ${MANIFEST_REPO_NAME} || true"
        }
    }
}