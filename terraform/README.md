# Running the Terraform

## Prerequisites


* In AWS console, create a s3 bucket (for terraform state) and DynamoDB table (for terraform lock). Set DynamoDB partition key to `LockID`. 

For each non-common environment, for example `dev`, create a `variables.tfvars` file in `terraform/environments/dev` folder with the following content:
```
bastion_allow_ips = ["your-ip/32"]
domain_name="your-domain.com"
subdomain_name="your-subdomain"
app_allow_ips = ["0.0.0.0/0"]
aws_region= "<aws_region>"
tf_state_bucket_name=<aws_state_bucket_name_here>
```

After creating the state bucket and lock table, create a `backend_config.tfbackend` file for all environments (including `common`). Set the following data in the file:
```
bucket         = <aws_state_bucket_name_here>
region         = "eu-north-1"
dynamodb_table = <aws_dynamodb_table_name_here>
```

* The terraform expects an ssh-key pair called `memorizer-bastion-key` for bastion usage. Create this in EC2 console before running terraform.

* Additionally the Terraform expects route53 hosted zone root domain with `NS`, `SOA`, `A` and `CNAME` records. This is created automatically after purchasing a domain in Route53.

Setup common environment first

```
cd environments/common
terraform init -backend-config=backend_config.tfbackend
terraform apply -var-file="variables.tfvars"
```

After creating the common environment, upload the Docker images to their ECR repositories. Make sure the tags match the configuration.

Login to ECR:
```
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com
```

```
docker build -t <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-django .
docker push <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-django:latest
```

```
docker build -t <aws-account-number-here>.ecr.eu-north-1.amazonaws.com/memorizer-consumer:latest -f .\Dockerfile_consumer_service .
docker push <aws-account-number-here>.ecr.eu-north-1.amazonaws.com/memorizer-consumer:latest
```

```
cd proxy
docker build -t <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-nginx:latest .
docker push <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-nginx:latest
```

Check `terraform/environments/dev/variables.tf` and then setup dev environment:
```
cd environments/dev
terraform init -backend-config=backend_config.tfbackend
terraform apply -var-file="variables.tfvars"
```

## Create Django superuser in AWS

Create Django superuser via bastion host.

First ssh to bastion host and run the following commands:

```
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com
docker pull <aws-account-number-here>.dkr.ecr.eu-north-1.amazonaws.com/memorizer-django:latest
sudo docker run -it \
    -e DB_HOST=<DB_HOST> \
    -e DB_NAME=<DB_NAME> \
    -e DB_USER=<DB_USER> \
    -e DB_PASS=<DB_PASS> \
    -e DB_PORT=5432 \
    <ECR_REPO>:latest(OR)prod \
    sh -c "python manage.py createsuperuser"
```