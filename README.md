# Project: Automated Website Deployment Using Jenkins, Terraform, Ansible, and Docker

Our Goal:
![Jenkins](https://github.com/user-attachments/assets/9346bf28-35aa-498c-b33c-aa821ad6e83b)

This project demonstrates a complete CI/CD pipeline to provision and deploy infrastructure and applications using Jenkins, Terraform, AWS, Ansible, and Docker. The setup includes:

    Automated provisioning of an AWS VPC, subnets, EC2 instances, and security groups using Terraform.
    Automated configuration of the EC2 instances with Ansible, installing Docker, Docker Compose, and deploying a web application.
    Deployment of a Docker container using Docker Compose, including a website, on the provisioned EC2 instance.

Technologies Used

    Jenkins: For orchestrating the CI/CD pipeline.
    Terraform: To provision AWS infrastructure.
    AWS: EC2, VPC, Security Groups.
    Ansible: For configuration management on the EC2 instance.
    Docker & Docker Compose: To containerize and deploy the web application.

Features

    AWS Infrastructure: The project creates a custom VPC, subnets, security groups, an internet gateway, and EC2 instances.
    CI/CD Pipeline: Jenkins automates the provisioning of infrastructure using Terraform and configures EC2 instances with Ansible.
    Dockerized Web Application: The application is deployed inside a Docker container, managed using Docker Compose.

Prerequisites

    AWS account with proper IAM roles and permissions.
    Jenkins set up with Terraform and Ansible plugins installed.
    SSH key configured for accessing AWS EC2 instances.
    Terraform, Ansible, Docker, and Docker Compose installed locally or in the Jenkins environment.

Step-by-Step Instructions
1. Clone the Repository
```
git clone https://github.com/omar1593321/jenk_project.git
cd your-repo
```
2. Set Up Jenkins Pipeline

The pipeline is defined in the Jenkinsfile. It will:

    Initialize and apply Terraform configurations.
    Run Ansible playbooks to install Docker, configure EC2 instances, and deploy the application.

3. Terraform Configuration

The main.tf file defines the infrastructure, including:

    A VPC with public and private subnets.
    Security groups to allow SSH, HTTP, and Docker traffic.
    An EC2 instance running Amazon Linux 2, with a public IP.

Terraform also outputs the instance's public IP, which can be used for accessing the application.
4. Ansible Playbook

The playbook.yaml file is used to configure the EC2 instance by:

    Installing Docker and Docker Compose.
    Adding the EC2 user to the Docker group.
    Deploying the Docker container using Docker Compose.

5. Docker Compose Setup

The docker-compose.yaml sets up the web application. After running the Ansible playbook, the container will be started automatically.
![image](https://github.com/user-attachments/assets/c49f7be0-bb26-4b37-9710-1379457468e0)


6. Jenkins Pipeline Stages

The Jenkins pipeline consists of the following stages:

    Terraform Init: Initializes the Terraform configuration.
    Terraform Destroy: Destroys the infrastructure when needed.
    Terraform Plan: Creates a plan for the infrastructure.
    Terraform Apply: Provisions the infrastructure.
    Ansible Setup: Configures EC2 instances and deploys Docker containers.

7. Access the Web Application

Once the pipeline completes, you can access the web application using the public IP of the EC2 instance on port 80.
![image](https://github.com/user-attachments/assets/2b10b370-c04e-4bdc-a243-338c33f70fba)

Detailed Jenkins Configuration
1. Jenkins Installation and Setup

Ensure Jenkins is installed and running on your server. You can follow the official Jenkins installation guide for your operating system.
2. Install Necessary Jenkins Plugins

To integrate Jenkins with Terraform, Ansible, and Docker, install the following plugins:

    Git Plugin: For cloning repositories.
    Pipeline Plugin: For defining pipeline scripts.
    Ansible Plugin: To run Ansible playbooks.
    Docker Pipeline Plugin: For Docker integration.
    Credentials Plugin: For managing secrets.
    Terraform Plugin (if available): To integrate Terraform directly.

Installation Steps:

    Navigate to Manage Jenkins > Manage Plugins.
    Under the Available tab, search for each plugin by name and install them.
    Restart Jenkins if prompted.

3. Configure Jenkins Credentials

Properly managing credentials is crucial for secure and seamless pipeline execution.

Add AWS Credentials:

    Go to Manage Jenkins > Manage Credentials.
    Select the (global) domain.
    Click Add Credentials.
    For AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY:
        Kind: Secret text
        Secret: Your AWS Access Key ID or Secret Access Key
        ID: aws_access_key_id and aws_secret_access_key respectively
        Description: (Optional) Description of the credential
    Click OK to save each credential.

Add SSH Key for EC2 Access:

    In Manage Jenkins > Manage Credentials.
    Select the (global) domain.
    Click Add Credentials.
    Kind: SSH Username with private key
    Username: ec2-user (or the appropriate username for your AMI)
    Private Key: Enter directly and paste your private key (.pem file) content
    ID: aws-ssh-key
    Description: (Optional) Description of the SSH key
    Click OK to save.

4. Jenkinsfile Explanation
```
pipeline {
    agent any
    environment {
    AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
    AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')     
    }
    stages {
        
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
stage('Terraform Destroy') {
            steps {
                script {
                    // Use the SSH key stored in Jenkins credentials
                    withCredentials([
    sshUserPrivateKey(credentialsId: 'aws-ssh-key', keyFileVariable: 'SSH_KEY_PATH'),
    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
]) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform destroy -auto-approve \
                        -var "ssh_private_key_path=$SSH_KEY_PATH" \
             
                        '''
                    }
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    // Use the SSH key stored in Jenkins credentials
                    withCredentials([
    sshUserPrivateKey(credentialsId: 'aws-ssh-key', keyFileVariable: 'SSH_KEY_PATH'),
    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
]) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform plan \
                        -var "ssh_private_key_path=$SSH_KEY_PATH" \
             
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    // Apply Terraform with SSH credentials passed from Jenkins
                    withCredentials([
    sshUserPrivateKey(credentialsId: 'aws-ssh-key', keyFileVariable: 'SSH_KEY_PATH'),
    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
]) 
                 {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform apply -auto-approve \
                        -var "ssh_private_key_path=$SSH_KEY_PATH" \
         
                        '''
                    }
                }
            }
        }
    }
}
```
Key Points:

    Environment Variables:
        AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are injected using the credentials function, referencing the IDs you set in Jenkins.

    Stages:
        Checkout Code: Clones the repository containing all necessary configurations.
        Terraform Init: Initializes the Terraform working directory.
        Terraform Plan: Generates an execution plan for Terraform. Uses withCredentials to securely pass AWS and SSH credentials.
        Terraform Apply: Applies the Terraform plan to provision the infrastructure.
        Ansible Setup: Runs the Ansible playbook to configure the EC2 instances and deploy Docker containers.
        Terraform Destroy:  Destroys the provisioned infrastructure. Useful for cleanup in testing environments.

    Credentials Management:
        withCredentials: Securely injects credentials into the pipeline steps without exposing them in logs.
        SSH Key Handling: The SSH key is used by Ansible to connect to the EC2 instances.

    Terraform Variables:
        Variables like ssh_private_key_path and aws_region are passed to Terraform to parameterize the configurations.

    Ansible Playbook Execution:
        The playbook is executed against the newly created EC2 instance using its public IP, which Terraform outputs.

5. Managing Jenkins Credentials Securely

Best Practices:

    Least Privilege: Ensure AWS credentials have only the necessary permissions.
    Separate Credentials: Use separate credentials for different stages or components if needed.
    Rotate Secrets: Regularly rotate credentials to minimize security risks.
    Avoid Hardcoding: Never hardcode sensitive information in the Jenkinsfile or code repositories.

6. Jenkins Pipeline Execution Flow

    Initialization:
        Jenkins triggers the pipeline upon code commit or manually.

    Cleanup:
        Terraform Destroy: Removes all provisioned resources, useful for re-using resources if something failed.

    Infrastructure Provisioning:
        Terraform Init: Prepares the working directory.
        Terraform Plan: Reviews changes before applying.
        Terraform Apply: Creates or updates AWS resources based on Terraform scripts.

    Configuration Management:
        Ansible Playbook: Configures the EC2 instances by installing necessary software and deploying Docker containers.

    Deployment:
        Docker Setup: Uses Docker Compose to manage containers, ensuring the web application is up and running.

7. Troubleshooting Common Jenkins Issues

Issue 1: Terraform Not Found

    Error: terraform: not found

    Solution: Ensure Terraform is installed on the Jenkins agent or use a Docker container with Terraform pre-installed.    
Issue 2: Incorrect Credentials Configuration

    Error: IncompleteSignature: Credential must have exactly 5 slash-delimited elements
    Solution: Ensure AWS credentials are correctly set up as separate string credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) in Jenkins.

Issue 3: YAML Syntax Errors in Ansible Playbook

    Error: yaml.scanner.ScannerError: mapping values are not allowed here
    Solution: Validate the YAML syntax using tools like YAML Lint and ensure proper indentation and formatting.

Issue 4: Ansible Copy Module Missing src Parameter

    Error: state is present but all of the following are missing: source
    Solution: Ensure all required parameters are provided in Ansible tasks. For example, the copy module requires both src and dest parameters.    
