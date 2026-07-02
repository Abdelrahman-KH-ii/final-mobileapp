from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from accounts.models import User


class AccountsApiTests(APITestCase):
    def setUp(self):
        self.register_url = reverse("register")
        self.login_url = reverse("login")
        self.profile_url = reverse("profile")

    def test_register_new_user_returns_201_and_tokens(self):
        payload = {
            "email": "testuser@example.com",
            "username": "testuser",
            "password": "strongpass123",
            "phone_number": "0123456789",
        }
        response = self.client.post(self.register_url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
        self.assertTrue(User.objects.filter(email=payload["email"]).exists())

    def test_register_duplicate_email_returns_400(self):
        User.objects.create_user(
            email="duplicate@example.com",
            username="duplicate_user",
            password="strongpass123",
        )
        payload = {
            "email": "duplicate@example.com",
            "username": "anotheruser",
            "password": "strongpass123",
        }
        response = self.client.post(self.register_url, payload, format="json")

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data.get("error"), "Email already exists")

    def test_login_with_valid_credentials_returns_tokens(self):
        password = "strongpass123"
        user = User.objects.create_user(
            email="login@example.com",
            username="loginuser",
            password=password,
        )

        response = self.client.post(
            self.login_url,
            {"email": user.email, "password": password},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)

    def test_login_with_invalid_credentials_returns_401(self):
        response = self.client.post(
            self.login_url,
            {"email": "bad@example.com", "password": "wrongpass"},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data.get("error"), "Invalid credentials")

    def test_profile_requires_authentication(self):
        response = self.client.get(self.profile_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class AccountsModelTests(APITestCase):
    def test_create_user_requires_email(self):
        with self.assertRaisesMessage(ValueError, "Email is required"):
            User.objects.create_user(email="", username="user", password="pass")

    def test_create_user_requires_username(self):
        with self.assertRaisesMessage(ValueError, "Username is required"):
            User.objects.create_user(email="user@example.com", username="", password="pass")
