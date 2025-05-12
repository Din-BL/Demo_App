pipeline {
    agent { label 'aws-dynamic-agent' }

    environment {
        SLACK_TOKEN     = credentials('Slack_Token')
        SONARQUBE_URL   = credentials('SonarQube_URL')
        SONARQUBE_TOKEN = credentials('SonarQube-Token')
    }

    stages {
        stage('Retrieve Latest Git Tag') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Fetching the latest Git Tag...'
                    withCredentials([usernamePassword(credentialsId: 'Gitlab_Access', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh '''
                            git config --local credential.helper '!f() { echo username=$GIT_USERNAME; echo password=$GIT_PASSWORD; }; f'
                            git fetch --tags --depth=1
                        '''
                        env.IMAGE_TAG = sh(script: "git describe --tags --abbrev=0", returnStdout: true).trim()
                        echo "Latest Git Tag: ${env.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Parallel Tasks') {
            parallel {
                stage('SonarQube Analysis') {
                    steps {
                        echo 'Running SonarQube analysis...'
                        withSonarQubeEnv('SonarQube') {
                            script {
                                def scannerHome = tool 'SonarScanner'
                                sh """
                                    ${scannerHome}/bin/sonar-scanner \\
                                        -Dsonar.projectKey=Demo-App \\
                                        -Dsonar.sources=. \\
                                        -Dsonar.host.url=${SONARQUBE_URL} \\
                                        -Dsonar.token=${SONARQUBE_TOKEN}
                                """
                            }
                        }
                    }
                }

                stage('Test') {
                    steps {
                        echo 'Running tests...'
                        sh '''
                            npm ci
                            npm test
                        '''
                    }
                }
            }
        }

        stage('Build') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Building Docker image...'
                    sh """
                        docker build -t dinbl/demo_app:${env.IMAGE_TAG} .
                        docker tag dinbl/demo_app:${env.IMAGE_TAG} dinbl/demo_app:latest
                    """
                }
            }
        }

        stage('Security Scan with Snyk') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo 'Running security scan with Snyk...'
                    withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                        sh 'snyk auth $SNYK_TOKEN'
                    }
                    def snykStatus = sh(script: "snyk container test dinbl/demo_app:${env.IMAGE_TAG} --severity-threshold=critical --file=Dockerfile", returnStatus: true)
                    if (snykStatus != 0) {
                        echo "Snyk found critical vulnerabilities. Review and address them."
                        currentBuild.result = 'UNSTABLE'
                    } else {
                        echo "No critical vulnerabilities found by Snyk."
                    }
                }
            }
        }

        stage('Push to ECR') {
    when {
        branch 'main'
    }
    steps {
        script {
            echo 'Pushing image to ECR...'
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS_Credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                // Get AWS account ID
                def awsAccountId = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
                def awsRegion = 'us-east-1' 
                
                // ECR repository name
                def ecrRepo = 'demo-app'
                
                // ECR login
                sh "aws ecr get-login-password --region ${awsRegion} | docker login --username AWS --password-stdin ${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com"
                
                // Tag the image for ECR
                sh "docker tag dinbl/demo_app:${env.IMAGE_TAG} ${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${ecrRepo}:${env.IMAGE_TAG}"
                sh "docker tag dinbl/demo_app:latest ${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${ecrRepo}:latest"
                
                // Push the image to ECR
                sh "docker push ${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${ecrRepo}:${env.IMAGE_TAG}"
                sh "docker push ${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${ecrRepo}:latest"
                
                echo "Image pushed to ECR: ${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/${ecrRepo}:${env.IMAGE_TAG}"
            }
        }
    }
}
    }

    post {
        success {
            script {
                echo 'Pipeline completed successfully.'
                if (env.BRANCH_NAME && !env.BRANCH_NAME.startsWith('feature')) {
                    updateHelmChart(env.IMAGE_TAG)
                    sendSlackNotification("Pipeline completed successfully. Image tag: ${env.IMAGE_TAG}")
                } else {
                    sendSlackNotification("Pipeline completed successfully.")
                }
            }
        }
        failure {
            script {
                echo 'Pipeline failed.'
                if (env.BRANCH_NAME && !env.BRANCH_NAME.startsWith('feature')) {
                    sendSlackNotification("Pipeline failed. Image tag: ${env.IMAGE_TAG}")
                } else {
                    sendSlackNotification("Pipeline failed.")
                }
            }
        }
    }
}

def updateHelmChart(imageTag) {
    withCredentials([usernamePassword(credentialsId: 'Gitlab_Access', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
        sh """
            git clone http://${GIT_USERNAME}:${GIT_PASSWORD}@10.0.11.60/root/manifests.git
            cd manifests
            sed -i 's/tag: .*/tag: ${imageTag}/g' values.yaml
            git config user.name "Din"
            git config user.email "Dinz5005@gmail.com"
            git add .
            git commit -m "Update Docker image tag to ${imageTag}"
            git push http://${GIT_USERNAME}:${GIT_PASSWORD}@10.0.11.60/root/manifests.git main
        """
    }
}

def sendSlackNotification(message) {
    withCredentials([string(credentialsId: 'Slack_Token', variable: 'SLACK_TOKEN')]) {
        slackSend(
            channel: '#cicd-project',
            message: message,
            token: SLACK_TOKEN
        )
    }
}
