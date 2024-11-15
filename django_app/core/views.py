from django.views.generic import TemplateView
from django.views.generic.list import ListView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator
from django.contrib import messages
from core.models import Note, OpenAISettingsUser, OpenAISettings
from django.conf import settings
from django.shortcuts import render, redirect
from django.views.decorators.http import require_http_methods
from django.http import HttpResponseRedirect
from .forms import NoteForm, EditNoteForm, EditOpenAISettingsForm
from .serializers import NoteSerializer
from django.db.models import Q
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.utils.safestring import mark_safe
from django.urls import reverse
from django.utils import timezone
from django.views import View
from datetime import timedelta
from .utils import post_to_queue, build_note_extra
import markdown
import os

class IndexView(TemplateView):
    template_name = 'index.html'
    
class AccountView(LoginRequiredMixin, TemplateView):
    template_name = 'account/account.html'
    
class AboutView(TemplateView):
    template_name = 'about.html'

class NotesView(LoginRequiredMixin, ListView):
    template_name = 'notes.html'
    model = Note
    paginate_by = settings.PAGINATE_BY
    context_object_name = 'notes'

    def get_template_names(self):
        if self.request.htmx:
            return "partials/notes-list.html"
        return "notes.html"

    def get_queryset(self):
        return Note.objects.filter(user=self.request.user).prefetch_related("tags")

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['view_name'] = 'NotesView'
        notes_with_extras = []
        for note in context['notes']:
            note_extra = build_note_extra(note)
            notes_with_extras.append(note_extra)
        context['notes_with_extras'] = notes_with_extras
        return context
    
# this view is used with search
class NotesResults(LoginRequiredMixin, ListView):
    template_name = 'partials/notes-list.html'
    model = Note
    context_object_name = 'notes'

    def post(self, request, *args, **kwargs):
        return self.get(request, *args, **kwargs)

    def get_queryset(self):
        if self.request.method == 'POST':
            search_text = self.request.POST.get('search-notes-field')
            users_notes = Note.objects.filter(user=self.request.user)
            search_results = users_notes.filter(
                Q(processed_note__icontains=search_text) |
                Q(title__icontains=search_text) |
                Q(original_note__icontains=search_text)
            )
            return search_results
        else:
            return Note.objects.filter(user=self.request.user)
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['view_name'] = 'NotesView'  # workaround variable to control when to use col-md-6 and row for note items on front page
        context['is_search'] = self.request.method == 'POST'  # Add a flag to indicate whether this is a search result
        notes_with_extras = []
        for note in context['notes']:
            note_extra = build_note_extra(note)  # Use the same build_note_extra function
            notes_with_extras.append(note_extra)
        context['notes_with_extras'] = notes_with_extras
        
        return context
        
# view for api
class NoteViewSet(viewsets.ModelViewSet):
    queryset = Note.objects.all()
    serializer_class = NoteSerializer
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def get_queryset(self):
        return Note.objects.filter(user=self.request.user)
    
    def create(self, request, *args, **kwargs):
        user = request.user
        time_limit = timedelta(seconds=15)
        
        # Check if user has posted within the last 60 seconds, do not do it when running locally
        if bool(int(os.getenv('LOCAL_EXECUTION', 0))) is False:
            if user.userprofile.last_posted:
                time_since_last_post = timezone.now() - user.userprofile.last_posted
                if time_since_last_post < time_limit:
                    return Response({"detail": "You must wait 60 seconds between posts."}, status=status.HTTP_429_TOO_MANY_REQUESTS)
        
        response = super().create(request, *args, **kwargs)
        user.userprofile.last_posted = timezone.now()  # Update the last_posted field on user model
        user.userprofile.save()
        user.save()
        return response
    
    def perform_update(self, serializer):
        # could be used for service users in the future
        if self.request.user.username == 'service_user':
            # Ensure only the contents of the note are updated and not the user.
            instance = self.get_object()
            serializer.save(user=instance.user)
        else:
            serializer.save(user=self.request.user)
        
@login_required
def detail(request, pk):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')
        
    if note.user != request.user:
        return redirect('notes')
    
    processed_note_md = mark_safe(markdown.markdown(note.processed_note, extensions=['fenced_code', 'codehilite']))
    context = {
        'note': note,
        'processed_note_md': processed_note_md,
        'todos': note.todos,
        'view_name': 'NotesView'
    }
    
    if request.htmx:
        return render(request, 'partials/note-detail.html', context)
    else:
        # this view is used when user reloads note_detail view or is forwarded from note edit page after save
        # workaround to fix issue of only partial loading
        return render(request, 'note-detail-full.html', context)
    
@login_required
def check_note_status_detail(request, pk):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')

    if note.user != request.user:
        return redirect('notes')

    if note.processed:
        processed_note_md = mark_safe(markdown.markdown(
            note.processed_note, extensions=['fenced_code', 'codehilite']))
        context = {
            'note': note,
            'processed_note_md': processed_note_md,
            'todos': note.todos,
        }
        return render(request, 'partials/note-content-detail.html', context)
    else:
        context = {
            'note': note,
        }
        return render(request, 'partials/note-loading-detail.html', context)
    

@login_required
def check_note_status_list(request, pk):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')

    if note.user != request.user:
        return redirect('notes')

    if note.processed:
        note_extra = build_note_extra(note)
        context = {'note_extra': note_extra}
        return render(request, 'partials/note-content-list.html', context)
    else:
        context = {'note': note}
        return render(request, 'partials/note-loading-list.html', context)
    
