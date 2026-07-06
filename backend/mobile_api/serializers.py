"""
Mobile API Serializers
Optimized for Flutter/mobile consumption - flat structures, no nested pagination overhead.
"""

from rest_framework import serializers
from accounts.models import User
from farms.models import Farm, Plot, SoilRecord, IrrigationSchedule, CropField, FarmData
from news.models import News, Category, Comment
from ai_core.models import AICoreResult


# ─── Auth ────────────────────────────────────────────────────────────────────

class MobileUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'username', 'phone_number', 'full_name', 'role', 'location', 'date_joined')
        read_only_fields = ('id', 'date_joined')

    def validate_email(self, value):
        user = self.instance
        qs = User.objects.filter(email=value)
        if user:
            qs = qs.exclude(pk=user.pk)
        if qs.exists():
            raise serializers.ValidationError("Email already in use.")
        return value


class MobileRegisterSerializer(serializers.Serializer):
    email = serializers.EmailField()
    username = serializers.CharField(max_length=150)
    password = serializers.CharField(write_only=True, min_length=8)
    phone_number = serializers.CharField(max_length=20, required=False, allow_blank=True)
    full_name = serializers.CharField(max_length=150, required=False, allow_blank=True, default='')
    role = serializers.ChoiceField(
        choices=[('Farmer', 'Farmer'), ('Expert', 'Agricultural Expert'), ('Student', 'Student')],
        required=False,
        default='Farmer'
    )
    location = serializers.CharField(max_length=255, required=False, allow_blank=True, default='')

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already in use.")
        return value

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("Username already taken.")
        return value

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class MobileLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class MobileChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_old_password(self, value):
        if not self.context['request'].user.check_password(value):
            raise serializers.ValidationError("Old password is incorrect.")
        return value

    def save(self, **kwargs):
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password'])
        user.save()
        return user


# ─── Farms ───────────────────────────────────────────────────────────────────

class MobileSoilRecordSerializer(serializers.ModelSerializer):
    id = serializers.CharField(read_only=True)

    class Meta:
        model = SoilRecord
        fields = ('id', 'plot', 'nitrogen', 'phosphorus', 'potassium', 'ph', 'moisture', 'created_at')
        read_only_fields = ('id', 'created_at')


class MobileIrrigationSerializer(serializers.ModelSerializer):
    id = serializers.CharField(read_only=True)

    class Meta:
        model = IrrigationSchedule
        fields = ('id', 'plot', 'scheduled_time', 'duration_minutes', 'water_volume', 'status')
        read_only_fields = ('id',)


class MobilePlotSerializer(serializers.ModelSerializer):
    id = serializers.CharField(read_only=True)
    soil_records_count = serializers.SerializerMethodField()
    next_irrigation = serializers.SerializerMethodField()

    class Meta:
        model = Plot
        fields = (
            'id', 'farm', 'name', 'crop_type', 'area', 'moisture',
            'harvest_date', 'status', 'latitude', 'longitude',
            'soil_records_count', 'next_irrigation',
        )
        read_only_fields = ('id',)

    def get_soil_records_count(self, obj):
        return obj.soil_records.count()

    def get_next_irrigation(self, obj):
        irr = obj.irrigations.filter(status='scheduled').order_by('scheduled_time').first()
        if irr:
            return {
                'id': irr.id,
                'scheduled_time': irr.scheduled_time,
                'duration_minutes': irr.duration_minutes,
            }
        return None


