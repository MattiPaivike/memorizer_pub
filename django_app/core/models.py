from django.db import models
from django.contrib.auth.models import User
from taggit.managers import TaggableManager

function_call_prompt = """
You will receive a string for a note taking appliction. Analyze the note text and look for actionable items.

Instructions:
1. Identify actionable items in the text, which may include tasks, follow-ups, reminders, or any statements implying a required action.
2. For each actionable item found, create a corresponding entry in a todo list.
3. Additionally, create a maximum of three suitable unique categories for the note.
4. Maintain the original language of the user's input, even if it is not in English.
5. If no actionable items exist in the text, respond with an empty JSON object in the format {"tasks": [], "categories": []}.

Output:
- Return a JSON object with two keys:
  - "tasks": an array containing each actionable item as a string.
  - "categories": an array with a maximum of three unique categories related to the note.
- If there are no actionable items, return {"tasks": [], "categories": []}.

Example Output:
{
    "tasks": [
        "Follow up with client on project status",
        "Prepare presentation for next week's meeting",
        "Order supplies for office"
    ],
    "categories": [
        "Client Management",
        "Presentations",
        "Supplies"
    ]
}
"""

note_prompt = ("Your mission is to assist in transforming user input into a coherent "
          "and well-structured note for a note-taking application, adhering to "
          "the following guidelines:\n\n"
          "### Content Enhancement:\n"
          "1. **Correct Typos:** Identify and correct any typographical errors present in the original input.\n"
          "2. **Maintain Original Language:** Preserve the original language of the user's input, do NOT change the language to english if the user's input is not in english.\n"
          "3. **Minimal Addition:** While maintaining coherency, only introduce minimal additions to the content. Refrain from adding content that can be measured in sentences.\n\n"
          "### Markdown Formatting:\n"
          "4. **Structured Formatting:** Implement markdown markup language to format the note, ensuring it is easy to read and well-organized.\n"
          "5. **Heading and Subheading:** If possible, distinguish between main points and subpoints, utilizing appropriate markdown headers.\n\n"
          "### General Instructions:\n"
          "6. **Do Not Add a Footer:** Ensure that no footer or additional closing statements are introduced at the end of the note.\n"
          "7. **Coherency is Key:** Ensure that any changes or additions maintain the coherence and intended message of the original note.\n\n"
          "Example:\n"
          "User Input: \"Meting with John on 10/10, discuss: budgets 2023, marketing strategy, and new hires\"\n\n"
          "Transformed Note:\n"
          "# Meeting with John on 10/10\n\n"
          "## Discussions:\n"
          "  - Budgets for 2023\n"
          "  - Marketing strategy\n"
          "  - New hires\n"
          "### Please ensure the following:\n"
          "- Accuracy: Guarantee that the information accuracy is preserved during the transformation and editing.\n"
          "- User-Friendliness: The final note should be user-friendly and easily navigable for reference.\n\n"
          "Remember, your primary role is to enhance and format user input into a cleaner, "
          "well-structured, and professional-looking note while strictly adhering to the given "
          "instructions and maintaining the original intent and language.")

# User level OpenAI settings so user can change prompt
class OpenAISettingsUser(models.Model):
    note_prompt = models.CharField(max_length=4000, default=note_prompt)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    
# 1 to 1 field for user
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    last_posted = models.DateTimeField(null=True, blank=True)

# System level OpenAI settings, not user specific
class OpenAISettings(models.Model):
    function_call_prompt = models.CharField(max_length=4000, default=function_call_prompt)
    note_prompt = models.CharField(max_length=4000, default=note_prompt)
    
class Note(models.Model):
    def get_default_todos():
        return []
    
    title = models.CharField(max_length=128)
    processed_note = models.TextField(max_length=4000, default='Note is being processed by GPT-4..')
    original_note = models.TextField(max_length=4000)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    tags = TaggableManager(blank=True) # https://github.com/jazzband/django-taggit
    todos = models.JSONField(default=get_default_todos, null=True, blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="notes")
    processed = models.BooleanField(default=False)
    
    def add_todo(self, task, save=True):
        todos = self.todos
        todo_id = len(todos)
        todos.append(
            {
                "id": todo_id,
                "task": task, 
                "is_completed": False
            }
        )
        if save is True:
            self.save()

    def update_todo(self, todo_id, new_task=None, is_completed=None):
        
        for todo in self.todos:
            if todo['id'] == todo_id:
                if new_task is not None:
                    todo['task'] = new_task
                if is_completed is None:  # If is_completed is None, toggle the current state
                    
                    todo['is_completed'] = not todo['is_completed']
                elif is_completed is not None:  # If is_completed is provided, set to the provided value
                    todo['is_completed'] = is_completed
                self.save()
                return True  # Return True if update is successful
        return False  # Return False if no to-do item with the given ID is found
    
    def delete_todo(self, todo_id):
        # Filter out the todo with the given id
        new_todos = [todo for todo in self.todos if todo['id'] != todo_id]
        
        if len(new_todos) == len(self.todos):  # No todo was deleted
            return False
        
        self.todos = new_todos
        self.save()
        return True

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title
