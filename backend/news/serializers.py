from rest_framework import serializers
from .models import Category, News, Comment


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = "__all__"


class NewsSerializer(serializers.ModelSerializer):
    author = serializers.ReadOnlyField(source="author.email")

    class Meta:
        model = News
        fields = "__all__"
        read_only_fields = ("author", "created_at", "updated_at")


class CommentSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source="user.email")

    class Meta:
        model = Comment
        fields = "__all__"
        read_only_fields = ("user", "is_approved", "created_at")