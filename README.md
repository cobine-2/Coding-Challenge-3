Tech Challenge 3: Infrastructure as Code with Terraform and Ansible
Introduction
This document provides a step-by-step guide to completing Tech Challenge 3: Infrastructure as Code with Terraform and Ansible. It covers setting up the environment, deploying infrastructure, and configuring the system using Ansible.
Prerequisites
Before starting, ensure you have the following installed on your local machine:
- AWS Account with IAM user having necessary permissions
- Terraform (Download from: https://developer.hashicorp.com/terraform/downloads)
- Ansible (Install via `sudo apt install -y ansible`)
- Git (Download from: https://git-scm.com/downloads)
- SSH Key Pair (Generated via `ssh-keygen` or via Terraform)
Setting Up the Environment
1. Clone the repository and navigate to the directory:

   git clone git@github.com:your-username/Coding-Challenge-3.git
   cd Coding-Challenge-3

2. Initialize Terraform:

   terraform init

3. Apply the Terraform configuration:

   terraform apply -auto-approve

This will:
   - Generate `my-keypair.pem`
   - Provision the EC2 instance
   - Create S3 bucket and IAM roles

4. SSH into the EC2 instance:

   chmod 400 my-keypair.pem
   ssh -i my-keypair.pem ubuntu@<EC2_PUBLIC_IP>

Terraform Configuration
Terraform is used to automate the provisioning of AWS infrastructure. The main Terraform file (`main.tf`) performs the following tasks:
- Creates an SSH key pair for secure EC2 access
- Provisions an EC2 instance (Ubuntu 22.04)
- Creates a Security Group allowing SSH (22) and HTTP (80)
- Creates an S3 bucket
- Sets up an IAM Role and Policy granting EC2 access to S3
- Creates an IAM Instance Profile and attaches it to the EC2 instance
Ansible Configuration
Once Terraform provisions the EC2 instance, Ansible is used to install and configure Nginx.
1. Install Ansible on the EC2 instance:

   sudo apt update && sudo apt install -y ansible

2. Create an Ansible inventory file to manage the instance itself:

   sudo mkdir -p /etc/ansible
   echo "[webserver]
   localhost ansible_connection=local" | sudo tee /etc/ansible/hosts

3. Create an Ansible playbook to install and configure Nginx:

   nano playbook.yml

Paste the following YAML code inside the file:

---
- name: Configure Nginx on EC2
  hosts: webserver
  become: true
  tasks:
    - name: Update package lists
      apt: update_cache=yes

    - name: Install Nginx
      apt: name=nginx state=present

    - name: Start and enable Nginx
      service: name=nginx state=started enabled=yes

    - name: Create a simple web page
      copy:
        content: "<h1>Hello, World!</h1>"
        dest: /var/www/html/index.html

4. Run the Ansible playbook:
   
   ansible-playbook playbook.yml

5. Verify Nginx is running:

   systemctl status nginx

Testing the Web Server
To access the deployed webpage, open a browser and go to:

   http://<EC2_PUBLIC_IP>

You should see the following message:

   Hello, World!

Conclusion
This project successfully demonstrates the provisioning of AWS infrastructure using Terraform and the configuration of an EC2 instance using Ansible. By following these steps, you have:
- Provisioned an EC2 instance, Security Group, and S3 bucket using Terraform.
- Configured EC2 with Ansible to install and enable Nginx.
- Deployed a simple 'Hello, World!' webpage.