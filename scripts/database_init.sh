#!/bin/sh

python manage.py migrate
python manage.py create_initial_data