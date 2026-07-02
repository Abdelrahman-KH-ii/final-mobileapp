from rest_framework.views import APIView
from rest_framework.permissions import (
    IsAuthenticated,
    IsAdminUser,
    AllowAny,
)
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404

from .models import Category, News, Comment
from .serializers import (
    CategorySerializer,
    NewsSerializer,
    CommentSerializer,
)


# ======================
# Categories
# ======================

class CategoryListCreateView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        categories = Category.objects.all()
        serializer = CategorySerializer(categories, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = CategorySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)


# ======================
# News
# ======================

class NewsListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        news = News.objects.filter(is_published=True)
        serializer = NewsSerializer(news, many=True)
        return Response(serializer.data)


class NewsDetailView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, pk):
        news = get_object_or_404(News, pk=pk, is_published=True)
        serializer = NewsSerializer(news)
        return Response(serializer.data)


class NewsCreateView(APIView):
    permission_classes = [IsAdminUser]

    def post(self, request):
        serializer = NewsSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(author=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class NewsUpdateDeleteView(APIView):
    permission_classes = [IsAdminUser]

    def put(self, request, pk):
        news = get_object_or_404(News, pk=pk)
        serializer = NewsSerializer(news, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    def delete(self, request, pk):
        news = get_object_or_404(News, pk=pk)
        news.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ======================
# Comments
# ======================

class CommentListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, news_id):
        comments = Comment.objects.filter(
            news_id=news_id,
            is_approved=True
        )
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data)

    def post(self, request, news_id):
        serializer = CommentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(
            user=request.user,
            news_id=news_id
        )
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class CommentApproveView(APIView):
    permission_classes = [IsAdminUser]

    def put(self, request, pk):
        comment = get_object_or_404(Comment, pk=pk)
        comment.is_approved = True
        comment.save()
        return Response({"message": "Comment approved"})