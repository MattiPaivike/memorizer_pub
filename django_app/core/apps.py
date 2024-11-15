from django.apps import AppConfig
from django.conf import settings

class CoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    # workaround for django in lambda issue
    if "core" in settings.INSTALLED_APPS:
        name = "core"
    else:
        name = "django_app.core"
    
    def ready(self):
        # workaround for django in lambda issue
        if "core" in settings.INSTALLED_APPS:
            import core.signals

