import os
from .settings import *

# Override ALLOWED_HOSTS for local development
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '*').split(',')

INSTALLED_APPS += [

]

# Override DEBUG for local development
DEBUG = os.environ.get('DEBUG', 'True').lower() == 'true'

# Static files configuration
STATIC_URL = os.environ.get('STATIC_URL', '/static/')
STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'public/static'),
)

MEDIA_URL = os.environ.get('MEDIA_URL', '/media/')
MEDIA_ROOT = os.environ.get('MEDIA_ROOT', os.path.join(BASE_DIR, 'public/media'))

SITE_ADDRESS = os.environ.get('SITE_ADDRESS', 'http://localhost:8000')

# Email configuration for local development
EMAIL_BACKEND = os.environ.get('EMAIL_BACKEND', 'django.core.mail.backends.console.EmailBackend')

# django-import-export:
IMPORT_EXPORT_USE_TRANSACTIONS = True

# Logging configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': os.environ.get('LOG_LEVEL', 'DEBUG'),
    },
}
