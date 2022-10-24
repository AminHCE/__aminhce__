from django.db import models

from applications.utils.models import Language


class Information(Language):
    full_name = models.CharField(max_length=150)
    phone = models.CharField(max_length=20, blank=True, null=True)
    website = models.URLField(blank=True, null=True)
    email = models.EmailField(blank=True, null=True)
    address = models.CharField(max_length=150, blank=True, null=True)
    quote = models.CharField(max_length=150, blank=True, null=True)
    about_me = models.TextField(blank=True, null=True)

    linkedin = models.URLField(blank=True, null=True)
    instagram = models.URLField(blank=True, null=True)
    twitter = models.URLField(blank=True, null=True)
    github = models.URLField(blank=True, null=True)


class Skill(models.Model):
    name = models.CharField(max_length=50)
    sub_name = models.CharField(max_length=50, blank=True, null=True)
    rate = models.IntegerField(blank=True, null=True)
    order = models.SmallIntegerField(default=0)

    class Meta:
        ordering = ('order', 'id')

    def __str__(self):
        return self.name


class Group(models.Model):
    title = models.CharField(max_length=50)
    skills = models.ManyToManyField(Skill, blank=True)

    class Meta:
        ordering = ("id",)

    def __str__(self):
        return self.title


class Link(Language):
    title = models.CharField(max_length=50)
    url = models.URLField()

    def __str__(self):
        return self.title


class LanguageSkill(Language):
    name = models.CharField(max_length=50)
    reading = models.IntegerField()
    writing = models.IntegerField()
    listening = models.IntegerField()
    speaking = models.IntegerField()

    def __str__(self):
        return self.name


class Education(Language):
    title = models.CharField(max_length=150)
    university = models.CharField(max_length=150, blank=True, null=True)
    begin_time = models.DateField(blank=True, null=True)
    end_time = models.DateField(blank=True, null=True)
    current = models.BooleanField(default=False)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.title


class Experience(Language):
    company_name = models.CharField(max_length=100)
    company_website = models.URLField(blank=True, null=True)
    project_name = models.CharField(max_length=100)
    location = models.CharField(max_length=100, blank=True, null=True)
    start_date = models.DateField(blank=True, null=True)
    end_date = models.DateField(blank=True, null=True)
    current = models.BooleanField(default=False)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.company_name


class Project(Language):
    project_name = models.CharField(max_length=100)
    subtitle = models.CharField(max_length=100)
    company_website = models.URLField(blank=True, null=True)
    location = models.CharField(max_length=100, blank=True, null=True)
    start_date = models.DateField(blank=True, null=True)
    end_date = models.DateField(blank=True, null=True)
    current = models.BooleanField(default=False)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.project_name


class Certificate(Language):
    title = models.CharField(max_length=100)
    picture = models.FileField(blank=True, null=True)
    pdf = models.FileField(blank=True, null=True)
    issue_date = models.DateField(blank=True, null=True)
    expire_date = models.DateField(blank=True, null=True)
    institute = models.CharField(max_length=150, blank=True, null=True)

    def __str__(self):
        return self.title

