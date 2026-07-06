---
title: FarmTech Backend API
emoji: 🌾
colorFrom: green
colorTo: blue
sdk: docker
pinned: false
license: mit
app_port: 7860
---

# FarmTech Backend API

Django REST Framework backend for the FarmTech mobile app.

## Endpoints

- `GET /api/mobile/health/` — Health check
- `POST /api/mobile/auth/register/` — Register user
- `POST /api/mobile/auth/login/` — Login
- `GET/POST /api/mobile/farms/` — List / create farms
- `GET/PUT/DELETE /api/mobile/farms/<id>/` — Farm detail
- `GET /api/mobile/dashboard/` — Dashboard data

## API Docs

Visit `/swagger/` for interactive Swagger documentation.
