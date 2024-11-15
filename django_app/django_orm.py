import os
import django
from django.conf import settings

# This is used with Lambda function to initialize Django ORM

def initialize_django_postgres_database() -> None:
    if settings.configured:
        return

    settings.configure(
        INSTALLED_APPS=[
            "django_app.core",
            "django.contrib.contenttypes",
            "django.contrib.auth",
        ],
        DATABASES={
            "default": {
                "ENGINE": "django.db.backends.postgresql",
                "HOST": os.environ.get("DB_HOST"),
                "NAME": os.environ.get("DB_NAME"),
                "USER": os.environ.get("DB_USER"),
                "PASSWORD": os.environ.get("DB_PASS"),
            }
        },
    )
    django.setup()
