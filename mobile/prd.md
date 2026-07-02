# Product Requirements Document (PRD)

## 1. Product Overview
**Product Name:** FarmTec
**Tagline:** Precision Intelligence for the Modern Farm
**Platform:** Mobile Application (Flutter - Android/iOS/Web)
**Version:** 2.2.0
**Status:** In Development (v2.2 Feature Update)

FarmTec is a comprehensive, AI-powered mobile application designed to assist modern farmers and agricultural enthusiasts. The app provides precision intelligence through features like farm management, soil analysis, market monitoring, and state-of-the-art AI-driven agricultural and medical assistants. It also features robust multi-lingual support, primarily targeting English and Arabic speakers, with a focus on making complex agricultural data understandable for both novice and expert users.

## 2. Target Audience
- Modern farmers and farm owners seeking digital management tools.
- Agricultural professionals looking for AI-powered diagnostics (e.g., plant diseases, soil health).
- Users needing immediate, accurate information regarding agricultural practices and relevant medications.
- Arabic and English-speaking agricultural communities (with full RTL support).
- **New in v2.0:** Non-expert users who need simplified terminology and tooltips for technical agricultural terms.

## 3. Key Features

### 3.1. Core Application Shell & Navigation
- **Splash Screen & Onboarding:** *(v2.0 Redesigned)* Unique animated splash screen with growing plant animation, pulsing glow effects, and staggered text fade-in. Uses local storage (`shared_preferences`) to determine if a user is new or returning. New users are guided through an onboarding flow before reaching authentication.
- **Multilingual Support:** *(v2.0 Enhanced)* Seamless, dynamic localization switching between English and Arabic across all features with farmer-friendly Arabic translations and terminology tooltips. Full RTL layout support.
- **App Shell:** A unified navigation structure linking the primary features with smooth page transitions and animated tab switching.
- **Dark Mode:** *(v2.0 New)* Full dark theme support with forest-inspired dark palette. User preference persisted across sessions.

### 3.2. Authentication & User Flow
- **Login Screen:** *(v2.0 Improved)* Full-screen responsive layout that fits all device sizes. Email + password authentication with social login (Google, Apple).
- **Signup Screen:** *(v2.0 Enhanced)* Additional registration fields:
  - Full Name
  - Email Address
  - Password
  - Phone Number (with country code)
  - Farm Name (optional)
  - Location / Region
  - User Role (Farmer / Expert / Student)
- **Farm Selection Screen:** *(v2.1 Enhanced)* Post-login intermediate screen:
  - Shows existing farms for selection if user has farms
  - Prompts "Add Your First Farm" if no farms exist
  - Selected farm becomes active context for dashboard and all features
  - Farm preference stored in SharedPreferences
  - **Interactive satellite map preview** in Add Farm sheet with tap-to-set-location and live GPS coordinate filling

### 3.3. Farm Management & Monitoring
- **Dashboard:** *(v2.2 Enhanced)* Single, unified dashboard screen connected to the selected farm. Provides at-a-glance overview of farm metrics, activities, and alerts. **Live weather data from Open-Meteo API** with current conditions and 5-day forecast. **Smart Nudges** to remind users of pending actions (e.g., "You haven't updated soil data in 2 weeks"). **Crop Lifecycle Tracking** displaying current growth stages and expected harvest time.
- **My Farm:** *(v2.2 Enhanced)* Farm management connected to centralized farm service. **Interactive satellite map view** with an advanced **NDVI / Vegetation Index Layer** overlay to visualize crop health (Healthy/Stressed). Detailed farm view with soil metrics, crop history, and recent operations.
- **Task Automation System:** *(v2.2 New)* Create and manage tasks (Irrigation, Fertilization, Spraying) with daily/weekly scheduling, worker assignment, and completion tracking.
- **Profit Calculator:** *(v2.2 New)* Financial tool to estimate expected yields and calculate potential profit based on current market prices and input costs.
- **Soil:** Tools and data points for tracking soil health, moisture levels, and nutrient profiles.
- **Market:** Real-time market monitoring, commodity prices, and agricultural trends with expandable forecast details. Crop-specific visual icons with gradient colors for each commodity.

### 3.4. AI Intelligence & Models
- **AI Models Screen:** *(v2.0 Enhanced)* Each model card displays current input values used for predictions (N, P, K, temperature, humidity, pH, rainfall sourced from selected farm). "Run Model" button with results bottom sheet. Model accuracy/confidence display.
- **AI Agriculture Assistant (Plant Disease Diagnostics):**
  - Powered by a fine-tuned Qwen3-VL-2B vision-language model deployed on Hugging Face Spaces.
  - Includes a RAG (Retrieval-Augmented Generation) pipeline utilizing the AgroLLM knowledge base.
  - Allows users to upload images for disease identification and ask natural language questions regarding agricultural advice.
- **AI Medicine Chat:**
  - An interactive, AI-powered medical assistant utilizing the Groq Vision model.
  - Analyzes uploaded images of agricultural medications or standard medicines to provide contextual, structured medical reports in Arabic.
  - Supports follow-up text conversations for deeper understanding.

### 3.5. Communication & Engagement
- **Chat (FarmBrain AI):** *(v2.0 Redesigned)* ChatGPT-inspired clean, minimal UI:
  - Clean white/light message area (dark in dark mode)
  - User messages right-aligned without bubble decorations
  - AI messages left-aligned with avatar and markdown support
  - Conversation history in side drawer
  - Minimal suggestion chips
  - Pinned input bar with attachment and send buttons
  - Animated typing indicator
