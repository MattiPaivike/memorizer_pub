#!/usr/bin/env python3
import boto3
import argparse
import sys

def start_batch_task(environment):
    """Start an ECS batch job task in the specified environment."""
    # Set up connection to AWS
    ecs_client = boto3.client('ecs')
    
    # Define cluster and task definition names based on environment
    cluster_name = f"{environment}-memorizer-cluster"
    task_definition = f"{environment}-memorizer-django-batch"
    
    try:
        # Configure network settings using same subnets and security groups as service
        # Get the current service configuration to extract network settings
        services = ecs_client.list_services(
            cluster=cluster_name,
            maxResults=100
        )
        
        if not services.get('serviceArns'):
            print(f"No services found in cluster {cluster_name}")
            return False
            
        service_details = ecs_client.describe_services(
            cluster=cluster_name,
            services=[services['serviceArns'][0]]
        )
        
        if not service_details.get('services'):
            print(f"Could not get service details for {cluster_name}")
            return False
            
        network_config = service_details['services'][0]['networkConfiguration']
        
        # Run the task with command override to execute the Django management command
        response = ecs_client.run_task(
            cluster=cluster_name,
            taskDefinition=task_definition,
            count=1,
            launchType='FARGATE',
            networkConfiguration=network_config,
            overrides={
                'containerOverrides': [
                    {
                        'name': "batch",  # Corrected container name from task definition
                        'command': ['python', 'manage.py', 'create_superuser_and_initial_data']
                    }
                ]
            }
        )
        
        print(f"Started batch task in {environment} environment")
        print(f"Task ARN: {response['tasks'][0]['taskArn']}")
        return True
        
    except Exception as e:
        print(f"Error starting batch task: {str(e)}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Start an ECS batch job task')
    parser.add_argument('--environment', '-e', type=str, 
                        help='Environment name (e.g., dev, staging, prod)')
    
    args = parser.parse_args()
    
    # If environment not provided as command line argument, prompt for it
    environment = args.environment
    if not environment:
        environment = input("Enter environment name (dev, staging, prod): ").strip()
    
    if not environment:
        print("Environment name is required")
        sys.exit(1)
    
    # Start the batch task
    success = start_batch_task(environment)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main() 