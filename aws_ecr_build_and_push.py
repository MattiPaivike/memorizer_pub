import subprocess
import sys
import os
import pathlib

def run_command(command):
    """Execute a shell command and handle errors"""
    try:
        print(f"Executing: {command}")
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}")
        print(f"Error details: {str(e)}")
        sys.exit(1)

def main():
    # Get the script's directory to ensure consistent paths
    script_dir = str(pathlib.Path(__file__).parent.absolute())
    
    # Get AWS account ID
    aws_account_id = input("Please enter your AWS account ID: ")
    
    # Get region from environment variable or use default
    region = os.environ.get('AWS_DEFAULT_REGION', 'eu-north-1')
    print(f"Using AWS region: {region}")
    
    # ECR login
    print("\nLogging into ECR...")
    ecr_login_cmd = f"aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {aws_account_id}.dkr.ecr.{region}.amazonaws.com"
    run_command(ecr_login_cmd)

    services = [
        {
            "name": "memorizer-django",
            "dockerfile": f"{script_dir}/Dockerfile",
            "context": script_dir
        },
        {
            "name": "memorizer-consumer",
            "dockerfile": f"{script_dir}/Dockerfile_consumer_service",
            "context": script_dir
        },
        {
            "name": "memorizer-nginx",
            "dockerfile": f"{script_dir}/nginx_proxy/Dockerfile",
            "context": f"{script_dir}/nginx_proxy"
        }
    ]

    # Build and push each service
    for service in services:
        print(f"\nProcessing {service['name']}...")

        # Build image
        print(f"Building {service['name']}...")
        image_uri = f"{aws_account_id}.dkr.ecr.{region}.amazonaws.com/{service['name']}:latest"
        build_cmd = f"docker build -t {image_uri} -f {service['dockerfile']} {service['context']}"
        run_command(build_cmd)

        # Push image
        print(f"Pushing {service['name']}...")
        push_cmd = f"docker push {image_uri}"
        run_command(push_cmd)


    print("\nAll images have been built and pushed successfully!")

if __name__ == "__main__":
    main() 