@require_http_methods(['DELETE'])
@login_required
def delete_note(request, pk):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')
    if note.user == request.user:
        note.delete()
    return HttpResponseRedirect(reverse('notes'), status=303) # need to respond with 303 to avoid bug with htmx

@login_required
def post_note(request):
    user = request.user
    post_message = True
        
    if request.method == 'POST':
        form = NoteForm(request.POST)
        if form.is_valid():
            # Save if not sent to openAI
            if form.cleaned_data['send_to_openai_checkbox'] is False:
                note = form.save(commit=False)
                note.processed_note = form.cleaned_data['original_note']
                note.processed = True
                note.user = request.user
                note.save()
                return redirect('note_detail', pk=note.pk)
            else:
                time_limit = timedelta(seconds=15)
                # Check the time of the last post
                if user.userprofile.last_posted:
                    time_since_last_post = timezone.now() - user.userprofile.last_posted
                    # Check if user has posted within the last 60 seconds, do not do it when running locally
                    if bool(int(os.getenv('LOCAL_EXECUTION', 0))) is False:
                        if time_since_last_post < time_limit:
                            messages.success(request, 'Error! You must wait 60 seconds between posts.')
                            post_message = False
                if post_message  == True:
                    note = form.save(commit=False)
                    note.user = request.user
                    note.save()
                    user.userprofile.last_posted = timezone.now()
                    user.userprofile.save()
                    user.save()
                    post_to_queue(
                        payload=f"{note.title}: {note.original_note}", 
                        note_user_id=request.user.id, 
                        note_pk=note.pk,
                        create_todo_list = form.cleaned_data['force_openai_todo_list_creation'],
                    )
                    messages.success(request, 'Note added to database, takes a little while for GPT to process it..')
                return redirect('note_detail', pk=note.pk)
    else:
        form = NoteForm()
    
    return render(request, 'forms/post-note.html', {'form': form})

@login_required
def request_api_key(request):
    user = request.user
    #Token.objects.filter(user=user).delete()  # Delete old token if exists
    token, created = Token.objects.get_or_create(user=user)
    return render(request, 'account/token.html', {'token': token})

@login_required
def edit_note(request, pk):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')
    
    if note.user != request.user:
        return redirect('notes')
    
    form = EditNoteForm(instance=note)
    if request.method == "GET":
        return render(request, 'partials/edit-note.html', {'form': form, 'note': note})

@login_required
def update_note(request, pk):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')
    
    if note.user != request.user:
        return redirect('notes')
    
    if request.method == "POST":
        form = EditNoteForm(request.POST, instance=note)
        if form.is_valid():
            form.save()
            messages.success(request, f'Note updated')
            return redirect('note_detail', pk=pk)  # Redirect to the appropriate view after update.
        else:
            return redirect('notes')
    else:
        return redirect('note_detail', pk=pk)
    
@method_decorator(login_required, name='dispatch')
class EditOpenAISettingsUser(View):
    template_name = 'forms/update-prompt.html'
    
    def get(self, request, *args, **kwargs):
        try:
            user_settings = OpenAISettingsUser.objects.get(user=request.user)
        except OpenAISettingsUser.DoesNotExist:
            return redirect('notes')
        if user_settings.user != request.user:
            return redirect('notes')
        
        form = EditOpenAISettingsForm(instance=user_settings)
        return render(request, self.template_name, {'form': form})

    def post(self, request, *args, **kwargs):
        try:
            user_settings = OpenAISettingsUser.objects.get(user=request.user)
        except OpenAISettingsUser.DoesNotExist:
            return redirect('notes')
        
        form = EditOpenAISettingsForm(request.POST, instance=user_settings)
        
        if 'action' in request.POST:
            if request.POST['action'] == 'save' and form.is_valid():
                form.save()
            elif request.POST['action'] == 'set_defaults':
                default_settings = OpenAISettings.objects.all().first()
                user_settings.note_prompt = default_settings.note_prompt
                user_settings.save()
            messages.success(request, 'OpenAI prompt updated')
            # redirect to prevent form resubmission on refresh
            return redirect('post_note')

        return render(request, self.template_name, {'form': form})

@require_http_methods(['POST'])
@login_required
def toggle_todo(request, pk, todo_id):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')
    
    if note.user != request.user:
        return redirect('notes')

    note.update_todo(todo_id, is_completed=None)
    context = {
        'note': note,
        'todos': note.todos,
        'view_name': 'NotesView'
    }
    return render(request, 'partials/todo-list.html', context)

@require_http_methods(['DELETE'])
@login_required
def delete_todo(request, pk, todo_id):
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')
    
    if note.user != request.user:
        return redirect('notes')
        
    note.delete_todo(todo_id)
    context = {
        'note': note,
        'todos': note.todos,
        'view_name': 'NotesView'
    }
    return render(request, 'partials/todo-list.html', context)

@require_http_methods(['POST'])
@login_required
def add_todo(request, pk):
    
    try:
        note = Note.objects.get(pk=pk)
    except Note.DoesNotExist:
        return redirect('notes')
    
    if note.user != request.user:
        return redirect('notes')

    task = request.POST.get('task')
    
    if task:
        note.add_todo(task)
        
    context = {
        'note': note,
        'todos': note.todos,
        'view_name': 'NotesView'
    }
        
    return render(request, 'partials/todo-list.html', context)
