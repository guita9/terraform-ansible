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
