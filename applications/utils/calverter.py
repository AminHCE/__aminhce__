# -*- coding: utf-8 -*-
from typing import Optional

import pytz

from applications.utils.persian import persianToEnNumb

__author__ = 'Hourshad'

GREGORIAN_EPOCH = 1721425.5
GREGORIAN_WEEKDAYS = ("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")

JALALI_EPOCH = 1948320.5
JALALI_WEEKDAYS = [u"یکشنبه", u"دوشنبه", u"سه شنبه", u"چهارشنبه", u"پنجشنبه", u"جمعه", u"شنبه"]
MONTH_NAMES = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند']

import math


class Calverter:
    """
    Converter Main Class
    """

    def __init__(self):
        self.J0000 = 1721424.5  # Julian date of Gregorian epoch: 0000-01-01
        self.J1970 = 2440587.5  # Julian date at Unix epoch: 1970-01-01
        self.JMJD = 2400000.5  # Epoch of Modified Julian Date system
        self.J1900 = 2415020.5  # Epoch (day 1) of Excel 1900 date system (PC)
        self.J1904 = 2416480.5  # Epoch (day 0) of Excel 1904 date system (Mac)

        self.norm_leap = ("Normal year", "Leap year")

    def jwday(self, j):
        "Calculate day of week from Julian day"

        return int(math.floor((j + 1.5))) % 7

    def weekday_before(self, weekday, jd):
        """
        Return Julian date of given weekday (0 = Sunday)
        in the seven days ending on jd.
        """

        return jd - self.jwday(jd - weekday)

    def search_weekday(self, weekday, jd, direction, offset):
        """
        Determine the Julian date for:

        @param weekday: Day of week desired, 0 = Sunday
        @param jd: Julian date to begin search
        @param direction: 1 = next weekday, -1 = last weekday
        @param offset: Offset from jd to begin search
        """

        return self.weekday_before(weekday, jd + (direction * offset))

    # Utility weekday functions, just wrappers for search_weekday

    def nearest_weekday(self, weekday, jd):
        return self.search_weekday(weekday, jd, 1, 3)

    def next_weekday(self, weekday, jd):
        return self.search_weekday(weekday, jd, 1, 7)

    def next_or_current_weekday(self, weekday, jd):
        return self.search_weekday(weekday, jd, 1, 6)

    def previous_weekday(self, weekday, jd):
        return self.search_weekday(weekday, jd, -1, 1)

    def previous_or_current_weekday(self, weekday, jd):
        return self.search_weekday(weekday, jd, 1, 0)

    def leap_gregorian(self, year):
        "Is a given year in the Gregorian calendar a leap year ?"

        return ((year % 4) == 0) and (not (((year % 100) == 0) and ((year % 400) != 0)))

    def gregorian_to_jd(self, year, month, day):
        "Determine Julian day number from Gregorian calendar date"

        tm = 0 if month <= 2 else (-1 if self.leap_gregorian(year) else -2)

        return (GREGORIAN_EPOCH - 1) + (365 * (year - 1)) + math.floor((year - 1) / 4) + (
            -math.floor((year - 1) / 100)) + \
               math.floor((year - 1) / 400) + math.floor((((367 * month) - 362) / 12) + tm + day)

    def jd_to_gregorian(self, jd):
        "Calculate Gregorian calendar date from Julian day"

        wjd = math.floor(jd - 0.5) + 0.5
        depoch = wjd - GREGORIAN_EPOCH
        quadricent = math.floor(depoch / 146097)
        dqc = depoch % 146097
        cent = math.floor(dqc / 36524)
        dcent = dqc % 36524
        quad = math.floor(dcent / 1461)
        dquad = dcent % 1461
        yindex = math.floor(dquad / 365)
        year = int((quadricent * 400) + (cent * 100) + (quad * 4) + yindex)
        if not ((cent == 4) or (yindex == 4)):
            year += 1

        yearday = wjd - self.gregorian_to_jd(year, 1, 1)

        leapadj = 0 if wjd < self.gregorian_to_jd(year, 3, 1) else (1 if self.leap_gregorian(year) else 2)

        month = int(math.floor((((yearday + leapadj) * 12) + 373) / 367))
        day = int(wjd - self.gregorian_to_jd(year, month, 1)) + 1

        return year, month, day

    def n_weeks(self, weekday, jd, nthweek):

        j = 7 * nthweek
        if nthweek > 0:
            j += self.previous_weekday(weekday, jd)
        else:
            j += self.next_weekday(weekday, jd)
        return j

    def iso_to_julian(self, year, week, day):
        "Return Julian day of given ISO year, week, and day"

        return day + self.n_weeks(0, self.gregorian_to_jd(year - 1, 12, 28), week)

    def jd_to_iso(self, jd):
        "Return array of ISO (year, week, day) for Julian day"

        year = self.jd_to_gregorian(jd - 3)[0]
        if jd >= self.iso_to_julian(year + 1, 1, 1):
            year += 1

        week = int(math.floor((jd - self.iso_to_julian(year, 1, 1)) / 7) + 1)
        day = self.jwday(jd)
        if day == 0:
            day = 7

        return year, week, day

    def iso_day_to_julian(self, year, day):
        "Return Julian day of given ISO year, and day of year"

        return (day - 1) + self.gregorian_to_jd(year, 1, 1)

    def jd_to_iso_day(self, jd):
        "Return array of ISO (year, day_of_year) for Julian day"

        year = self.jd_to_gregorian(jd)[0]
        day = int(math.floor(jd - self.gregorian_to_jd(year, 1, 1))) + 1
        return year, day

    def pad(self, Str, howlong, padwith):
        "Pad a string to a given length with a given fill character. "

        s = str(Str)

        while s.length < howlong:
            s = padwith + s
        return s

    def leap_islamic(self, year):
        "Is a given year a leap year in the Islamic calendar ?"

        return (((year * 11) + 14) % 30) < 11

    def leap_jalali(self, year):
        "Is a given year a leap year in the Jalali calendar ?"

        return ((((((year - 474 if year > 0 else 473) % 2820) + 474) + 38) * 682) % 2816) < 682

    def jalali_to_jd(self, year, month, day):
        "Determine Julian day from Jalali date"

        epbase = year - 474 if year >= 0 else 473
        epyear = 474 + (epbase % 2820)

        if month <= 7:
            mm = (month - 1) * 31
        else:
            mm = ((month - 1) * 30) + 6

        return day + mm + math.floor(((epyear * 682) - 110) / 2816) + (epyear - 1) * 365 + \
               math.floor(epbase / 2820) * 1029983 + (JALALI_EPOCH - 1)

    def jd_to_jalali(self, jd):
        "Calculate Jalali date from Julian day"

        jd = math.floor(jd) + 0.5
        depoch = jd - self.jalali_to_jd(475, 1, 1)
        cycle = math.floor(depoch / 1029983)
        cyear = depoch % 1029983
        if cyear == 1029982:
            ycycle = 2820
        else:
            aux1 = math.floor(cyear / 366)
            aux2 = cyear % 366
            ycycle = math.floor(((2134 * aux1) + (2816 * aux2) + 2815) / 1028522) + aux1 + 1

        year = int(ycycle + (2820 * cycle) + 474)
        if year <= 0:
            year -= 1

        yday = (jd - self.jalali_to_jd(year, 1, 1)) + 1
        if yday <= 186:
            month = int(math.ceil(yday / 31))
        else:
            month = int(math.ceil((yday - 6) / 30))

        day = int(jd - self.jalali_to_jd(year, month, 1)) + 1
        return year, month, day


