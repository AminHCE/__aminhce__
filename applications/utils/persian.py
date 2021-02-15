from django.utils.html import strip_tags

__author__ = 'M.Y'
import re


def enToPersianNumb(number):
    dic = {
        '0': '۰',
        '1': '۱',
        '2': '۲',
        '3': '۳',
        '4': '۴',
        '5': '۵',
        '6': '۶',
        '7': '۷',
        '8': '۸',
        '9': '۹',
        '.': '.',
    }
    return multiple_replace(dic, number)


def persianToEnNumb(number):
    dic = {
        '۰': '0',
        '۱': '1',
        '۲': '2',
        '۳': '3',
        '۴': '4',
        '۵': '5',
        '۶': '6',
        '۷': '7',
        '۸': '8',
        '۹': '9',
        '.': '.',
    }
    return multiple_replace(dic, number)


def enToPersianChar(userInput):
    dic = {  # Assumes that charaters written with standard persioan keyboard, not windows arabic layout
        'q': 'ض',
        'w': 'ص',
        'e': 'ث',
        'r': 'ق',
        't': 'ف',
        'y': 'غ',
        'u': 'ع',
        'i': 'ه',
        'o': 'خ',
        'p': 'ح',
        '[': 'ج',
        ']': 'چ',
        'a': 'ش',
        's': 'س',
        'd': 'ی',
        'f': 'ب',
        'g': 'ل',
        'h': 'ا',
        'j': 'ت',
        'k': 'ن',
        'l': 'م',
        ';': 'ک',
        "'": 'گ',
        'z': 'ظ',
        'x': 'ط',
        'c': 'ز',
        'v': 'ر',
        'b': 'ذ',
        'n': 'د',
        'm': 'پ',
        ',': 'و',
        '?': '؟',
    }
    return multiple_replace(dic, userInput)


def arToPersianNumb(number):
    dic = {
        '١': '۱',
        '٢': '۲',
        '٣': '۳',
        '٤': '۴',
        '٥': '۵',
        '٦': '۶',
        '٧': '۷',
        '٨': '۸',
        '٩': '۹',
        '٠': '۰',
    }
    return multiple_replace(dic, number)


def arToPersianChar(userInput):
    dic = {
        'ك': 'ک',
        'دِ': 'د',
        'بِ': 'ب',
        'زِ': 'ز',
        'ذِ': 'ذ',
        'شِ': 'ش',
        'سِ': 'س',
        'ى': 'ی',
        'ي': 'ی'
    }
    return strip_tags(multiple_replace(dic, userInput))


def multiple_replace(dic, text):
    if not text:
        return text
    pattern = "|".join(map(re.escape, dic.keys()))
    return re.sub(pattern, lambda m: dic[m.group()], str(text))
