from django.contrib import admin
from .models import Category, News, Comment


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("id", "name")
    search_fields = ("name",)


@admin.register(News)
class NewsAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "category", "author", "is_published", "created_at")
    list_filter = ("is_published", "category")
    search_fields = ("title",)
    autocomplete_fields = ("category", "author")


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ("id", "news", "user", "is_approved", "created_at")
    list_filter = ("is_approved",)
    search_fields = ("news__title", "user__email")