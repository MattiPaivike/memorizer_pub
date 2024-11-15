# MemoRizer

An AI powered note taking application built with Django and HTMX.

## Running app locally

Create `.env` file, see `env.sample`.

Create initial data etc:
```
cd django_app
python manage.py migrate
python manage.py create_initial_data
python manage.py createsuperuser
```

To run locally you need Redis and Celery. In production we use SQS / AWS Lambda

Start Celery (on windows):
```
cd django_app
celery -A epicmemory worker --loglevel=info -P solo
```

Start Celery (on linux):
```
celery -A epicmemory worker --loglevel=info 
```

You can start redis from docker:
```
docker run -d -p 6379:6379 redis:7.4.1-alpine
```

## Running in docker-compose

Build and run the application:
```
docker-compose build
docker-compose up
```

To create a Django superuser for your running local instance, find the running `app` container id with `docker ps` command.

Then run (copy the container id from the `docker ps` output and replace `<CONTAINER_ID_HERE>` below):
```
docker exec -it <CONTAINER_ID_HERE> sh -c "python manage.py createsuperuser"
```

# Deployment

See `terraform/` folder for infrastructure setup.