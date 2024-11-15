from django.core.management.base import BaseCommand
from core.models import OpenAISettings

# This script creates initial OpenAI prompts data to database.

class Command(BaseCommand):
    help = 'Create initial OpenAI prompt data'

    def handle(self, *args, **options):
        if not OpenAISettings.objects.exists():
            OpenAISettings.objects.create()
            print("Initial data created")
