import os
from django.core.management.base import BaseCommand, CommandError
from django.core.management import call_command
from django.contrib.auth import get_user_model

User = get_user_model()

class Command(BaseCommand):
    help = 'Create a Django superuser from environment variables and run create_initial_data'

    def handle(self, *args, **options):
        # Get environment variables
        username = os.environ.get('DJANGO_SUPERUSER_NAME')
        email = os.environ.get('DJANGO_SUPERUSER_EMAIL')
        password = os.environ.get('DJANGO_SUPERUSER_PASSWORD')

        # Check if all required environment variables are set
        if not username:
            raise CommandError('DJANGO_SUPERUSER_NAME environment variable is not set')
        if not email:
            raise CommandError('DJANGO_SUPERUSER_EMAIL environment variable is not set')
        if not password:
            raise CommandError('DJANGO_SUPERUSER_PASSWORD environment variable is not set')

        # Check if the user already exists
        if User.objects.filter(username=username).exists():
            self.stdout.write(self.style.WARNING(f'Superuser "{username}" already exists'))
        else:
            # Create the superuser
            User.objects.create_superuser(username=username, email=email, password=password)
            self.stdout.write(self.style.SUCCESS(f'Superuser "{username}" created successfully'))

        # Run create_initial_data command
        self.stdout.write('Running create_initial_data command...')
        call_command('create_initial_data')
        self.stdout.write(self.style.SUCCESS('All initialization completed successfully')) 