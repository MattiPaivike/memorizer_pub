import sys
import json
import os
from openai import OpenAI, AzureOpenAI
from django_app.core.models import Note
from django_app.core.models import OpenAISettings, User
from typing import Union, Literal
from aws_utils import get_ssm_parameter

def initialize_openai_client():
    api_type = os.getenv("OPENAI_API_TYPE", "openai")
    
    if api_type == "azure":
        return AzureOpenAI(
            api_version=os.getenv("OPENAI_API_VERSION"),
            api_endpoint=os.getenv("AZURE_OPENAI_API_BASE_URL"),
        )
    else:
        return OpenAI(
            api_key=get_ssm_parameter(os.getenv('OPENAI_API_KEY_SSM_NAME')),
        )
    
def openai_completion_call(
    openai_client: Union[OpenAI, AzureOpenAI],
    model_name: str,
    temperature: float,
    set_frequency_penalty: bool,
    messages_payload: dict,
    frequency_penalty: float = 0.0,
    json_mode: bool = True,
) -> dict:
    """
    This function calls the OpenAI completion API in JSON mode and returns the response.

    Args:
        openai_client: An instance of AzureOpenAI client.
        model_name (str): The name of the OpenAI model to use.
        temperature (float): The 'temperature' setting for the API call.
        set_frequency_penalty (bool): A flag to determine whether to use the 'frequency_penalty'.
        messages_payload (dict): The payload to send in the completion call.
        frequency_penalty (float, optional): The 'frequency_penalty' value. Default is 0.0.
        json_mode (bool, optional): A flag to determine whether to use the JSON mode. Default is True.
    """

    api_params = {
        "model": model_name,
        "temperature": temperature,
        "messages": messages_payload,
        "seed": 1,
    }

    if json_mode is True:
        api_params["response_format"] = {"type": "json_object"}

    if set_frequency_penalty:
        api_params["frequency_penalty"] = frequency_penalty

    openai_call = openai_client.chat.completions.create(**api_params)

    return openai_call

def process_completion_todo_list(
    reply_content: dict
) -> tuple[int, int, list, list]:
    """
    Processes the OpenAI API response to extract token usage and lists of tasks and categories.

    Args:
        reply_content (dict): OpenAI completion call reply

    Returns:
        tuple: A tuple containing:
            - completion_token_usage (int): Number of tokens used for the completion.
            - prompt_token_usage (int): Number of tokens used for the prompt.
            - tasks (list): List of tasks identified in the response.
            - categories (list): List of categories identified in the response.
    """

    # Verify if the completion finished successfully
    if reply_content.choices[0].finish_reason != "stop":
        raise ValueError(
            f"OpenAI completion call did not finish successfully. Finish reason: {reply_content.choices[0].finish_reason}"
        )
    
    # Extract token usage data
    prompt_token_usage = reply_content.usage.prompt_tokens
    completion_token_usage = reply_content.usage.completion_tokens

    # Load JSON content from the response message
    try:
        json_content = json.loads(reply_content.choices[0].message.content)
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON format in the response content: {e}")

    # Extract "tasks" and "categories" from the JSON content
    tasks = json_content.get("tasks", [])
    categories = json_content.get("categories", [])

    # Return token counts along with the extracted lists
    return completion_token_usage, prompt_token_usage, tasks, categories

def process_completion_call_main_note(
    reply_content: dict,
) -> tuple[int, int, str]:
    """
    This function processes the reply from OpenAI completion call.

    Args:
        reply_content (dict): OpenAI completion call reply
    """

    if reply_content.choices[0].finish_reason != "stop":
        raise ValueError(
            f"OpenAI completion call did not finish successfully. Finish reason: {reply_content.choices[0].finish_reason}"
        )
    prompt_token_usage = reply_content.usage.prompt_tokens
    completion_token_usage = reply_content.usage.completion_tokens
    return (
        completion_token_usage,
        prompt_token_usage,
        reply_content.choices[0].message.content,
    )

def create_openai_payload(note_text: str, note_user_id, note_type: Literal["main_note", "todo_list"] = "main_note",) -> dict:
    """
    This function creates the OpenAI completion call messages dictionary

    Args:
        note_text (str): The note text to process.
        note_user_id (int): The ID of the user who created the note.
    """
    if note_type == "main_note":
        django_user = User.objects.get(pk=note_user_id)
        prompt = django_user.openaisettingsuser.note_prompt
    else:
        prompt = OpenAISettings.objects.all().first().function_call_prompt

    completion_call_messages = [
        {
            "role": "system",
            "content": prompt,
        },
        {
            "role": "user",
            "content": note_text,
        }
    ]

    return completion_call_messages

def main_openai_note_call(payload: str, note_user_id: str, note_pk: int, create_todo_list: bool=True):
    """
    Function to process a note with OpenAI language model

    args:
        payload (str): note text to be sent to OpenAI language model
        note_pk (int): the primary key of the note object in the database
        note_user_id (int): the name of the user who created the note
        create_todo_list (bool): if True, the language model will always attempt to create a todo list
    """
    total_completion_token_usage = 0
    total_prompt_token_usage = 0
    openai_client = initialize_openai_client()
    openai_model = os.getenv('OPENAI_COMPLETION_MODEL_DEPLOYMENT_NAME', 'gpt-4o-mini')

    # get the todo list prompt
    if create_todo_list is True:
        todo_list_payload = create_openai_payload(
            note_text=payload,
            note_user_id=note_user_id,
            note_type="todo_list"
        )
    # create note payload for openai
    main_note_payload = create_openai_payload(
        note_text=payload,
        note_user_id=note_user_id,
        note_type="main_note"
    )

    try:
        note = Note.objects.get(pk=note_pk)
    except Note.DoesNotExist:
        print(f"Note with id: {note_pk} does not exist. User most likely deleted the note before it could be processed.")
        sys.exit(1)
    
    # OpenAI calls:
    # first run the completion without function call to get a well formatted note
    try:
        completion = openai_completion_call(
            openai_client=openai_client,
            model_name=openai_model,
            temperature=0.0,
            set_frequency_penalty=False,
            messages_payload=main_note_payload,
            json_mode=False,
        )
        
        total_completion_token_usage, total_prompt_token_usage, reply_content = process_completion_call_main_note(
            reply_content=completion,
        )
        note.processed_note = reply_content
    except Exception as err:
        error_msg = f"Error in OpenAI completion: {err}"
        print(error_msg)
        note.processed_note = error_msg
        note.save()
        sys.exit(1)

    print("Total completion token usage for main note: ", total_completion_token_usage)
    print("Total prompt token usage for main note: ", total_prompt_token_usage)
    
    # run the todo list call
    if create_todo_list is True:
        completion = openai_completion_call(
            openai_client=openai_client,
            model_name=openai_model,
            temperature=0.0,
            set_frequency_penalty=False,
            messages_payload=todo_list_payload,
            json_mode=True
        )

    total_completion_token_usage, total_prompt_token_usage, todo_list_items, note_categories = process_completion_todo_list(
        reply_content=completion,
    )
    if note_categories != []:
        for category in note_categories:
            note.tags.add(category)
        
    if todo_list_items != []:
        for todo in todo_list_items:
            note.add_todo(todo, save=False)

    print("Total completion token usage for todo list: ", total_completion_token_usage)
    print("Total prompt token usage for todo list: ", total_prompt_token_usage)

    note.processed = True
    note.save()