from django.contrib import admin

from django_summernote.admin import SummernoteModelAdmin

from .models import Information, Group, Skill, Link, LanguageSkill, Education, Experience, Project, Certificate


@admin.register(Information)
class InformationAdmin(SummernoteModelAdmin):
    list_display = ['full_name', 'language']
    summernote_fields = ['about_me']
    save_as = True


@admin.register(Group)
class GroupAdmin(admin.ModelAdmin):
    save_as = True


@admin.register(Skill)
class SkillAdmin(admin.ModelAdmin):
    save_as = True


@admin.register(Link)
class LinkAdmin(admin.ModelAdmin):
    save_as = True


@admin.register(LanguageSkill)
class LanguageSkillAdmin(admin.ModelAdmin):
    list_display = ['name', 'language']
    save_as = True


@admin.register(Education)
class EducationAdmin(SummernoteModelAdmin):
    list_display = ['title', 'language']
    summernote_fields = ['description']
    save_as = True


@admin.register(Experience)
class ExperienceAdmin(SummernoteModelAdmin):
    list_display = ['company_name', 'language']
    summernote_fields = ['description']
    save_as = True


@admin.register(Project)
class ProjectAdmin(SummernoteModelAdmin):
    list_display = ['project_name', 'language']
    summernote_fields = ['description']
    save_as = True


@admin.register(Certificate)
class CertificateAdmin(admin.ModelAdmin):
    list_display = ['title', 'language']
    save_as = True
