from django.http import HttpResponse
from django.template import loader


def home_view(request):

    context = {}
    temp = loader.get_template('website/index.html')
    return HttpResponse(temp.render(context, request))
