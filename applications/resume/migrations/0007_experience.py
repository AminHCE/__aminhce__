# Generated by Django 3.1.6 on 2021-02-12 21:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('resume', '0006_education'),
    ]

    operations = [
        migrations.CreateModel(
            name='Experience',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('language', models.IntegerField(choices=[(1, 'English'), (2, 'Farsi')])),
                ('company_name', models.CharField(max_length=100)),
                ('company_website', models.URLField(blank=True, null=True)),
                ('project_name', models.CharField(max_length=100)),
                ('start_date', models.DateField(blank=True, null=True)),
                ('end_date', models.DateField(blank=True, null=True)),
                ('description', models.TextField(blank=True, null=True)),
            ],
            options={
                'abstract': False,
            },
        ),
    ]