from datetime import datetime, date


def jalali_to_gregorian(dat_str, sep=''):
    """
    Gets date in (char(8)) (or / delimited) (or char(10) / delimited)
    returns Date
    returns None on error
    """
    cal = Calverter()
    try:
        if sep:
            splited = dat_str.split(sep)
            year = splited[0]
            month = splited[1]
            day = splited[2]
        elif len(dat_str) == 8:
            year = dat_str[0:4]
            month = dat_str[4:6]
            day = dat_str[6:8]
        elif len(dat_str) == 10:
            year = dat_str[0:4]
            month = dat_str[5:7]
            day = dat_str[8:10]
        else:
            splited = dat_str.split('/')
            year = splited[0]
            month = splited[1]
            day = splited[2]
        if not year.isdigit():
            return None
        if not month.isdigit():
            return None
        if not day.isdigit():
            return None
        jd = cal.jalali_to_jd(int(year), int(month), int(day))
        dat_tuple = cal.jd_to_gregorian(jd)
        return date(dat_tuple[0], dat_tuple[1], dat_tuple[2])
    except Exception:
        return None


def gregorian_to_jalali(date, sep='/'):
    """
    Gets georgian date
    returns persian date in char(10) (/ separated)
    """
    if date == '' or date is None:
        return ''
    cal = Calverter()
    date_str = str(date)
    year = date_str[0:4]
    month = date_str[5:7]
    day = date_str[8:10]
    jd = cal.gregorian_to_jd(int(year), int(month), int(day))
    dat_tuple = cal.jd_to_jalali(jd)
    format_date = "%s" + sep + "%s" + sep + "%s"
    return format_date % (
        str(dat_tuple[0]).rjust(4, '0'), str(dat_tuple[1]).rjust(2, '0'), str(dat_tuple[2]).rjust(2, '0'))


def gregorian_to_jalaliyear(date, sep='/'):
    """
    Gets georgian date
    returns persian date in char(10) (/ separated)
    """
    if date == '' or date is None:
        return ''
    cal = Calverter()
    date_str = str(date)
    year = date_str[0:4]
    month = date_str[5:7]
    day = date_str[8:10]
    jd = cal.gregorian_to_jd(int(year), int(month), int(day))
    dat_tuple = cal.jd_to_jalali(jd)
    return str(dat_tuple[0]).rjust(4, '0')


