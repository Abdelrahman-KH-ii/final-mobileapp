"""
Django app configuration for AI Core

Configures the AI Core application for Django project.
"""

from django.apps import AppConfig


class AiCoreConfig(AppConfig):
    """
    Configuration class for the AI Core app.
    
    Handles model registration and app initialization for the AI Core module
    which manages all AI model predictions and results.
    """
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ai_core'
    verbose_name = 'AI Core'