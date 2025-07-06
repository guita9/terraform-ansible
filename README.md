# AWS EC2 Instance with Specific Ports Open (Terraform)

This Terraform project provisions a single AWS EC2 instance and a security group configured to allow SSH, a custom application port, and Prometheus Node Exporter traffic.

## Project Structure

* `main.tf`: Defines the AWS EC2 instance and the associated Security Group.
* `outputs.tf`: Specifies output variables, such as the public IP of the EC2 instance.
* `variables.tf`: Declares input variables for the Terraform configuration (though currently only `region` is defined and not directly used in `main.tf` for dynamic region selection).

## Prerequisites

Before you can deploy this infrastructure, ensure you have the following:

1.  **Terraform CLI:**
    * Download and install the Terraform command-line interface (CLI) from the [official HashiCorp website](https://developer.hashicorp.com/terraform/downloads).

2.  **AWS Account and Credentials:**
    * You need an active AWS account.
    * Configure your AWS credentials on your local machine. Terraform uses the AWS CLI's credential chain (environment variables, shared credentials file, IAM roles for EC2 instances) to authenticate. The simplest way for local development is usually:
        * **AWS CLI:** Install the [AWS CLI](https://aws.amazon.com/cli/) and run `aws configure`.
        * **Environment Variables:** Set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

3.  **Existing AWS VPC:**
    * The `main.tf` file references a specific VPC ID (`vpc-016t53b4fd9123456`). **You must replace this with an actual VPC ID from your AWS account in the `us-east-1` region, or ensure this VPC exists.** You can find your VPC IDs in the AWS VPC console.

4.  **Existing AWS EC2 Key Pair:**
    * The `main.tf` file specifies `key_name = "sanjayssh"`.
    * You **must** have an EC2 Key Pair named `sanjayssh` created in the `us-east-1` region within your AWS account.
    * You will also need the corresponding private key file (`.pem`) on your local machine to SSH into the created EC2 instance.

5.  **AMI ID:**
    * The `ami = "ami-020cba7c55df1f615"` is for `us-east-1`. While this is a common Amazon Linux 2 AMI, it's good practice to verify its validity or update it if you need a different operating system or a newer version.

## Deployment Steps

1.  **Clone (or download) this repository:**
    ```bash
    git clone <repository-url>
    cd terraform-ansible/aws/Terraformlabs
    ```
    (Replace `<repository-url>` with the actual URL if this is in a Git repository.)

2.  **Initialize Terraform:**
    Navigate to the `terraform-ansible/aws/Terraformlabs` directory and run:
    ```bash
    terraform init
    ```
    This command downloads the necessary AWS provider plugin.

3.  **Review the Plan:**
    It's crucial to review the changes Terraform will make before applying them.
    ```bash
    terraform plan
    ```
    This command shows you what resources will be created, modified, or destroyed.

4.  **Apply the Configuration:**
    If the plan looks correct, apply the configuration to create the resources:
    ```bash
    terraform apply
    ```
    Terraform will prompt you to confirm the action. Type `yes` and press Enter.

5.  **Retrieve Instance IP:**
    After `terraform apply` completes successfully, the public IP address of your EC2 instance will be displayed in the output. If it's not immediately visible, you can get it using:
    ```bash
    terraform output instance_ip
    ```

## Connecting to the EC2 Instance

Once the instance is launched, you can connect to it via SSH using the public IP address and your private key:

```bash
ssh -i /path/to/your/sanjayssh.pem ec2-user@<instance_public_ip>
```

# FastAPI Application Deployment with Ansible

This repository contains Ansible playbooks and configuration files to automate the deployment of a FastAPI application with a local PostgreSQL database on a remote server. The playbook is designed to be compatible with both Debian-based (e.g., Ubuntu) and Red Hat-based (e.g., CentOS, Rocky Linux) operating systems.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Setup and Usage](#setup-and-usage)
    - [1. Clone the Repository](#1-clone-the-repository)
    - [2. Prepare your Ansible Environment](#2-prepare-your-ansible-environment)
    - [3. Configure Inventory (hosts file)](#3-configure-inventory-hosts-file)
    - [4. Place Your FastAPI Application](#4-place-your-fastapi-application)
    - [5. Run the Ansible Playbook](#5-run-the-ansible-playbook)
- [What the Playbook Does](#what-the-playbook-does)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Features

* **Automated OS Setup**: Installs necessary system dependencies (Python, `pip`, `venv`, build tools) tailored for Debian/Ubuntu and Red Hat/CentOS/Rocky Linux.
* **PostgreSQL Installation & Configuration**: Installs PostgreSQL server, sets the `postgres` user password, and creates the application database.
* **FastAPI Application Deployment**: Copies your FastAPI application code to the server, sets up a Python virtual environment, and installs dependencies.
* **Gunicorn & Uvicorn Setup**: Installs and configures Gunicorn with Uvicorn workers for serving the FastAPI application.
* **Database Migrations**: Runs SQLAlchemy migrations to create necessary database tables.
* **Systemd Service Management**: Creates and manages a systemd service to ensure your FastAPI application runs persistently and restarts automatically on failure or boot.
* **Idempotent**: Can be run multiple times without causing unintended side effects, bringing the server to the desired state.

## Prerequisites

Before using this playbook, ensure you have:

* **Ansible Installed**: On your local machine (control node).
    ```bash
    pip install ansible
    ```
* **SSH Access to Target Server(s)**:
    * The target server should be a fresh installation of a Debian-based (e.g., Ubuntu) or Red Hat-based (e.g., CentOS, Rocky Linux) Linux distribution.
    * You need an SSH private key (`sanjayssh.pem` as per the example) for passwordless authentication to the `ansible_user` (e.g., `ubuntu`) on the target server.
    * The `ansible_user` must have `sudo` privileges without requiring a password (often configured by default on cloud images like AWS EC2's `ubuntu` or `ec2-user`).

* **Your FastAPI Application Code**: Organized in a directory named `app/` with a `requirements.txt` file at its root. A minimal example structure for your `app/` directory might look like this:
    ```
    app/
    ├── main.py        # Your FastAPI application entry point
    ├── database.py    # SQLAlchemy setup and Base for migrations
    ├── models.py      # Your SQLAlchemy models
    ├── schemas.py     # Pydantic schemas
    └── requirements.txt # Python dependencies (fastapi, uvicorn, sqlalchemy, psycopg2-binary, etc.)
    ```

## Repository Structure
```bash
├── app/                        # Your FastAPI application code goes here
│   ├── main.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   └── requirements.txt
├── deploy_fastapi.yml          # The main Ansible playbook for deployment
├── fastapi_app.service.j2      # Jinja2 template for the systemd service file
├── hosts                       # Ansible inventory file (define your target servers here)
└── sanjayssh.pem               # Your SSH private key for server authentication
```
