import json
import tempfile
from unittest.mock import patch
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import User
from farms.models import Farm, Plot, SoilRecord, IrrigationSchedule, CropField, FarmData
from news.models import Category, News, Comment
from ai_core.models import AICoreResult


class MobileApiTests(APITestCase):

    def setUp(self):
        # 1. Create a test user
        self.user_password = "strongpassword123"
        self.user = User.objects.create_user(
            email="farmer@example.com",
            username="farmerbob",
            password=self.user_password,
            phone_number="0123456789"
        )
        
        # 2. Get JWT tokens for authentication
        response = self.client.post(
            reverse("mobile_api:login"),
            {"email": self.user.email, "password": self.user_password},
            format="json"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.access_token = response.data["access"]
        self.refresh_token = response.data["refresh"]
        self.auth_headers = {"HTTP_AUTHORIZATION": f"Bearer {self.access_token}"}

        # 3. Create initial test records
        self.farm = Farm.objects.create(
            user=self.user,
            name="Bob's Organic Farm",
            location="Giza, Egypt",
            soil_type="Clay",
            climate_zone="Arid",
            latitude=30.0130,
            longitude=31.2088
        )

        self.plot = Plot.objects.create(
            farm=self.farm,
            name="North Sector",
            crop_type="wheat",
            area=2.5,
            moisture=45.0,
            harvest_date="2026-09-15",
            status="healthy",
            latitude=30.0131,
            longitude=31.2089
        )

        self.soil_record = SoilRecord.objects.create(
            plot=self.plot,
            nitrogen=60.0,
            phosphorus=35.0,
            potassium=40.0,
            ph=6.8,
            moisture=42.0
        )

        self.irrigation = IrrigationSchedule.objects.create(
            plot=self.plot,
            scheduled_time="2026-06-15T08:00:00Z",
            duration_minutes=30,
            water_volume=120.0,
            status="scheduled"
        )

        self.crop_field = CropField.objects.create(
            farm=self.farm,
            crop_type="wheat",
            color="#00AA00",
            latitude=30.0132,
            longitude=31.2090,
            area=1.5,
            soil_type="loamy",
            ndvi=0.65,
            soil_moisture=38.0,
            temperature=28.0,
            humidity=55.0
        )

        self.farm_data = FarmData.objects.create(
            farm=self.farm,
            temperature=31.5,
            humidity=40.2,
            nitrogen=58.0,
            phosphorus=32.0,
            potassium=39.0,
            soil_ph=6.7
        )

        self.category = Category.objects.create(name="Agriculture Tech")
        self.news = News.objects.create(
            category=self.category,
            author=self.user,
            title="AI Revolution in Farming",
            content="Details about the AI revolution in modern agriculture.",
            is_published=True
        )

        self.comment = Comment.objects.create(
            news=self.news,
            user=self.user,
            text="Very insightful article!",
            is_approved=True
        )

    # ═══════════════════════════════════════════════════════════════════════════════
    # 1. HEALTH CHECK
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_health_check(self):
        url = reverse("mobile_api:health")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], "ok")
        self.assertEqual(response.data["service"], "farmtech-mobile-api")

    # ═══════════════════════════════════════════════════════════════════════════════
    # 2. AUTHENTICATION
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_auth_register(self):
        url = reverse("mobile_api:register")
        payload = {
            "email": "newfarmer@example.com",
            "username": "newfarmer",
            "password": "supersecurepassword123",
            "phone_number": "0987654321"
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
        self.assertEqual(response.data["user"]["email"], payload["email"])

    def test_auth_login_success(self):
        url = reverse("mobile_api:login")
        payload = {
            "email": self.user.email,
            "password": self.user_password
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)

    def test_auth_login_invalid(self):
        url = reverse("mobile_api:login")
        payload = {
            "email": self.user.email,
            "password": "wrongpassword"
        }
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertFalse(response.data["success"])

    def test_auth_logout(self):
        url = reverse("mobile_api:logout")
        payload = {"refresh": self.refresh_token}
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])

    def test_auth_profile_get_and_put(self):
        url = reverse("mobile_api:profile")
        
        # GET profile
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["email"], self.user.email)

        # PUT profile update
        update_payload = {"phone_number": "0111111111", "username": "farmerbobupdated"}
        response = self.client.put(url, update_payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["username"], "farmerbobupdated")
        self.assertEqual(response.data["data"]["phone_number"], "0111111111")

    def test_auth_change_password(self):
        url = reverse("mobile_api:change-password")
        payload = {
            "old_password": self.user_password,
            "new_password": "brandnewpassword987"
        }
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["message"], "Password changed. Please login again.")

    def test_auth_token_refresh(self):
        url = reverse("mobile_api:token-refresh")
        payload = {"refresh": self.refresh_token}
        response = self.client.post(url, payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)

    # ═══════════════════════════════════════════════════════════════════════════════
    # 3. DASHBOARD
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_dashboard_endpoint(self):
        url = reverse("mobile_api:dashboard")
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        data = response.data["data"]
        self.assertEqual(data["farms_count"], 1)
        self.assertEqual(data["plots_count"], 1)
        self.assertEqual(data["crop_fields_count"], 1)
        self.assertEqual(data["latest_soil"]["ph"], 6.8)
        self.assertEqual(data["latest_irrigation"]["status"], "scheduled")

    # ═══════════════════════════════════════════════════════════════════════════════
    # 4. FARMS
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_farm_list_and_create(self):
        url = reverse("mobile_api:farm-list")
        
        # GET List
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)

        # POST Create
        payload = {
            "name": "East Valley Farm",
            "location": "Luxor, Egypt",
            "soil_type": "Sandy",
            "climate_zone": "Hyper-arid",
            "lat": 25.6872,
            "lng": 32.6396
        }
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["name"], payload["name"])

    def test_farm_detail_update_delete(self):
        detail_url = reverse("mobile_api:farm-detail", kwargs={"pk": self.farm.id})
        
        # GET Detail
        response = self.client.get(detail_url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["name"], self.farm.name)
        self.assertEqual(len(response.data["data"]["plots"]), 1)

        # PUT Update
        update_payload = {"name": "Bob's Mega Farm"}
        response = self.client.put(detail_url, update_payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["name"], "Bob's Mega Farm")

        # DELETE Farm
        response = self.client.delete(detail_url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Farm.objects.filter(id=self.farm.id).exists())

    # ═══════════════════════════════════════════════════════════════════════════════
    # 5. PLOTS
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_plot_list_and_create(self):
        url = reverse("mobile_api:plot-list", kwargs={"farm_id": self.farm.id})
        
        # GET List
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)

        # POST Create
        payload = {
            "name": "South Sector",
            "crop_type": "corn",
            "area": 1.8,
            "moisture": 30.5,
            "harvest_date": "2026-10-01",
            "status": "healthy",
            "latitude": 30.0135,
            "longitude": 31.2095
        }
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["name"], payload["name"])

    def test_plot_detail_update_delete(self):
        detail_url = reverse("mobile_api:plot-detail", kwargs={"pk": self.plot.id})
        
        # GET Detail
        response = self.client.get(detail_url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["name"], self.plot.name)

        # PUT Update
        update_payload = {"name": "North Sector A"}
        response = self.client.put(detail_url, update_payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["name"], "North Sector A")

        # DELETE Plot
        response = self.client.delete(detail_url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Plot.objects.filter(id=self.plot.id).exists())

    # ═══════════════════════════════════════════════════════════════════════════════
    # 6. SOIL RECORDS
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_soil_record_list_and_create(self):
        url = reverse("mobile_api:soil-list", kwargs={"plot_id": self.plot.id})
        
        # GET List
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)

        # POST Create
        payload = {
            "nitrogen": 62.0,
            "phosphorus": 36.0,
            "potassium": 41.0,
            "ph": 6.9,
            "moisture": 43.0
        }
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["ph"], payload["ph"])

    # ═══════════════════════════════════════════════════════════════════════════════
    # 7. IRRIGATION
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_irrigation_list_and_create(self):
        url = reverse("mobile_api:irrigation-list", kwargs={"plot_id": self.plot.id})
        
        # GET List
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)

        # POST Create
        payload = {
            "scheduled_time": "2026-06-16T09:00:00Z",
            "duration_minutes": 45,
            "water_volume": 150.0,
            "status": "scheduled"
        }
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["duration_minutes"], payload["duration_minutes"])

    def test_irrigation_detail_update_delete(self):
        detail_url = reverse("mobile_api:irrigation-detail", kwargs={"pk": self.irrigation.id})
        
        # PUT Update
        update_payload = {"status": "in_progress"}
        response = self.client.put(detail_url, update_payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["status"], "in_progress")

        # DELETE Irrigation
        response = self.client.delete(detail_url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(IrrigationSchedule.objects.filter(id=self.irrigation.id).exists())

    # ═══════════════════════════════════════════════════════════════════════════════
    # 8. CROP FIELDS
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_crop_field_list_and_create(self):
        url = reverse("mobile_api:cropfield-list")
        
        # GET List
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)

        # POST Create
        payload = {
            "farm": self.farm.id,
            "crop_type": "corn",
            "color": "#FFAA00",
            "latitude": 30.0140,
            "longitude": 31.2100,
            "area": 2.0,
            "soil_type": "sandy",
            "ndvi": 0.71,
            "soil_moisture": 40.0,
            "temperature": 29.5,
            "humidity": 50.0
        }
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["crop_type"], payload["crop_type"])

    def test_crop_field_detail_update_delete(self):
        detail_url = reverse("mobile_api:cropfield-detail", kwargs={"pk": self.crop_field.id})
        
        # GET Detail
        response = self.client.get(detail_url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["crop_type"], self.crop_field.crop_type)

        # PUT Update
        update_payload = {"color": "#FFAAFF"}
        response = self.client.put(detail_url, update_payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["color"], "#FFAAFF")

        # DELETE CropField
        response = self.client.delete(detail_url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(CropField.objects.filter(id=self.crop_field.id).exists())

    # ═══════════════════════════════════════════════════════════════════════════════
    # 9. FARM SENSOR DATA
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_farm_data_list_and_create(self):
        url = reverse("mobile_api:farm-sensor-data", kwargs={"farm_id": self.farm.id})
        
        # GET List
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)

        # POST Create
        payload = {
            "temperature": 32.0,
            "humidity": 41.0,
            "nitrogen": 59.0,
            "phosphorus": 33.0,
            "potassium": 40.0,
            "soil_ph": 6.8
        }
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["temperature"], payload["temperature"])

    # ═══════════════════════════════════════════════════════════════════════════════
    # 10. NEWS AND COMMENTS
    # ═══════════════════════════════════════════════════════════════════════════════
    def test_news_list(self):
        url = reverse("mobile_api:news-list")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["total"], 1)

    def test_news_categories(self):
        url = reverse("mobile_api:news-categories")
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"][0]["name"], self.category.name)

    def test_news_detail(self):
        url = reverse("mobile_api:news-detail", kwargs={"pk": self.news.id})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["title"], self.news.title)

    def test_news_comments_get_and_post(self):
        url = reverse("mobile_api:news-comments", kwargs={"news_id": self.news.id})
        
        # GET Comments
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)

        # POST Comment
        payload = {"text": "Awesome read, thanks!"}
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["message"], "Comment submitted and awaiting approval.")

    # ═══════════════════════════════════════════════════════════════════════════════
    # 11. AI ENDPOINTS (MOCKED REQUESTS)
    # ═══════════════════════════════════════════════════════════════════════════════
    @patch("mobile_api.views.cv_model.predict_image")
    def test_ai_plant_disease_cv(self, mock_predict):
        url = reverse("mobile_api:ai-plant-disease")
        
        # Mock local CV model loader prediction
        mock_predict.return_value = {
            "prediction": "Apple Scab",
            "confidence": 92.4,
            "class_id": 2
        }

        # Create a dummy image file
        with tempfile.NamedTemporaryFile(suffix=".jpg") as tmp_img:
            tmp_img.write(b"fake image bytes")
            tmp_img.seek(0)
            
            response = self.client.post(
                url,
                {"image": tmp_img},
                format="multipart",
                **self.auth_headers
            )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["prediction"], "Apple Scab")
        self.assertEqual(response.data["data"]["confidence"], 92.4)

    @patch("requests.post")
    def test_ai_crop_recommendation(self, mock_post):
        url = reverse("mobile_api:ai-crop-rec")
        
        # Mock API response
        mock_post.return_value.status_code = 200
        mock_post.return_value.json.return_value = {
            "recommended_crop": "rice",
            "confidence": 0.85,
            "all_scores": {"rice": 0.85, "wheat": 0.15}
        }

        payload = {
            "data": {
                "N": 80,
                "P": 40,
                "K": 40,
                "temperature": 26.5,
                "humidity": 80.2,
                "ph": 6.5,
                "rainfall": 200.0
            },
            "save": True
        }
        
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["result"]["recommended_crop"], "rice")
        self.assertTrue(AICoreResult.objects.filter(user=self.user, model_type="crop_recommendation").exists())

    @patch("requests.post")
    def test_ai_irrigation_recommendation(self, mock_post):
        url = reverse("mobile_api:ai-irrigation")
        
        # Mock API response
        mock_post.return_value.status_code = 200
        mock_post.return_value.json.return_value = {
            "irrigation_need_mm": 12.5,
            "irrigation_class": "🔴 High"
        }

        payload = {
            "data": {
                "temperature": 32.0,
                "humidity": 45.0,
                "moisture": 25.0,
                "soil_type": "Loamy",
                "crop_type": "wheat"
            },
            "save": True
        }
        
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["result"]["irrigation_class"], "🔴 High")
        self.assertTrue(AICoreResult.objects.filter(user=self.user, model_type="irrigation_optimizer").exists())

    @patch("requests.post")
    def test_ai_yield_prediction(self, mock_post):
        url = reverse("mobile_api:ai-yield")
        
        # Mock API response
        mock_post.return_value.status_code = 200
        mock_post.return_value.json.return_value = {
            "status": "success",
            "crop": "wheat",
            "yield": 7.15,
            "unit": "Tonnes/Feddan"
        }

        payload = {
            "data": {
                "lat": 30.0130,
                "lon": 31.2088,
                "year": 2026,
                "crop": "wheat"
            },
            "save": True
        }
        
        response = self.client.post(url, payload, format="json", **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["result"]["yield"], 7.15)
        self.assertTrue(AICoreResult.objects.filter(user=self.user, model_type="yield_prediction").exists())

    @patch("requests.get")
    def test_ai_commodity_price_forecast(self, mock_get):
        # 1. Test Listing Commodities
        url = reverse("mobile_api:ai-forecast")
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = ["Wheat", "Corn", "Rice"]
        
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertIn("Wheat", response.data["data"]["commodities"])

        # 2. Test Forecasting Single Commodity
        mock_get.return_value.json.return_value = [
            {"commodity": "Wheat", "year": 2026, "quarter": 3, "price": 2593.67}
        ]
        response = self.client.get(url, {"commodity": "Wheat"}, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(response.data["data"]["forecast"][0]["price"], 2593.67)

    def test_ai_results_history(self):
        # Save a mock result to history first
        AICoreResult.objects.create(
            user=self.user,
            model_type="crop_recommendation",
            input_data={"ph": 6.5},
            result_data={"recommended_crop": "wheat"},
            execution_time=0.123
        )
        
        url = reverse("mobile_api:ai-history")
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["success"])
        self.assertEqual(len(response.data["data"]), 1)
        self.assertEqual(response.data["data"][0]["model_type"], "crop_recommendation")
