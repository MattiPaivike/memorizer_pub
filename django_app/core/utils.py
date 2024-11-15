import os
import boto3
import json
import json
from .tasks import openai_celery_call
from django.utils.safestring import mark_safe
import markdown
from django.utils.html import escape

def build_note_extra(note):
    # First escape any HTML in the note
    safe_note = escape(note.processed_note)
    
    # Intelligently truncate at a safe point
    truncated_md = truncate_markdown(safe_note, length=100)
    
    rendered_md = mark_safe(markdown.markdown(
        truncated_md,
        extensions=['fenced_code', 'codehilite'],
        # Add safe mode to prevent HTML injection
        safe_mode='escape'
    ))
    
    todos = note.todos
    return {
        'note': note,
        'rendered_md': rendered_md,
        'todos': todos
    }

def truncate_markdown(text, length=100):
    """
    Intelligently truncate markdown text while preserving syntax
    """
    # If text is shorter than limit, return as is
    if len(text) <= length:
        return text
        
    # Find the last occurrence of common markdown markers before the limit
    markers = ['\n\n', '. ', '! ', '? ', '\n']
    best_position = length
    
    # Check if we're in the middle of a code block
    code_blocks = text[:length].count('```')
    if code_blocks % 2 != 0:
        # Find the next closing code block marker
        next_code_block = text[length:].find('```')
        if next_code_block != -1:
            return text[:length + next_code_block + 3]
    
    # Find the best breaking point
    for marker in markers:
        position = text[:length].rfind(marker)
        if position > 0:
            best_position = position
            break
            
    return text[:best_position] + '...'

def post_to_queue(payload: str, note_user_id: str, note_pk: str, create_todo_list: bool=True) -> dict:
    """
    Send message to either AWS SQS queue or locally running Redis/Celery
    
    args:
        payload (str): note text to be sent to GPT
        note_pk (int): the primary key of the note object in the database
        note_user_id (int): the primary name of the user who created the note
        create_todo_list (bool): if True, the function calling model will always attempt to create a todo list
    """

    if bool(int(os.getenv('LOCAL_EXECUTION', 0))) is True or bool(int(os.getenv('USE_CELERY', 0))) is True:
        openai_celery_call.delay(
            payload=payload,
            note_user_id=note_user_id,
            note_pk=note_pk,
            create_todo_list=create_todo_list
        )
    else:
        data = {
            "payload": payload,
            "note_pk": note_pk,
            "note_user_id": note_user_id,
            "create_todo_list": create_todo_list
        }
        sqs = boto3.client('sqs')
        queue_url = os.getenv('SQS_URL')
        response = sqs.send_message(
            MessageBody=json.dumps(
                data,
                ensure_ascii=False
            ),
            QueueUrl=queue_url
        )
        return response