- **Notifications:** Push notifications and in-app alerts for critical farm events, market changes, or AI diagnostics results.
- **Profile & Auth:** Secure user authentication, profile management, and preference settings (including language selection and dark/light mode toggle).

## 4. Design System

### 4.1. Color Palette *(v2.0 Harmonized)*
- **Primary:** Deep Forest Green `#1B4332`
- **Secondary:** Leaf Green `#2D6A4F`
- **Accent:** Golden Amber `#FFB800`
- **Surface Light:** `#F3F4ED`
- **Surface Dark:** `#0F1A12`
- **Success:** `#22C55E`
- **Error:** `#BA1A1A`
- **Warning:** `#F59E0B`
- **Info:** `#0EA5E9`

### 4.2. Typography
- **Headings:** Manrope (Bold/ExtraBold)
- **Body:** Inter (Regular/Medium)
- **UI Labels:** Manrope (SemiBold/Bold)

### 4.3. UX Principles *(v2.0 New)*
- **Understandability:** Technical terms (N, P, K, pH) include help icons with plain-language tooltips
- **Dual-audience:** Information architecture serves both novice farmers and agricultural experts
- **Micro-animations:** Card entrances, tab transitions, loading states for premium feel
- **Empty states:** Illustrated placeholders when no data is available

## 5. Technology Stack
- **Frontend / Mobile Client:** Flutter (Dart ^3.7.0)
- **UI Components & Theming:** Material Design 3, `cupertino_icons`, `google_fonts`, `svg_flutter`.
- **Data Visualization:** `fl_chart`.
- **Local Storage:** `shared_preferences`.
- **Localization:** `flutter_localizations`, `intl` *(v2.0 New)*
- **AI & Machine Learning (Backend Services):**
  - Fine-tuned Qwen3-VL-2B (Vision-Language processing for plant diseases).
  - Hugging Face Spaces (Model hosting).
  - Groq Vision (Medicine analysis).
  - RAG Architecture with AgroLLM.
- **Weather API:** Open-Meteo (free, no API key required). Current weather + multi-day forecast via `api.open-meteo.com`.
- **Mapping:** `flutter_map` with `latlong2` for satellite map views. Esri World Imagery tile provider for satellite imagery.

## 6. Non-Functional Requirements
- **Performance:** Fast loading times, especially when uploading images to AI services. Smooth UI rendering at 60fps. Cached API responses to reduce network overhead.
- **Usability:** Intuitive, accessible design that caters to users with varying levels of technical literacy. Help tooltips for expert terminology.
- **Localization:** High-quality, farmer-friendly Arabic translations with right-to-left (RTL) layout support. Terminology tooltips explaining technical terms in simple language.
- **Reliability:** Graceful error handling for AI requests and network issues, caching previously fetched data where possible.
- **Theming:** Consistent visual identity across light and dark modes with harmonized color palette.

## 7. v2.2 Changelog Summary
1. **Task Automation System:** Create, schedule, and assign tasks (Irrigation, Fertilization, Spraying) with completion tracking.
2. **Crop Lifecycle Tracking:** System tracks and visualizes growth stages and expected harvest time.
3. **NDVI Layer:** Satellite map overlay showing crop health via vegetation index (Healthy/Stressed).
4. **Smart Nudges:** Context-aware reminders for farm updates and pending checks.
5. **Profit Calculator:** Tool to calculate expected financial returns.

## 8. v2.1 Changelog Summary
1. **Weather Integration:** Live weather data via Open-Meteo API with real-time conditions and 5-day forecast
2. **Satellite Maps:** Interactive Esri satellite imagery on My Farm and Farm Selection screens
3. **Crop Visuals:** Commodity-specific emoji icons with gradient badges in Market screen
4. **Map-Based Farm Creation:** Tap-to-set-location on satellite map when adding farms
5. **Smart Alerts:** Weather-based farming condition detection (Optimal/Alert/Monitor)
6. **Arabic Weather:** Full Arabic translations for all WMO weather codes
7. **Forecast Display:** 5-day forecast row with weather emojis, high/low temps, and day names (EN/AR)

## 8. v2.0 Changelog Summary
1. **Splash Screen:** Redesigned with unique plant-growth animation and particle effects
2. **Auth Screens:** Responsive full-screen layout, additional signup fields (phone, farm name, location, role)
3. **Farm Selection:** New post-login screen for farm management before entering dashboard
4. **Dashboard:** Consolidated single implementation, connected to active farm context
5. **AI Models:** Display current prediction input values, run model button, confidence metrics
6. **Chat UI:** ChatGPT-inspired minimal design with conversation history drawer
7. **My Farm:** Connected to centralized farm service, farm detail view with history
8. **Farm History:** New operation timeline feature tracking all farm activities
9. **Visual Polish:** Micro-animations, consistent shadows, help tooltips, empty states
10. **Dark Mode:** Full dark theme with forest-inspired palette
11. **Color Palette:** Harmonized and consolidated color system
12. **Arabic Localization:** Complete farmer-friendly Arabic translations with RTL support

## 9. Future Roadmap
- Integration of IoT sensor data for real-time My Farm and Soil updates.
- Expansion of AI capabilities to include predictive crop yield modeling.
- Community features for farmers to share insights and solutions locally.
- Further refinements of the AI models based on continuous user feedback and data collection.
- Cloud sync for farm data across devices.
- Offline mode for areas with limited connectivity.
- Extended 14-day weather forecasts with hourly breakdowns.
- Push notifications for weather alerts and frost warnings.
