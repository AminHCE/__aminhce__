from django.urls import path

from .views import resume_view

urlpatterns = [
    path('<str:language>', resume_view, name='resume'),
]
