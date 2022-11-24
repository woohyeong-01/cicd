pipeline {
    agent any
 
    stages {
        stage('Git Clone') {
            steps {
                script {
                    try{
                        git url: "https://$GIT_URL", branch: "master", credentialsId: "$GIT_CREDENTIALS_ID"
                        env.cloneResult=true
                    }catch(error){
                        print(error)
                        env.cloneResult=false
                         currentBuild.result='FAILURE'
                    }
                }
                
            }
        }
        stage('Docker Build'){
            when{
                expression {
                    return env.cloneResult ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/
                }
            }
            steps {
                script{
                    try{
                        sh"""
                        #!/bin/bash
                         cat>Dockerfile<
# build stage
FROM ${ECR_BASE_URI}:init as build-stage
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["gunicorn",   "--bind", "0.0.0.0:8000",  "flasktest:app", "-w", "2", "--timeout=300", "-k", "gevent"]
EOF"""
                        sh"""
                        aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${ECR_URI}
                        docker build -t ${env.JOB_NAME.toLowerCase()} .
                        docker tag ${env.JOB_NAME.toLowerCase()}:latest ${ECR_TASK_URI}:ver${env.BUILD_NUMBER}
                        docker push ${ECR_TASK_URI}:ver${env.BUILD_NUMBER}
                        """
                         env.dockerBuildResult=true
                    }catch(error){
                        print(error)
                         env.dockerBuildResult=false
                         currentBuild.result='FAILURE'
                    }
                }
            }
        }
        stage('Deploy pods'){
            when {
                expression {
                    return env.dockerBuildResult ==~ /(?i)(Y|YES|T|TRUE|ON|RUN)/
                }
            }
            steps{
                script{
                    try{
                        sh """
                        sudo rm -rf deployfiles
                        mkdir deployfiles && cd deployfiles
                        #!/bin/bash
                         cat>monthly_deploy.yaml<
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monthly-deployment
  labels:
    app: monthly
spec:
  replicas: 3
  selector:
    matchLabels:
      app: monthly
  template:
    metadata:
      labels:
        app: monthly
    spec:
      containers:
      - name: monthly-cont
        image: ${ECR_TASK_URI}:ver${env.BUILD_NUMBER}
        ports:
        - containerPort: 5000
EOF"""
                        sh "pwd"
                        sh "/home/jenkins/bin/kubectl apply -f /var/lib/jenkins/workspace/Deploy_SREBGK_MonthlyReport/deployfiles/monthly_deploy.yaml"
                         env.deployPodsResult=true
                    }catch(error){
                        print(error)
                         env.deployPodsResult=false
                         currnetBuild.result='FAILURE'
                    }
                    
                }
            }
            
        }
    }
}
