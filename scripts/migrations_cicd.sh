#!/usr/bin/env bash

# This script will run Django migrations on AWS Fargate
# used with gitlab-ci pipeline

# Environment can be latest or prod
ENVIRONMENT="${1:-latest}"

# Get Subnets and SecurityGroups for the task
SERVICE_ARN=$(aws ecs list-services --cluster epicmemory-cluster-$ENVIRONMENT --query "serviceArns[?contains(@, 'epicmemory-django-$ENVIRONMENT')]" --region eu-north-1 --output text)
SUBNETS=$(aws ecs describe-services --cluster epicmemory-cluster-$ENVIRONMENT --services $SERVICE_ARN --query 'services[].networkConfiguration.awsvpcConfiguration.subnets' --region eu-north-1 | jq -r '.[]' | xargs)
SECURITYGROUPS=$(aws ecs describe-services --cluster epicmemory-cluster-$ENVIRONMENT --services $SERVICE_ARN --query 'services[].networkConfiguration.awsvpcConfiguration.securityGroups' --region eu-north-1 | jq -r '.[]' | xargs)

ECS_TASK_OVERRIDES='{"containerOverrides": [{"name": "api","command": ["python", "manage.py", "migrate"]}]}' 
TASK_ARN=$(aws ecs run-task --cluster epicmemory-cluster-$ENVIRONMENT --task-definition epicmemory-django-$ENVIRONMENT --launch-type FARGATE --count 1 --network-configuration "awsvpcConfiguration={subnets=${SUBNETS},securityGroups=${SECURITYGROUPS},assignPublicIp=ENABLED}" --overrides "$ECS_TASK_OVERRIDES" --region eu-north-1 --output text --query 'tasks[0].taskArn')

while true; do
  # Get the task state using AWS CLI
  task_state=$(aws ecs describe-tasks --cluster epicmemory-cluster-$ENVIRONMENT --tasks $TASK_ARN --region eu-north-1 --query 'tasks[0].lastStatus')
  
  # Check if the task state is one of the valid states
  if [[ "$task_state" != '"PROVISIONING"' && "$task_state" != '"PENDING"' && "$task_state" != '"ACTIVATING"' && "$task_state" != '"RUNNING"' ]]; then
    echo "Datamigration task is no longer running. All done. Task result:"
    aws ecs describe-tasks --cluster epicmemory-cluster-$ENVIRONMENT --tasks $TASK_ARN --region eu-north-1
    break
  fi

  # Sleep for 5 seconds before checking the task state again
  echo "Datamigration task is still active. sleeping for 5 seconds"
  sleep 5
done
