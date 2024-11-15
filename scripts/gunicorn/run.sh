#!/bin/sh

python manage.py collectstatic --noinput
python manage.py migrate
python manage.py create_initial_data
gunicorn  --config /scripts/gunicorn_config.py epicmemory.wsgi