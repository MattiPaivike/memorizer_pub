# MemoRizer

An AI-powered note-taking application that transforms hastily written text into beautifully formatted notes and todo lists.

![Demo GIF](pictures/demo.gif)

## Features

- Convert rough notes to well-formatted documents
- Automatically organize content into structured notes
- Create and manage todo lists with AI assistance

## Tech Stack

- **Backend**: Python/Django
- **Frontend**: HTMX
- **Task Queue**: Celery with Redis (local) or AWS SQS and Lambda (production)
- **Infrastructure**: AWS ECS, Terraform
- **CI/CD**: GitHub Actions

## Local Development

### Prerequisites

- Python 3.9+
- Docker and Docker Compose (optional)
- Redis (can be run in Docker)

### Environment Setup

1. Clone the repository
2. Create a `.env` file in the root directory (see `env.sample` for required variables)

### Running the Application

#### Option 1: Running with Local Python and Django development server

Create your virtual environment and install:
```bash
pip install -r requirements.txt
```

Start Redis:
```bash
docker run -d -p 6379:6379 redis:7.4.1-alpine
```

Start Celery worker:

On Windows:
```bash
cd django_app
celery -A epicmemory worker --loglevel=info -P solo
```

On Linux/macOS:
```bash
cd django_app
celery -A epicmemory worker --loglevel=info
```

Run migrations and create initial database data:
```bash
cd django_app
python manage.py migrate
python manage.py create_initial_data
```


Start Django server:
```bash
cd django_app
python manage.py runserver
```

#### Option 2: Running with Docker Compose

Build and run the application:
```bash
docker-compose up --build
```

Create a superuser in the running Docker container:
```bash
# Find the container ID
docker ps

# Create superuser (replace <CONTAINER_ID> with the actual ID)
docker exec -it <CONTAINER_ID> sh -c "python manage.py createsuperuser"
```

## Production Deployment

### AWS Infrastructure

The application is designed to be deployed on AWS using Terraform. The infrastructure includes:

- ECS cluster for container orchestration
- RDS for database
- SQS for message queue
- ECR for container registry
- EC2 for bastion
- ALB for loadbalancing

See the `terraform/` folder for infrastructure setup details.

### CI/CD Setup

The repository includes GitHub Actions workflows for CI/CD. To use them, configure the following GitHub secrets:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_ECR_URL_CONSUMER_SERVICE
AWS_ECR_URL_DJANGO
AWS_ECR_URL_NGINX
```