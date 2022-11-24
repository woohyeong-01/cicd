pipeline {
    agent any
    stages {
        stage ('build') {
            steps {
              sh 'printenv'
            }
        }
        stage ('Publish ECR') {
            steps {
                withEnv (["AWS_ACCESS_KEY=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}", "AWS_DEFAULT_REGION=${env.AWS_DEFAULT_REGION}"]) {
                    sh 'docker login -u AWS -p $(aws ecr get-login-password --region ap-northeast-2) 402593391658.dkr.ecr.ap-northeast-2.amazonaws.com'
                    sh 'docker build -t test .'
                    sh 'docker tag test:latest 402593391658.dkr.ecr.ap-northeast-2.amazonaws.com/test:""$BUILD_ID""'
                    sh 'docker push 402593391658.dkr.ecr.ap-northeast-2.amazonaws.com/test:""$BUILD_ID""'
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
        image: 402593391658.dkr.ecr.ap-northeast-2.amazonaws.com/test:""$BUILD_ID""
        ports:
        - containerPort: 5000
EOF"""
                        sh "pwd"
                        sh "/home/ec2-user/kubectl apply -f monthly_deploy.yaml"
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
