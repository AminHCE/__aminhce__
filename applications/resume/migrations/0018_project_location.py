# Generated by Django 3.1.6 on 2021-02-15 07:52

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resume', '0017_auto_20210214_0716'),
    ]

    operations = [
        migrations.AddField(
            model_name='project',
            name='location',
            field=models.CharField(blank=True, max_length=100, null=True),
        ),
    ]
