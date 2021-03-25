from .settings import *

ALLOWED_HOSTS = ['*']

INSTALLED_APPS += [

]

DEBUG = True

STATIC_URL = '/static/'

STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'public_www/static'),
)

MEDIA_URL = '/media/'

MEDIA_ROOT = os.path.join(BASE_DIR, 'public_www/media')

SITE_ADDRESS = 'http://localhost:8000'

# django-import-export:
IMPORT_EXPORT_USE_TRANSACTIONS = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
