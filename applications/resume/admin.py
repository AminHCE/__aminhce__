from django.contrib import admin

from django_summernote.admin import SummernoteModelAdmin

from .models import Information, Group, Skill, Link, LanguageSkill, Education, Experience, Project, Certificate


@admin.register(Information)
class InformationAdmin(SummernoteModelAdmin):
    summernote_fields = ['about_me']


@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    pass


@admin.register(Skill)
class SkillAdmin(admin.ModelAdmin):
    pass


@admin.register(Link)
class LinkAdmin(admin.ModelAdmin):
    pass


@admin.register(LanguageSkill)
class LanguageSkillAdmin(admin.ModelAdmin):
    pass


@admin.register(Education)
class EducationAdmin(admin.ModelAdmin):
    pass


@admin.register(Experience)
class ExperienceAdmin(SummernoteModelAdmin):
    summernote_fields = ['description']


@admin.register(Project)
class ProjectAdmin(SummernoteModelAdmin):
    summernote_fields = ['description']


@admin.register(Certificate)
class CertificateAdmin(admin.ModelAdmin):
    pass
