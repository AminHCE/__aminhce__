# Generated by Django 3.1.6 on 2021-02-15 09:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resume', '0018_project_location'),
    ]

    operations = [
        migrations.AddField(
            model_name='education',
            name='current',
            field=models.BooleanField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='experience',
            name='current',
            field=models.BooleanField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='project',
            name='current',
            field=models.BooleanField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='education',
            name='begin_time',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='education',
            name='end_time',
            field=models.DateField(blank=True, null=True),
        ),
    ]