class MobileFarmSerializer(serializers.ModelSerializer):
    id = serializers.CharField(read_only=True)
    plots_count = serializers.SerializerMethodField()
    crop_fields_count = serializers.SerializerMethodField()

    # Map to camelCase/aliases for mobile client compatibility
    lat = serializers.DecimalField(source='latitude', max_digits=9, decimal_places=6, required=False, allow_null=True)
    lng = serializers.DecimalField(source='longitude', max_digits=9, decimal_places=6, required=False, allow_null=True)
    lastScan = serializers.CharField(source='last_scan', required=False, allow_blank=True, default="")
    plantedAt = serializers.DateTimeField(source='planted_at', required=False, allow_null=True)

    class Meta:
        model = Farm
        fields = (
            'id', 'name', 'location', 'soil_type', 'climate_zone',
            'lat', 'lng', 'crop', 'area', 'health', 'lastScan', 'plantedAt',
            'nitrogen', 'phosphorus', 'potassium', 'ph', 'temperature', 'humidity', 'soil_moisture',
            'created_at', 'plots_count', 'crop_fields_count',
        )
        read_only_fields = ('id', 'created_at')

    def get_plots_count(self, obj):
        return obj.plots.count()

    def get_crop_fields_count(self, obj):
        return obj.crop_fields.count()


class MobileFarmDetailSerializer(MobileFarmSerializer):
    """Full farm detail with nested plots."""
    plots = MobilePlotSerializer(many=True, read_only=True)

    class Meta(MobileFarmSerializer.Meta):
        fields = MobileFarmSerializer.Meta.fields + ('plots',)


class MobileCropFieldSerializer(serializers.ModelSerializer):
    id = serializers.CharField(read_only=True)
    farm_name = serializers.CharField(source='farm.name', read_only=True, allow_null=True)

    class Meta:
        model = CropField
        fields = (
            'id', 'farm', 'farm_name', 'crop_type', 'color',
            'latitude', 'longitude', 'area', 'soil_type',
            'ndvi', 'soil_moisture', 'temperature', 'humidity',
            'created_at', 'updated_at',
        )
        read_only_fields = ('id', 'created_at', 'updated_at', 'farm_name')


class MobileFarmDataSerializer(serializers.ModelSerializer):
    id = serializers.CharField(read_only=True)

    class Meta:
        model = FarmData
        fields = ('id', 'farm', 'temperature', 'humidity', 'nitrogen',
                  'phosphorus', 'potassium', 'soil_ph', 'created_at')
        read_only_fields = ('id', 'created_at')


# ─── Dashboard ───────────────────────────────────────────────────────────────

class MobileDashboardSerializer(serializers.Serializer):
    """Flat dashboard snapshot for mobile home screen."""
    farms_count = serializers.IntegerField()
    plots_count = serializers.IntegerField()
    crop_fields_count = serializers.IntegerField()
    alerts_count = serializers.IntegerField()
    latest_irrigation = serializers.DictField(allow_null=True)
    latest_soil = serializers.DictField(allow_null=True)
    recent_ai_results = serializers.ListField()


# ─── News ────────────────────────────────────────────────────────────────────

class MobileCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name')


class MobileNewsListSerializer(serializers.ModelSerializer):
    """Lightweight news list - no content body to save bandwidth."""
    category_name = serializers.CharField(source='category.name', read_only=True)
    author_name = serializers.CharField(source='author.username', read_only=True)

    class Meta:
        model = News
        fields = ('id', 'title', 'category_name', 'author_name', 'image_url', 'created_at')


class MobileNewsDetailSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    author_name = serializers.CharField(source='author.username', read_only=True)
    comments_count = serializers.SerializerMethodField()

    class Meta:
        model = News
        fields = (
            'id', 'title', 'content', 'category_name', 'author_name',
            'image_url', 'created_at', 'comments_count',
        )

    def get_comments_count(self, obj):
        return obj.comments.filter(is_approved=True).count()


class MobileCommentSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = Comment
        fields = ('id', 'user_name', 'text', 'created_at')
        read_only_fields = ('id', 'created_at', 'user_name')


# ─── AI Results History ───────────────────────────────────────────────────────

class MobileAIResultSerializer(serializers.ModelSerializer):
    model_type_display = serializers.CharField(source='get_model_type_display', read_only=True)

    class Meta:
        model = AICoreResult
        fields = ('id', 'model_type', 'model_type_display', 'result_data',
                  'execution_time', 'created_at')
        read_only_fields = fields
