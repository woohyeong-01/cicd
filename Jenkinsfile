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
      steps{
        script{
            try{
                sh"""
                #!/bin/bash
                cat>web.yaml<<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: ${ECR_TASK_URI}:ver${env.BUILD_ID}
        ports:
        - containerPort: 5000
EOF
"""
        sh 'kubectl apply -f /home/ec2-user/web_deploy.yaml'
            }
        }
      }
    }
  }
}