def gregorian_to_jalaliyearmonth(date, sep='/'):
    """
    Gets georgian date
    returns persian date in char(10) (/ separated)
    """
    if date == '' or date is None:
        return ''
    cal = Calverter()
    date_str = str(date)
    year = date_str[0:4]
    month = date_str[5:7]
    day = date_str[8:10]
    jd = cal.gregorian_to_jd(int(year), int(month), int(day))
    dat_tuple = cal.jd_to_jalali(jd)
    year = str(dat_tuple[0]).rjust(4, '0')
    month_num = int(str(dat_tuple[1]))
    month = MONTH_NAMES[month_num - 1]
    return month + " " + year


def pdate_day_month(date, sep='/'):
    """
    Gets georgian date
    returns persian date in char(10) (/ separated)
    """
    if date == '' or date is None:
        return ''
    cal = Calverter()
    date_str = str(date)
    year = date_str[0:4]
    month = date_str[5:7]
    day = date_str[8:10]
    jd = cal.gregorian_to_jd(int(year), int(month), int(day))
    dat_tuple = cal.jd_to_jalali(jd)
    format_date = "%s" + sep + "%s"
    return format_date % (
        str(dat_tuple[2]).rjust(2, '0'), str(dat_tuple[1]).rjust(2, '0'))


def gregorian_to_jalaliyearmonthday(date, sep=' '):
    """
    Gets georgian date
    returns persian date in char(10) (/ separated)
    """
    if date == '' or date is None:
        return ''
    cal = Calverter()
    date_str = str(date)
    year = date_str[0:4]
    month = date_str[5:7]
    day = date_str[8:10]
    jd = cal.gregorian_to_jd(int(year), int(month), int(day))
    dat_tuple = cal.jd_to_jalali(jd)
    format_date = "%s" + ' ' + "%s" + sep + " %s"
    month = MONTH_NAMES[int(str(dat_tuple[1]).rjust(2, '0')) - 1]
    return format_date % (
        str(dat_tuple[2]), month, str(dat_tuple[0]).rjust(4, '0'))


def gregorian_to_jalalimonthday(date, sep='، '):
    """
    Gets georgian date
    returns persian date in char(10) (/ separated)
    """
    if date == '' or date is None:
        return ''
    cal = Calverter()
    date_str = str(date)
    year = date_str[0:4]
    month = date_str[5:7]
    day = date_str[8:10]
    jd = cal.gregorian_to_jd(int(year), int(month), int(day))
    dat_tuple = cal.jd_to_jalali(jd)
    format_date = JALALI_WEEKDAYS[date.weekday()] + sep + "%s" + sep + "%s" + sep + "%s"
    month = MONTH_NAMES[int(str(dat_tuple[1]).rjust(2, '0')) - 1]
    return format_date % (
        str(dat_tuple[2]).rjust(2, '0'), month, str(dat_tuple[0]).rjust(4, '0'))


def jalali_by_time(date, sep='/'):
    jdate = gregorian_to_jalali(date, sep)
    return "%s:%s - %s" % (date.hour, date.minute, jdate)


def jalali_today():
    date = datetime.now().date()
    return gregorian_to_jalali(date)


def jalali_time_to_gregorian(datetime_val: str, to_utc_time=True, to_tehran_time=False) -> Optional[datetime]:
    if not datetime_val:
        return None
    datetime_val = persianToEnNumb(datetime_val)
    field_value_arr = datetime_val.split()
    if len(field_value_arr) == 2:
        date_val, time_val = field_value_arr
    else:
        date_val = datetime_val.strip()
        time_val = '00:00:00'
    miladi_date = jalali_to_gregorian(date_val).isoformat()
    miladi_date_time = '%s %s' % (miladi_date, time_val)
    if to_tehran_time:
        unaware_datetime = datetime.strptime(miladi_date_time, '%Y-%m-%d %H:%M:%S')
        tehran_tz = pytz.timezone("Asia/Tehran")
        return tehran_tz.localize(unaware_datetime).astimezone(pytz.utc)
    elif to_utc_time:
        return datetime.strptime(miladi_date_time, '%Y-%m-%d %H:%M:%S').astimezone(pytz.utc)
    else:
        return datetime.strptime(miladi_date_time, '%Y-%m-%d %H:%M:%S')


def jalali_time_to_gregorian_split(datetime_val: str):
    if not datetime_val:
        return None
    datetime_val = persianToEnNumb(datetime_val)
    field_value_arr = datetime_val.split()
    if len(field_value_arr) == 2:
        date_val, time_val = field_value_arr
    else:
        date_val = datetime_val.strip()
        time_val = '00:00:00'
    miladi_date = jalali_to_gregorian(date_val)
    return miladi_date, time_val


def gregorian_to_jalali_time(val, apply_timezone=True):
    if not val:
        return ''
    if isinstance(val, datetime) and apply_timezone:
        val = val.astimezone(pytz.timezone("Asia/Tehran"))
    date_part = gregorian_to_jalali(val)
    time_part = val.strftime('%H:%M:%S')
    return '%s %s' % (date_part, time_part)
