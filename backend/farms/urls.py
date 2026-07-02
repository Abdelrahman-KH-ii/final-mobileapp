from rest_framework.routers import DefaultRouter
from django.urls import path
from .views import FarmViewSet, DashboardView, CropFieldViewSet

router = DefaultRouter()
router.register(r"farms", FarmViewSet, basename="farms")
router.register(r"fields", CropFieldViewSet, basename="crop-fields")

urlpatterns = router.urls + [
    path("dashboard/", DashboardView.as_view(), name="dashboard"),
]