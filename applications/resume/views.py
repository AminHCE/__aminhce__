from django.http import HttpResponse, Http404
from django.template import loader

from applications.resume.models import Experience, Project, Education, Information, Certificate, Group


def resume_view(request, language):
    if language == 'en':
        temp = loader.get_template('resume/ltr-resume.html')
        language_code = 1
    elif language == 'fa':
        temp = loader.get_template('resume/rtl-resume.html')
        language_code = 2
    else:
        raise Http404

    information = Information.objects.get(language=language_code)
    group = Group.objects.all()
    experiences = Experience.objects.filter(language=language_code).order_by('-start_date')
    projects = Project.objects.filter(language=language_code).order_by('-start_date')
    educations = Education.objects.filter(language=language_code).order_by('-begin_time')
    certificates = Certificate.objects.filter(language=language_code).order_by('-issue_date')

    context = {'information': information, 'group': group, 'experiences': experiences, 'projects': projects,
               'educations': educations, 'certificates': certificates}

    return HttpResponse(temp.render(context, request))
