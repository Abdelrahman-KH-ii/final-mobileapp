# Generated manually

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0002_remove_user_is_admin_alter_user_email'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='full_name',
            field=models.CharField(blank=True, default='', max_length=150),
        ),
        migrations.AddField(
            model_name='user',
            name='role',
            field=models.CharField(
                choices=[('Farmer', 'Farmer'), ('Expert', 'Agricultural Expert'), ('Student', 'Student')],
                default='Farmer',
                max_length=50
            ),
        ),
        migrations.AddField(
            model_name='user',
            name='location',
            field=models.CharField(blank=True, default='', max_length=255),
        ),
    ]
