from django.contrib import admin
from .models import Note, OpenAISettings, UserProfile, OpenAISettingsUser
from django.db import models
from django import forms

class OpenAISettingsAdmin(admin.ModelAdmin):
    formfield_overrides = {
        models.CharField: {'widget': forms.Textarea(attrs={'rows':5, 'cols':150})},
    }

admin.site.register(Note)
admin.site.register(OpenAISettings, OpenAISettingsAdmin)
admin.site.register(UserProfile)
admin.site.register(OpenAISettingsUser, OpenAISettingsAdmin)
