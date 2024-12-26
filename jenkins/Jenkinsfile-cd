pipeline {
    
    environment {
        GIT_COMMIT = ''
        ARGOCD_SERVER = 'eranargocd.duckdns.org:443'
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
                script {
                    sh """
                    yq -i '.image.tag = "'${params.GIT_COMMIT}'"' web-app/values.yaml
                    """
                }
            }
        }
    stage('git push') {
        steps {
            withCredentials([
                sshUserPrivateKey(credentialsId: 'github-for-jobs', keyFileVariable: 'SSH_KEY', usernameVariable: 'GIT_USER')
            ]) {
                script {
                    // Ensure the repository directory is safe
                    sh 'git config --global --add safe.directory /home/ec2-user/workspace/leumi-cd'

                    sh '''
                    git config user.name "Jenkins Bot"
                    git config user.email "jenkins@example.com"

                    git remote set-url origin git@github.com:eranzaksh/GitOps_Project_CD.git

                    # Add GitHub's SSH key to known_hosts to prevent "Host key verification failed"
                    mkdir -p ~/.ssh
                    ssh-keyscan github.com >> ~/.ssh/known_hosts

                    git add .
                    git commit -m "update values.yaml" || echo "No changes"

                    GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push origin HEAD:main
                    '''
                }
            }
        }
    }
    stage('Connect to argocd') {
        steps {
            withAWS(region: 'eu-north-1', credentials: 'aws-access-and-secret') {
            sh '''
            
            aws eks update-kubeconfig --name tf-leumi

            export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
            argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD --insecure
            '''
            }
        }
    }
    // stage('Check if argocd app exists'){
    //     steps {
    //         script {
    //             def appExists = sh(returnStatus: true, script: "argocd app get leumi-app") == 0
    //             if (appExists) {
    //                 env.EXISTS = 'true'
    //             } else {
    //                 env.EXISTS = 'false'
    //             }
    //         }
    //     }
    // }
    stage('Create argocd app') {
        steps {
            sh '''
            argocd app create leumi-app \
            --repo https://github.com/eranzaksh/GitOps_Project_CD.git \
            --path web-app \
            --dest-namespace default \
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
