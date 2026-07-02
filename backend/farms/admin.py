from django.contrib import admin
from .models import Farm, FarmData


@admin.register(Farm)
class FarmAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "user", "soil_type", "climate_zone", "created_at")
    list_filter = ("soil_type", "climate_zone")
    search_fields = ("name", "user__email")


@admin.register(FarmData)
class FarmDataAdmin(admin.ModelAdmin):
    list_display = ("id", "farm", "temperature", "humidity", "created_at")
    list_filter = ("created_at",)
    search_fields = ("farm__name",)