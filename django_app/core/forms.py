from django import forms
from .models import Note, OpenAISettingsUser

class NoteForm(forms.ModelForm):
    send_to_openai_checkbox = forms.BooleanField(
        required=False, 
        initial=True,
        label='Send to OpenAI (otherwise saved straight to database)', 
        widget=forms.CheckboxInput(attrs={'class': 'my-checkbox-class'})  # You can set HTML attributes here
    )
    force_openai_todo_list_creation = forms.BooleanField(
        required=False, 
        initial=True,
        label='Create to-do list and categories. (Leave checked and the LLM will always attempt to create a todo list and categories.)', 
        widget=forms.CheckboxInput(attrs={'class': 'my-checkbox-class'})  # You can set HTML attributes here
    )
    class Meta:
        model = Note
        fields = ['title', 'original_note']

class EditNoteForm(forms.ModelForm):
    class Meta:
        model = Note
        fields = ['title', 'processed_note', 'original_note', 'todos']
        
class EditOpenAISettingsForm(forms.ModelForm):
    class Meta:
        model = OpenAISettingsUser
        fields = ['note_prompt']
