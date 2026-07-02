"""
Django Admin configuration for AI Core models
"""

from django.contrib import admin
from .models import AICoreResult


@admin.register(AICoreResult)
class AICoreResultAdmin(admin.ModelAdmin):
    """
    Admin interface for AICoreResult model.
    
    Provides filtering, search, and display options for AI model results.
    """
    list_display = (
        "id",
        "model_type",
        "user",
        "farm",
        "execution_time",
        "created_at",
    )
    list_filter = (
        "model_type",
        "created_at",
    )
    search_fields = (
        "user__email",
        "user__first_name",
        "user__last_name",
        "farm__name"
    )
    readonly_fields = (
        "execution_time",
        "created_at",
        "input_data",
        "result_data"
    )
    fieldsets = (
        ("User & Farm", {
            "fields": ("user", "farm")
        }),
        ("Model Information", {
            "fields": ("model_type",)
        }),
        ("Data", {
            "fields": ("input_data", "result_data"),
            "classes": ("collapse",)
        }),
        ("Metadata", {
            "fields": ("execution_time", "created_at"),
            "classes": ("collapse",)
        }),
    )
    ordering = ("-created_at",)