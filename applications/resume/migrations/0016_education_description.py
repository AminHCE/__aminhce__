# Generated by Django 3.1.6 on 2021-02-13 21:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resume', '0015_auto_20210213_2054'),
    ]

    operations = [
        migrations.AddField(
            model_name='education',
            name='description',
            field=models.TextField(blank=True, null=True),
        ),
    ]
