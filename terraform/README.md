# Running the Terraform

## Prerequisites in AWS Console

1. This Terraform configuration requires an S3 bucket (for Terraform state) and a DynamoDB table (for Terraform state locking). Create these resources manually before proceeding. Ensure the DynamoDB table has a partition key named `LockID`.
2. The configuration requires an SSH key pair named `memorizer-bastion-key` for bastion host access. Create this key pair in the EC2 console before running Terraform.
3. The configuration expects a Route53 hosted zone for your root domain with `NS`, `SOA`, `A`, and `CNAME` records. These are created automatically when you purchase a domain through AWS Route53.

## Environment Structure

This Terraform project is organized into the following environments:
`environments/common` for common resources such as IAM.
`environments/dev` for development environment

For each additional environment you need (such as staging or production), simply copy the `environments/dev` directory and rename it accordingly (e.g., `environments/staging`).

## Configuration Setup

After creating the S3 state bucket and DynamoDB lock table, create a `backend_config.tfbackend` file for all environments (including `common`). Add the following content to each file:

```
bucket         = <aws_state_bucket_name_here>
region         = <aws_region>
dynamodb_table = <aws_dynamodb_table_name_here>
```

Create these files at:
- `environments/common/backend_config.tfbackend`
- `environments/dev/backend_config.tfbackend`
- (and any other environments you've added)

### Creating variables.tfvars Files

For each environment (except `common`), create a `variables.tfvars` file. For example, for the dev environment, create `terraform/environments/dev/variables.tfvars` with the following content:

```
bastion_allow_ips = ["your-ip/32"]  # IP address(es) to allow connection to bastion host
domain_name = "your-domain.com"     # Domain name for your application
subdomain_name = "your-subdomain"   # Subdomain name (optional)
app_allow_ips = ["0.0.0.0/0"]       # IP address(es) to allow connection to your application
aws_region = "<aws_region>"         # AWS region for deployment
tf_state_bucket_name = "<aws_state_bucket_name_here>"  # S3 bucket created earlier for Terraform state
```

## Deployment Process

### 1. Deploy Common Resources First

```bash
cd environments/common
terraform init -backend-config=backend_config.tfbackend
terraform apply
```

### 2. Build and Upload Docker Images

After creating the common environment, build and upload the Docker images to their ECR repositories. Ensure the image tags match your configuration.

Login to ECR with AWS CLI:
```bash
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com
```

Build and push the containers:

```bash
# Django application
docker build -t <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-django .
docker push <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-django:latest

# Consumer service
docker build -t <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-consumer:latest -f ./Dockerfile_consumer_service .
docker push <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-consumer:latest

# Nginx proxy
cd proxy
docker build -t <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-nginx:latest .
docker push <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-nginx:latest
```

### 3. Deploy Environment-Specific Resources

After uploading the Docker images, deploy each environment:

```bash
cd environments/dev
terraform init -backend-config=backend_config.tfbackend
terraform apply -var-file="variables.tfvars"
```

## Post-Deployment: Creating a Django Superuser

To create a Django superuser via the bastion host:

1. SSH into the bastion host
2. Run the following commands:

```bash
# Login to ECR
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com

# Pull the Django image
docker pull <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-django:latest

# Create superuser
sudo docker run -it \
    -e DB_HOST=<DB_HOST> \
    -e DB_NAME=<DB_NAME> \
    -e DB_USER=<DB_USER> \
    -e DB_PASS=<DB_PASS> \
    -e DB_PORT=5432 \
    <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-django:latest \
    sh -c "python manage.py createsuperuser"
```

Replace `<DB_HOST>`, `<DB_NAME>`, `<DB_USER>`, and `<DB_PASS>` with your actual database connection details.
