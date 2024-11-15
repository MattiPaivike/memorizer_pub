import os
if bool(int(os.getenv('LOCAL_EXECUTION', 0))) is True or bool(int(os.getenv('USE_CELERY', 0))) is True:
    from .celery import app as celery_app

    __all__ = ("celery_app",)