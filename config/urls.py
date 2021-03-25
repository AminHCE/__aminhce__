from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('summernote/', include('django_summernote.urls')),

    path('', include('applications.website.urls', namespace='website')),
    path('resume/', include('applications.resume.urls', namespace='resume')),
]
