pipeline {
    agent any
    tools {
        terraform 'my_terraform'
    }
    stages{
        stage('Git Checkout'){
            steps{
                git branch: 'main', url: 'https://github.com/kumariseait/terra_ec2.git'
            }
        }
        stage('Terraform Initilization'){
            steps{
                sh 'terraform init'
            }
        }
        stage('Terraform planning'){
            steps{
                sh 'terraform plan'
            }
        }
        stage('Terraform apply'){
            steps{
                sh 'terraform apply --auto-approve'
            }
        }
        stage('Run next job'){
            steps{
                build job: "terra_destroy", wait: true
            }   
        }
    }
}
