from django.contrib import admin

from django_summernote.admin import SummernoteModelAdmin
from import_export.admin import ImportExportModelAdmin

from .models import Information, Group, Skill, Link, LanguageSkill, Education, Experience, Project, Certificate


@admin.register(Information)
class InformationAdmin(SummernoteModelAdmin, ImportExportModelAdmin):
    list_display = ['full_name', 'language']
    summernote_fields = ['about_me']
    save_as = True


@admin.register(Group)
class GroupAdmin(ImportExportModelAdmin):
    save_as = True


@admin.register(Skill)
class SkillAdmin(ImportExportModelAdmin):
    save_as = True


@admin.register(Link)
class LinkAdmin(ImportExportModelAdmin):
    save_as = True


@admin.register(LanguageSkill)
class LanguageSkillAdmin(ImportExportModelAdmin):
    list_display = ['name', 'language']
    save_as = True


@admin.register(Education)
class EducationAdmin(SummernoteModelAdmin, ImportExportModelAdmin):
    list_display = ['title', 'language']
    summernote_fields = ['description']
    save_as = True


@admin.register(Experience)
class ExperienceAdmin(SummernoteModelAdmin, ImportExportModelAdmin):
    list_display = ['company_name', 'language']
    summernote_fields = ['description']
    save_as = True


@admin.register(Project)
class ProjectAdmin(SummernoteModelAdmin, ImportExportModelAdmin):
    list_display = ['project_name', 'language']
    summernote_fields = ['description']
    save_as = True


@admin.register(Certificate)
class CertificateAdmin(ImportExportModelAdmin):
    list_display = ['title', 'language']
    save_as = True
