# Generated by Django 3.1.6 on 2021-02-13 18:11

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resume', '0009_experience_location'),
    ]

    operations = [
        migrations.CreateModel(
            name='Projects',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('language', models.IntegerField(choices=[(1, 'English'), (2, 'Farsi')])),
                ('project_name', models.CharField(max_length=100)),
                ('subtitle', models.CharField(max_length=100)),
                ('company_website', models.URLField(blank=True, null=True)),
                ('start_date', models.DateField(blank=True, null=True)),
                ('end_date', models.DateField(blank=True, null=True)),
                ('description', models.TextField(blank=True, null=True)),
            ],
            options={
                'abstract': False,
            },
        ),
    ]
