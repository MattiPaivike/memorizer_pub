from django.urls import path, include
from core import views
from rest_framework.routers import DefaultRouter
from .views import NoteViewSet

router = DefaultRouter()
router.register(r'notes', NoteViewSet)

urlpatterns = [
    path('', views.NotesView.as_view(), name='notes'),
    path('accounts/', include('allauth.urls')),
    path('postnote/', views.post_note, name='post_note'),
    path('about/', views.AboutView.as_view(), name='about'),
    path('accounts/account/', views.AccountView.as_view(), name='account_profile'),
    path('accounts/token/', views.request_api_key, name='account_token'),
    path('api/', include(router.urls)),
    path('api/', include('dj_rest_auth.urls')),
    path('delete-note/<int:pk>/', views.delete_note, name='delete_note'),
    path('accounts/updateprompt/', views.EditOpenAISettingsUser.as_view(), name='account_update_prompt'),
]

htmxpatterns = [
    path('notesresults/', views.NotesResults.as_view(), name='notes_results'),
    path('detail/<int:pk>/', views.detail, name='note_detail'),
    path('notes/<int:pk>/edit/', views.edit_note, name='edit_note'),
    path('notes/<int:pk>/update/', views.update_note, name='update_note'),
    path('toggletodo/<int:pk>/<int:todo_id>/', views.toggle_todo, name='toggle_todo'),
    path('deletetodo/<int:pk>/<int:todo_id>/', views.delete_todo, name='delete_todo'),
    path('addtodo/<int:pk>/', views.add_todo, name='add_todo'),
    path('check_note_status_list/<int:pk>/', views.check_note_status_list, name='check_note_status_list'),
    path('check_note_status_detail/<int:pk>/', views.check_note_status_detail, name='check_note_status_detail'),
]

urlpatterns += htmxpatterns
