from django.urls import path
from .views import (
    CategoryListCreateView,
    NewsListView,
    NewsDetailView,
    NewsCreateView,
    NewsUpdateDeleteView,
    CommentListCreateView,
    CommentApproveView,
)

urlpatterns = [
    path("categories/", CategoryListCreateView.as_view()),
    path("news/", NewsListView.as_view()),
    path("news/new/", NewsCreateView.as_view()),
    path("news/<int:pk>/", NewsDetailView.as_view()),
    path("news/<int:pk>/edit/", NewsUpdateDeleteView.as_view()),
    path("news/<int:news_id>/comments/", CommentListCreateView.as_view()),
    path("comments/<int:pk>/approve/", CommentApproveView.as_view()),
]
