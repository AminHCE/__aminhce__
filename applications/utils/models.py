from django.db import models


class Language(models.Model):
    EN = 1
    FA = 2
    LANGUAGE_CHOICES = (
        (EN, 'English'),
        (FA, 'Farsi'),
    )
    language = models.IntegerField(choices=LANGUAGE_CHOICES)

    class Meta:
        abstract = True
