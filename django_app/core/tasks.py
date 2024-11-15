from celery import shared_task
from .openai_utils import main_openai_note_call

@shared_task(bind=True)
def openai_celery_call(self, payload, note_user_id, note_pk, create_todo_list):
    main_openai_note_call(payload, note_user_id, note_pk, create_todo_list)