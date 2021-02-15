# -*- coding: utf-8 -*-
import datetime

import pytz
from django import template

from ..calverter import gregorian_to_jalali, gregorian_to_jalaliyearmonth
from ..persian import enToPersianNumb
register = template.Library()


@register.filter
def pdate(date):
    if not date:
        return ''
    if isinstance(date, datetime.datetime):
        date = date.astimezone(pytz.timezone("Asia/Tehran"))
    return enToPersianNumb(gregorian_to_jalaliyearmonth(date))
