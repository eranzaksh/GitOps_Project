pipeline {
    
    environment {
        GIT_COMMIT = ''
        ARGOCD_SERVER = 'eranargocd.duckdns.org:443'
        DOMAINS="eranargocd,eranapp,erangrafana"
        TOKEN = credentials('duckdns-token') 
        DUCKDNS_URL="https://www.duckdns.org/update?domains=${DOMAINS}&token=${TOKEN}"
    }


    agent {
        docker {
            label 'eee'
            image "eranzaksh/jenkins-agent:python"
            args '-u 0:0 -v /var/run/docker.sock:/var/run/docker.sock'
            alwaysPull true
        }
    }

    stages {
        stage("Clone Git Repository") {
            steps {
                checkout scm 
            
            }
        }

        // Here GIT_COMMIT var comes from the first job i made and is the trigger for this job
        stage("update configuration files") {
            steps {
                withAWS(region: 'eu-north-1', credentials: 'aws-access-and-secret') {
                    script {
                        sh """
                        yq -i '.image.tag = "'${params.GIT_COMMIT}'"' web-app/values.yaml
                        yq -i '.image.tag = "'${params.GIT_COMMIT}'"' backend-app/values.yaml
                        
                        # Get security group IDs
                        FRONTEND_SG_ID=\$(aws ec2 describe-security-groups --filters 'Name=group-name,Values=frontend-pod-sg*' --query 'SecurityGroups[0].GroupId' --output text)
                        BACKEND_SG_ID=\$(aws ec2 describe-security-groups --filters 'Name=group-name,Values=backend-pod-sg*' --query 'SecurityGroups[0].GroupId' --output text)
                        
                        # Check if frontend values has the correct SG, if not - put it there
                        CURRENT_FRONTEND_SG=\$(yq '.securityGroup.id' web-app/values.yaml)
                        if [ "\$CURRENT_FRONTEND_SG" != "\$FRONTEND_SG_ID" ]; then
                            yq -i '.securityGroup.id = "'\$FRONTEND_SG_ID'"' web-app/values.yaml
                        fi
                        
                        # Check if backend values has the correct SG, if not - put it there  
                        CURRENT_BACKEND_SG=\$(yq '.securityGroup.id' backend-app/values.yaml)
                        if [ "\$CURRENT_BACKEND_SG" != "\$BACKEND_SG_ID" ]; then
                            yq -i '.securityGroup.id = "'\$BACKEND_SG_ID'"' backend-app/values.yaml
                        fi
                        """
                    }
                }
            }
            }
    stage('git push') {
        steps {
            withCredentials([
                sshUserPrivateKey(credentialsId: 'github-ssh', keyFileVariable: 'SSH_KEY', usernameVariable: 'GIT_USER')
            ]) {
                script {
                    // Ensure the repository directory is safe
                    sh 'git config --global --add safe.directory /home/ec2-user/workspace/project-cd'

                    sh '''
                    git config user.name "Jenkins Bot"
                    git config user.email "jenkins@example.com"

                    # Set the GitHub SSH remote URL
                    git remote set-url origin git@github.com:eranzaksh/CD_Project.git

                    # Add GitHub's SSH key to known_hosts to prevent "Host key verification failed"
                    mkdir -p ~/.ssh
                    ssh-keyscan github.com >> ~/.ssh/known_hosts

                    git add .
                    git commit -m "update values.yaml" || echo "No changes"

                    # Push changes using SSH key
                    GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push origin HEAD:main
                    '''
                }
            }
        }
    }

    stage('Configure infrastructure components') {
        steps {
            withAWS(region: 'eu-north-1', credentials: 'aws-access-and-secret') {
                sh '''
                aws eks update-kubeconfig --name tf-eran
                helm repo add jetstack https://charts.jetstack.io
                helm repo add external-secrets https://charts.external-secrets.io
                helm repo update
                helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
                helm install external-secrets external-secrets/external-secrets --namespace external-secrets --create-namespace --set installCRDs=true
                '''
                sh "kubectl apply -f cluster-issuer.yaml"
                sh "helm upgrade --install argocd-ingress ./helm/argocd -n argocd --create-namespace"
                sh "helm upgrade --install prometheus-ingress ./helm/prometheus -n monitoring --create-namespace"
            }
        }
    }
    stage('Configure duckdns host and Connect to argocd') {
        steps {
            withAWS(region: 'eu-north-1', credentials: 'aws-access-and-secret') {
            sh '''
            
            aws eks update-kubeconfig --name tf-eran
            export LbDnsName=`kubectl get svc -n ingress-nginx | awk -F ' ' '{print $4}' | head -n2 | tail -n1`
            export CLB_IP=`nslookup ${LbDnsName} | grep 'Address' | tail -n 1 | awk '{print $2}'`
            curl "$DUCKDNS_URL&ip=$CLB_IP"
            export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
            argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD
            '''
            }
        }
    }
    stage('Check if frontend argocd app exists'){
        steps {
            script {
                def appExists = sh(returnStatus: true, script: "argocd app get web-app") == 0
                if (appExists) {
                    env.FRONTEND_EXISTS = 'true'
                } else {
                    env.FRONTEND_EXISTS = 'false'
                }
            }
        }
    }
    stage('Create frontend argocd app') {
        when {
            expression { env.FRONTEND_EXISTS == 'false' }
        }
        steps {
            sh '''
            argocd app create web-app \
            --repo https://github.com/eranzaksh/CD_Project.git \
            --path web-app \
            --dest-namespace web-app \
            --dest-server https://kubernetes.default.svc \
            --sync-policy automated \
            --auto-prune \
            --sync-option CreateNamespace=true
            '''
        }
    }
    stage('Check if backend argocd app exists'){
        steps {
            script {
                def backendAppExists = sh(returnStatus: true, script: "argocd app get backend-app") == 0
                if (backendAppExists) {
                    env.BACKEND_EXISTS = 'true'
                } else {
                    env.BACKEND_EXISTS = 'false'
                }
            }
        }
    }
    stage('Create backend argocd app') {
        when {
            expression { env.BACKEND_EXISTS == 'false' }
        }
        steps {
            sh '''
            argocd app create backend-app \
            --repo https://github.com/eranzaksh/CD_Project.git \
            --path backend-app \
            --dest-namespace backend \
            --dest-server https://kubernetes.default.svc \
            --sync-policy automated \
            --auto-prune \
            --sync-option CreateNamespace=true
            '''
        }
    }
    
 
    }     
    post {
        always {
            cleanWs()   
        }

        success {
          slackSend channel: 'succeeded-build', color: 'good', message: "Build successful: Job '${env.JOB_NAME}-${env.BUILD_NUMBER} ${STAGE_NAME}'"
        }
    
        failure {
          slackSend channel: 'devops-alerts', color: 'danger', message: "Build failed: Job '${env.JOB_NAME}-${env.BUILD_NUMBER} ${STAGE_NAME}'"
        }

}
    
}
