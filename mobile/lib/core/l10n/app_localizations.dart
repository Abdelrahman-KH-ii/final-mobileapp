import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  String convertNumbers(String input) {
    if (!isArabic) return input;
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // ── App ──
      'app_name': 'FarmTec',
      'tagline': 'Precision Intelligence for the Modern Farm',
      'precision_intelligence': 'Precision Intelligence',
      'loading_farm_data': 'Loading your farm data...',

      // ── Auth ──
      'welcome_back': 'Welcome Back',
      'sign_in_subtitle':
          'Sign in to manage your precision agriculture ecosystem.',
      'create_account': 'Create Account',
      'sign_up_subtitle':
          'Enter your details to start monitoring your digital ecosystem.',
      'email_address': 'Email Address',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'farm_name': 'Farm Name',
      'location_region': 'Location / Region',
      'user_role': 'User Role',
      'role_farmer': 'Farmer',
      'role_expert': 'Agricultural Expert',
      'role_student': 'Student',
      'login_button': 'Login To Dashboard',
      'signup_button': 'Sign Up',
      'no_account': "Don't have an account? ",
      'sign_up': 'Sign Up',
      'have_account': 'Already have an account? ',
      'login': 'Login',
      'or': 'OR',
      'terms_prefix': 'By signing up, you agree to our ',
      'terms_of_service': 'Terms of Service',
      'and': ' and ',
      'privacy_policy': 'Privacy Policy',

      // ── Navigation ──
      'dashboard': 'Dashboard',
      'my_farm': 'My Farm',
      'ai_models': 'AI Models',
      'market': 'Market',
      'chat': 'Chat',

      // ── Farm Selection ──
      'select_farm': 'Select Your Farm',
      'select_farm_subtitle': 'Choose a farm to manage or add a new one',
      'add_first_farm': 'Add Your First Farm',
      'add_first_farm_desc': 'Get started by adding your farm details',
      'add_farm': 'Add Farm',
      'add_field': 'Add Field',
      'continue_text': 'Continue',
      'farms_tab': 'Farms',
      'farms': 'Farms',
      'activity_tab': 'Recent Activity',
      'recent_activity': 'Recent Activity',

      // ── Dashboard ──
      'good_morning': 'Good Morning 🌱',
      'soil_metrics': 'Soil Metrics',
      'soil_analysis_score': 'Soil Analysis',
      'soil_health_score': 'Soil Health Score',
      'overall_soil_health': 'Overall Soil Health',
      'organic_matter': 'Organic Matter',
      'texture': 'Texture',
      'ai_recommendation': 'AI Recommendation',
      'active_processes': 'Active Processes',
      'market_snapshot': 'Market Snapshot',
      'weather': 'Weather',
      'nitrogen': 'Nitrogen',
      'phosphorus': 'Phosphorus',
      'potassium': 'Potassium',
      'moisture': 'Moisture',
      'humidity': 'Humidity',
      'precipitation': 'Precipitation',
      'wind': 'Wind',
      'soil_temp': 'Soil Temp',
      'optimal': 'Optimal',
      'medium': 'Medium',
      'for_growth': 'FOR GROWTH',
      'apply_now': 'Apply Now',
      'schedule': 'Schedule',
      'nitrogen_tip': 'Essential element for plant leaf growth',
      'phosphorus_tip': 'Supports root development and flowering',
      'potassium_tip': 'Strengthens the plant and improves disease resistance',
      'ph_tip': 'Measures soil acidity/alkalinity (ideal: 6.0-7.0)',
      'disease_scan': 'Disease Scan',
      'analyzing': 'Analyzing...',
      'farming_advice_description': 'Practical tips to improve crop health and farm efficiency.',
      'farming_advice_short_label': 'For better results',
      'yield_prediction': 'Yield Prediction',
      'complete': 'Complete',
      'farming_advice_tips': 'Farming Advice & Tips',
      'advice_crop_rotation': 'Rotate crops annually to maintain soil balance and reduce pests.',
      'advice_irrigation_practices': 'Use drip irrigation and schedule watering based on soil moisture.',
      'advice_soil_fertility': 'Add organic matter and test nutrients regularly to keep soil fertile.',
      'advice_pest_monitoring': 'Scout fields weekly and use natural controls to manage pests early.',

      // ── AI Models ──
      'ai_engine': 'FarmBrain AI Engine',
      'all_models_ready': 'All models ready',
      'live': 'LIVE',
      'available_models': 'Available Models',
      'recent_analyses': 'Recent Analyses',
      'crop_recommendation': 'Crop Recommendation',
      'crop_recommendation_desc': 'Predicts optimal crop based on GPS location',
      'disease_detection': 'Disease Detection',
      'disease_detection_desc':
          'Upload crop photos for instant disease identification.',
      'yield_prediction_desc':
          'Forecasts crop yield from location, year & crop type',
      'nutrient_optimizer': 'Nutrient Optimizer',
      'nutrient_optimizer_desc':
          'Precise fertilizer recommendations for each field block.',
      'weather_forecast': 'Weather Forecast',
      'weather_forecast_desc':
          'Hyperlocal 14-day forecast for precision planning.',
      'irrigation_planner': 'Irrigation Planner',
      'irrigation_planner_desc':
          'Calculates irrigation needs from GPS coordinates',
      'market_forecast': 'Market Forecast',
      'market_forecast_desc': 'Commodity price forecast from live market data',
      'current_values': 'Current Values',
      'run_model': 'Run Model',
      'run_prediction': 'Run Prediction',
      'model_inputs': 'Model Inputs',
      'input_parameters': 'Input Parameters',
      'uses_defaults': 'Uses defaults if left empty',
      'prediction_results': 'Prediction Results',
      'confidence': 'Confidence',
      'tap_model_subtitle': 'Tap a model to run live predictions',
      'connected_to_api': 'Connected to HuggingFace APIs',
      'get_request': 'GET request',
      'parameters': 'parameters',
      'stat_accuracy': 'Accuracy',
      'stat_speed': 'Speed',
      'stat_runs': 'Runs',
      'photo_and_text': 'Photo + text',
      'new_badge': 'NEW',
      'upload_plant_photo': 'Upload Plant Photo',
      'take_photo': 'Camera',
      'choose_from_gallery': 'Gallery',
      'tap_to_add_photo': 'Add a clear photo of the affected leaf or plant',
      'photo_required': 'Please add a plant photo before running analysis.',
      'vision_model_badge': 'Vision LLM · HuggingFace',
      'analyze_plant': 'Analyze Plant',
      'optional_question': 'Optional Question',
      'plant_question_hint':
          'Describe symptoms or ask about treatment, crop type, or severity...',

      // ── Market ──
      'market_prices': 'Market Prices',
      'market_subtitle': 'Live commodity prices · Updated every 15 min',
      'all_commodities': 'All Commodities',
      'crops': 'Crops',
      'fruits': 'Fruits',
      'vegetables': 'Vegetables',
      'grains': 'Grains',
      'sort': 'Sort',
      'sort_default': 'Default',
      'sort_price_high': 'Price: High to Low',
      'sort_price_low': 'Price: Low to High',
      'sort_change_high': 'Highest Gainers',
      'forecast_details': 'Forecast Details',
      'current_price': 'Current Price',
      'failed_to_load_market': 'Failed to load market prices.',
      'no_market_for_crop': 'No market price available for {crop} right now.',
      'per_ton': '/t',
      'wheat': 'Wheat',
      'maize': 'Maize',
      'rice': 'Rice',
      'mango': 'Mango',
      'potato': 'Potato',
      'tomato': 'Tomato',
      'jowar_(sorghum)': 'Jowar (Sorghum)',
      'green_fodder': 'Green Fodder',
      'field_alpha': 'Field Alpha',
      'field_beta': 'Field Beta',
      'field_gamma': 'Field Gamma',
      'model_training_complete': 'Model training complete',

      // ── My Farm ──
      'all_fields': 'All Fields',
      'total_area': 'Total Area',
      'healthy_fields': 'Healthy Fields',
      'alerts': 'Alerts',
      'healthy': 'Healthy',
      'warning': 'Warning',
      'critical': 'Critical',
      'field_name': 'Field Name',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'use_gps': 'Use Current GPS Location',
      'fetching_gps': 'Fetching GPS...',
      'crop_type': 'Crop Type',
      'area_hectares': 'Area (hectares)',
      'add_new_field': 'Add New Field',
      'field_added': '✅ Field added!',
      'no_farm_selected': 'No farm selected',
      'farm_details': 'Your farm details in one place',
      'farm_overview': 'Farm Overview',
      'location': 'Location',
      'view_map': 'View on Map',
      'view_map_btn': 'View Map',
      'change_crop': 'Change Crop',
      'location_coordinates': 'Location Coordinates',
      'coords_short_format': '{lat} , {lng}',
      'no_recent_activity': 'No recent activity',
      'health': 'Health',
      'last_scan': 'Last Scan',

      // ── Farm History ──
      'history': 'History',
      'recent_operations': 'Recent Operations',
      'no_operations': 'No operations yet',
      'fertilizer_applied': 'Fertilizer Applied',
      'irrigation_completed': 'Irrigation Completed',
      'disease_scan_run': 'Disease Scan Run',
      'crop_planted': 'Crop Planted',
      'weather_alert': 'Weather Alert',
      'farm_created': 'Farm Created',
      'op_ai_crop_recommendation': 'Crop Recommendation',
      'op_ai_yield_prediction': 'Yield Prediction',
      'op_ai_irrigation_planner': 'Irrigation Planner',
      'op_ai_market_forecast': 'Market Forecast',
      'op_ai_disease_detection': 'Disease Detection',
      'no_activity_yet': 'No activity yet',
      'activity_on_farm': 'Farm: {farm}',
      'ndvi_scan': 'NDVI Scan',
      'ndvi_scan_result': 'Avg NDVI {value}',
      'ndvi_no_location': 'Add GPS coordinates to run an NDVI scan',
      'ndvi_analyzing': 'Analyzing vegetation...',
      'ndvi_healthy': 'Healthy',
      'ndvi_stressed': 'Stressed',
      'gps_coordinates': 'GPS Coordinates',
      'lat_lng_format': 'Lat: {lat}  ·  Lng: {lng}',
      'lat_lng_format_ar': 'Lat: {lat} · Lng: {lng}',
      'planting_date': 'Planting Date',
      'select_planting_date': 'Select planting date',
      'no_planting_date': 'Not set',
      'crop_lifecycle': 'Crop Lifecycle',
      'profit_calculator': 'Profit Calculator',
      'estimated_yield': 'Estimated Yield',
      'current_market_price': 'Current Market Price',
      'source': 'Source',
      'total_expected_profit': 'Total Expected Profit',
      'day_n': 'Day {n}',
      'sowing': 'Sowing',
      'expected_harvest': 'Expected Harvest',
      'set_planting_date_hint': 'Set a planting date when adding your farm',
      'stage_germination': 'Germination',
      'stage_emergence': 'Emergence',
      'stage_vegetative': 'Vegetative',
      'stage_tillering': 'Tillering',
      'stage_heading': 'Heading',
      'stage_maturity': 'Maturity',
      'stage_seedling': 'Seedling',
      'stage_panicle': 'Panicle',
      'stage_ripening': 'Ripening',
      'stage_transplant': 'Transplant',
      'stage_flowering': 'Flowering',
      'stage_fruiting': 'Fruiting',
      'stage_sprouting': 'Sprouting',
      'stage_canopy_growth': 'Canopy Growth',
      'stage_tuber_bulking': 'Tuber Bulking',
      'stage_maturation': 'Maturation',
      'stage_flush': 'Flush',
      'stage_fruit_set': 'Fruit Set',
      'stage_booting': 'Booting',
      'stage_grain_maturity': 'Grain Maturity',
      'stage_establishment': 'Establishment',
      'stage_leaf_growth': 'Leaf Growth',
      'stage_cutting': 'Cutting',
      'map_preview': 'Map Preview',
      'map_satellite_attribution': '© Mapbox © Maxar',
      'tap_map_set_location': 'Tap map to set location',
      'about': 'About',
      'auto_filled_gps': 'Auto-filled from your farm GPS',
      'api_error': 'API Error {code}',
      'connection_error':
          'Could not connect. Model may be sleeping — retry in 30s.',
      'clear_all': 'Clear All',
      'no_notifications': 'No notifications',
      'time_ago_minutes': '{n}m ago',
      'time_ago_hours': '{h}h ago',
      'time_ago_days': '{d}d ago',
      'task_automation': 'Next Tasks',
      'location_fetch_failed': 'Failed to get location',
      'year': 'Year',
      'notifications_off': 'Notifications are turned off.',
      'no_notifications_match':
          'No notifications match your alert settings.',
      'notifications_subtitle': 'Weather, market, and farm alerts in one place',
      'notifications_empty_hint':
          'Pull down to refresh or adjust alert settings in Profile.',
      'mark_all_read': 'Mark all read',
      'enable_push_prompt':
          'Allow push notifications to receive weather and market alerts.',
      'enable': 'Enable',

      // ── Chat ──
      'farmbrain_ai': 'FarmBrain AI',
      'ask_anything': 'Ask FarmBrain anything...',
      'new_chat': 'New Chat',
      'chat_history': 'Chat History',
      'question_field_health': '🌿 What are common signs of healthy crops?',
      'question_irrigation': '💧 What are good irrigation best practices?',
      'question_disease': '🦠 How can I spot crop diseases early?',
      'question_market': '📈 What are current agriculture market trends?',
      'question_crop': '🌱 What crops are best for the upcoming season?',
      'suggestion_analyze': '🌿 Analyze Field',
      'suggestion_irrigation': '💧 Irrigation schedule',
      'suggestion_disease': '🦠 Disease check',
      'suggestion_market': '📈 Market update',
      'suggestion_crop': '🌱 Crop recommendation',

      // ── Profile / Settings ──
      'profile': 'Profile',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'english': 'English',
      'arabic': 'العربية',
      'notifications': 'Notifications',
      'logout': 'Logout',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Sign Out?',
      'sign_out_message':
          'You will need to log in again to access your farm data.',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'save_changes': 'Save Changes',
      'update_password': 'Update Password',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_password': 'Confirm Password',
      'profile_updated': 'Profile updated!',
      'appearance': 'Appearance',
      'account': 'Account',
      'support': 'Support',
      'help_faq': 'Help & FAQ',
      'about_us': 'About Us',
      'contact': 'Contact',
      'app_version': 'App Version',
      'farm_statistics': 'Farm Statistics',
      'efficiency': 'Efficiency',
      'push_notifications': 'Push Notifications',
      'weather_alerts': 'Weather Alerts',
      'market_price_alerts': 'Market Price Alerts',
      'disease_alerts': 'Disease Alerts',

      // ── General ──
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'done': 'Done',
      'failed_to_load': 'Failed to load data',
      'synchronizing': 'SYNCHRONIZING SOIL DATA',
      'version': '@FarmTec v2.0',

      // ── Onboarding ──
      'skip': 'Skip',
      'next': 'Next',
      'get_started': 'Get Started',
      'skip_onboarding': 'Skip Onboarding',
      'onboarding_title_1': 'Maximize Your Profits',
      'onboarding_subtitle_1':
          'Real-time market tracking and AI-driven price forecasting to help you sell at the optimal moment.',
      'onboarding_label_veg_index': 'VEGETATION INDEX',
      'onboarding_val_veg_index': '0.82 NDVI',
      'onboarding_sub_veg_index': '+4% vs last scan',
      'onboarding_label_light_exp': 'LIGHT EXPOSURE',
      'onboarding_val_light_exp': '94%',
      'onboarding_title_2': 'AI-Powered\nInsights',
      'onboarding_subtitle_2':
          'Upload photos of your crops for instant disease detection and nutrient analysis.',
      'onboarding_label_status': 'STATUS',
      'onboarding_val_status_progress': 'Analysis in Progress...',
      'onboarding_label_detection': 'DETECTION',
      'onboarding_val_confidence': '98.4% Confidence',
      'onboarding_title_3': 'Optimize\nEvery Drop',
      'onboarding_subtitle_3':
          'Automated irrigation plans that adjust based on weather forecasts and soil moisture levels.',
      'onboarding_tag_smart_irrigation': 'SMART IRRIGATION',
      'onboarding_label_moisture': 'MOISTURE',
      'onboarding_val_moisture': '68%',
      'onboarding_label_forecast': 'FORECAST',
      'onboarding_val_forecast_rain': 'Rain 2pm',
      'onboarding_feat_title_scaling': 'Predictive Scaling',
      'onboarding_feat_desc_scaling':
          'Systems scale water use 12 hours before rain events.',

      // ── Units & Measures ──
      'ppm': 'ppm',
      'ha': 'ha',
      'seconds_abbr': 's',
      'thousands_abbr': 'K',

      // ── Extra Dashboard ──
      'ai_reco_apply_urea':
          'Apply 15 kg/ha of Urea to {farm} for optimal nitrogen before next rainfall.',
      'precipitation_value': '{value}mm',
      'wind_value': '{value} km/h',
      'temp_value': '{value}°C',
      'soil_temp_value': '{value}°C',
      'forecast_5day': '5-Day Forecast',
      'weather_unavailable': 'Weather unavailable',
      'alert': 'Alert',
      'monitor': 'Monitor',
      'nitrogen_n': 'Nitrogen (N)',
      'phosphorus_p': 'Phosphorus (P)',
      'potassium_k': 'Potassium (K)',
      'ph_level': 'pH Level',

      // ── Extra AI Models ──
      'parameters_count': '{count} parameters',
      'models_live_count': '{count} LIVE',
      'recommended_crop': '🌾 Recommended: {crop}',
      'yield_predicted': '📊 Yield: {yield} {unit}',
      'irrigation_need': '💧 Need: {need}mm ({class})',

      // ── Extra Chat ──
      'chat_welcome':
          "Hello! I'm FarmBrain, your AI agriculture assistant. How can I help you today?",
      'new_conversation_started':
          'New conversation started. How can I help you?',

      // ── Extra Market ──
      'per_ton_full': 'per ton',
      'quarter_format': 'Q{quarter} {year}',

      // ── Extra Profile ──
      'profile_user_name': 'Ahmed Al-Rashid',
      'profile_user_role': 'Senior Farm Manager · 8 years',
      'north_region': 'North Region',

      // ── Extra Support & FAQ ──
      'help_faq_heading': 'How can we help?',
      'help_faq_summary':
          'Quick answers for the whole FarmTec app: dashboard, farms, AI models, NDVI, market data, notifications, profile, and account settings.',
      'faq_sec_ndvi': 'Using NDVI',
      'faq_sec_ndvi_line1':
          'Open My Farm, select a field, then tap Run Scan to refresh the vegetation index.',
      'faq_sec_ndvi_line2':
          'Scores near 1.00 indicate strong plant vigor. Lower scores point to water, nutrient, or disease stress.',
      'faq_sec_dash': 'Dashboard and profit',
      'faq_sec_dash_line1':
          'The dashboard summarizes weather, farm status, tasks, market context, and projected gross profit.',
      'faq_sec_dash_line2':
          'Profit uses the latest Yield Prediction model result, then multiplies it by the current market price.',
      'faq_sec_ai': 'AI models',
      'faq_sec_ai_line1':
          'Open AI Models to run crop recommendation, disease detection, yield prediction, irrigation, weather, and nutrient tools.',
      'faq_sec_ai_line2':
          'Yield Prediction saves its latest result so the profit calculator can use the same number.',
      'faq_sec_fields': 'Managing fields',
      'faq_sec_fields_line1':
          'Use Add Field to save a field name, crop, area, and GPS location.',
      'faq_sec_fields_line2':
          'Tap any field card to view crop lifecycle, soil readings, NDVI analysis, activity, and AI insights.',
      'faq_sec_lifecycle': 'Crop lifecycle',
      'faq_sec_lifecycle_line1':
          'Lifecycle cards show stage windows and field actions for every available crop.',
      'faq_sec_lifecycle_line2':
          'Supported crops include Wheat, Maize, Rice, Tomato, Potato, Mango, Jowar (Sorghum), and Green Fodder.',
      'faq_sec_market': 'Market and notifications',
      'faq_sec_market_line1':
          'Market shows commodity prices and forecast details for supported crops.',
      'faq_sec_market_line2':
          'Profile controls push notifications plus weather and market price alert categories.',
      'faq_sec_alerts': 'Alerts and notifications',
      'faq_sec_alerts_line1':
          'Weather and market price alerts can be enabled or disabled from Profile.',
      'faq_sec_alerts_line2':
          'Critical field health should be inspected in person before applying treatment.',

      'privacy_heading': 'Your farm data stays yours',
      'privacy_summary':
          'FarmTec uses account, field, and location data only to provide farm monitoring, recommendations, and app functionality.',
      'privacy_sec_data': 'Data we use',
      'privacy_sec_data_line1':
          'Profile details, selected farms, crop information, field locations, and app preferences.',
      'privacy_sec_data_line2':
          'Location is used for maps, weather context, field boundaries, and vegetation analysis.',
      'privacy_sec_protect': 'How data is protected',
      'privacy_sec_protect_line1':
          'Local preferences are stored on the device for faster access.',
      'privacy_sec_protect_line2':
          'We do not sell personal or farm data. Shared reports should be sent only to people you trust.',
      'privacy_sec_choices': 'Your choices',
      'privacy_sec_choices_line1':
          'You can update profile details, change notification settings, or sign out from Profile.',
      'privacy_sec_choices_line2':
          'Remove saved farms when you no longer want them available in the app.',

      'about_heading': 'Precision intelligence for farms',
      'about_summary':
          'FarmTec brings field monitoring, satellite-style vegetation analysis, market context, and AI guidance into one mobile workspace.',
      'about_sec_build': 'What we build',
      'about_sec_build_line1':
          'Tools that help growers understand crop health, soil condition, irrigation needs, and market movement.',
      'about_sec_build_line2':
          'Simple field workflows that make data useful while work is happening.',
      'about_sec_approach': 'Our approach',
      'about_sec_approach_line1':
          'Clear recommendations, practical metrics, and fast access from the farm dashboard.',
      'about_sec_approach_line2':
          'AI support is designed to assist decisions, not replace field inspection or agronomic judgment.',

      'contact_heading': 'Talk to FarmTec support',
      'contact_summary':
          'Reach out for account help, field setup questions, product feedback, or partnership conversations.',
      'contact_sec_support': 'Support',
      'contact_sec_support_line1': 'Email: support@farmtec.io',
      'contact_sec_support_line2': 'Phone: +20 100 000 0000',
      'contact_sec_support_line3':
          'Hours: Sunday to Thursday, 9:00 AM - 6:00 PM Cairo time.',
      'contact_sec_when': 'When contacting us',
      'contact_sec_when_line1':
          'Include your farm name, field name, crop, and the screen where you saw the issue.',
      'contact_sec_when_line2':
          'For NDVI or map issues, include the field GPS location if available.',

      // ── Extra Notifications ──
      'market_update': 'Market Update',
      'just_now': 'Just now',
      'notif_market_changed':
          'Wheat price changed to {price}/t. Review your selling strategy.',
      'notif_market_up':
          'Wheat price up 2.3% to \$287.50/t. Consider selling this week.',
      'notif_weather_adjust':
          'Significant temperature change expected tomorrow. Adjust irrigation accordingly.',
    },
    'ar': {
      // ── App ──
      'app_name': 'فارم تك',
      'tagline': 'ذكاء زراعي متقدّم لمزرعتك',
      'precision_intelligence': 'ذكاء زراعي دقيق',
      'loading_farm_data': 'جارِ تحميل بيانات المزرعة...',

      // ── Auth ──
      'welcome_back': 'مرحباً بعودتك',
      'sign_in_subtitle': 'سجّل دخولك لإدارة مزرعتك الذكية.',
      'create_account': 'إنشاء حساب جديد',
      'sign_up_subtitle': 'أدخل بياناتك لبدء إدارة مزرعتك.',
      'email_address': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'full_name': 'الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'farm_name': 'اسم المزرعة',
      'location_region': 'الموقع / المنطقة',
      'user_role': 'نوع المستخدم',
      'role_farmer': 'مزارع',
      'role_expert': 'مهندس زراعي',
      'role_student': 'طالب',
      'login_button': 'دخول',
      'signup_button': 'إنشاء حساب',
      'no_account': 'ليس لديك حساب؟ ',
      'sign_up': 'سجّل الآن',
      'have_account': 'لديك حساب بالفعل؟ ',
      'login': 'تسجيل الدخول',
      'or': 'أو',
      'terms_prefix': 'بالتسجيل، أنت توافق على ',
      'terms_of_service': 'شروط الاستخدام',
      'and': ' و ',
      'privacy_policy': 'سياسة الخصوصية',

      // ── Navigation ──
      'dashboard': 'الرئيسية',
      'my_farm': 'مزرعتي',
      'ai_models': 'الذكاء الاصطناعي',
      'market': 'السوق',
      'chat': 'المحادثة',

      // ── Farm Selection ──
      'select_farm': 'اختر مزرعتك',
      'select_farm_subtitle': 'اختر مزرعة لإدارتها أو أضف واحدة جديدة',
      'add_first_farm': 'أضف مزرعتك الأولى',
      'add_first_farm_desc': 'ابدأ بإضافة تفاصيل مزرعتك',
      'add_farm': 'إضافة مزرعة',
      'add_field': 'إضافة حقل',
      'continue_text': 'متابعة',
      'farms_tab': 'المزارع',
      'farms': 'المزارع',
      'activity_tab': 'آخر الأنشطة',
      'recent_activity': 'آخر الأنشطة',

      // ── Dashboard ──
      'good_morning': 'صباح الخير 🌱',
      'soil_metrics': 'تحليل التربة',
      'soil_analysis_score': 'تحليل صحة التربة',
      'soil_health_score': 'درجة صحة التربة',
      'overall_soil_health': 'الصحة العامة للتربة',
      'organic_matter': 'المواد العضوية',
      'texture': 'الملمس',
      'ai_recommendation': 'توصية ذكية',
      'active_processes': 'العمليات الجارية',
      'market_snapshot': 'نظرة على الأسعار',
      'weather': 'حالة الطقس',
      'nitrogen': 'نيتروجين (N)',
      'phosphorus': 'فوسفور (P)',
      'potassium': 'بوتاسيوم (K)',
      'moisture': 'رطوبة التربة',
      'humidity': 'رطوبة الجو',
      'precipitation': 'كمية الأمطار',
      'wind': 'سرعة الرياح',
      'soil_temp': 'حرارة التربة',
      'optimal': 'مثالي',
      'medium': 'متوسط',
      'for_growth': 'للنمو',
      'apply_now': 'تطبيق الآن',
      'schedule': 'جدولة',
      'nitrogen_tip': 'عنصر أساسي لنمو أوراق النبات وزيادة اللون الأخضر',
      'farming_advice_short_label': 'لنتائج أفضل',
      'phosphorus_tip': 'يساعد على نمو الجذور وتكوين الأزهار والثمار',
      'potassium_tip': 'يقوّي النبات ويزيد مقاومته للأمراض والجفاف',
      'ph_tip': 'درجة حموضة التربة — المثالي بين ٦.٠ و ٧.٠',
      'disease_scan': 'فحص الأمراض',
      'analyzing': 'جارِ التحليل...',
      'farming_advice_description': 'نصائح عملية لتحسين صحة المحاصيل وكفاءة المزرعة.',
      'yield_prediction': 'توقع المحصول',
      'complete': 'مكتمل',
      'farming_advice_tips': 'نصائح وإرشادات زراعية',
      'advice_crop_rotation': 'دوِّر المحاصيل سنويًا للحفاظ على توازن التربة وتقليل الآفات.',
      'advice_irrigation_practices': 'استخدم الري بالتنقيط وجدول الري حسب رطوبة التربة.',
      'advice_soil_fertility': 'أضف المواد العضوية وافحص العناصر الغذائية بانتظام.',
      'advice_pest_monitoring': 'افحص الحقول أسبوعيًا واستخدم الضوابط الطبيعية مبكرًا.',

      // ── AI Models ──
      'ai_engine': 'محرك فارم برين',
      'all_models_ready': 'جميع النماذج جاهزة',
      'live': 'مباشر',
      'available_models': 'النماذج المتاحة',
      'recent_analyses': 'تحليلات سابقة',
      'crop_recommendation': 'اقتراح المحصول الأنسب',
      'crop_recommendation_desc':
          'يقترح أفضل محصول بناءً على موقع الأرض والطقس.',
      'disease_detection': 'كشف أمراض النبات',
      'disease_detection_desc': 'ارفع صورة النبات للتعرف على المرض فوراً.',
      'yield_prediction_desc':
          'يتوقع كمية الإنتاج من الموقع ونوع المحصول والسنة.',
      'nutrient_optimizer': 'تحسين تغذية التربة',
      'nutrient_optimizer_desc':
          'يحدد الأسمدة المناسبة وكميتها لكل جزء من الأرض.',
      'weather_forecast': 'توقعات الطقس',
      'weather_forecast_desc': 'توقعات دقيقة لـ١٤ يوم لمنطقتك.',
      'irrigation_planner': 'تخطيط الري',
      'irrigation_planner_desc':
          'يحسب كمية المياه المطلوبة بناءً على حالة التربة.',
      'market_forecast': 'توقعات الأسعار',
      'market_forecast_desc': 'يعرض توقعات أسعار المحاصيل في السوق.',
      'current_values': 'القيم الحالية',
      'run_model': 'تشغيل التحليل',
      'run_prediction': 'ابدأ التحليل',
      'model_inputs': 'البيانات المطلوبة',
      'input_parameters': 'البيانات المطلوبة',
      'uses_defaults': 'ستُستخدم قيم تلقائية إن تُركت فارغة',
      'prediction_results': 'نتائج التحليل',
      'confidence': 'نسبة الدقة',
      'tap_model_subtitle': 'اضغط على أي نموذج لبدء التحليل',
      'connected_to_api': 'متصل بخوادم الذكاء الاصطناعي',
      'get_request': 'طلب تلقائي',
      'parameters': 'بيانات مطلوبة',
      'stat_accuracy': 'الدقة',
      'stat_speed': 'السرعة',
      'stat_runs': 'التشغيلات',
      'photo_and_text': 'صورة + نص',
      'new_badge': 'جديد',
      'upload_plant_photo': 'ارفع صورة النبات',
      'take_photo': 'التقاط',
      'choose_from_gallery': 'المعرض',
      'tap_to_add_photo': 'أضف صورة واضحة للورقة أو النبات المتضرر',
      'photo_required': 'يرجى إضافة صورة للنبات قبل بدء التحليل.',
      'vision_model_badge': 'نموذج رؤية · HuggingFace',
      'analyze_plant': 'تحليل النبات',
      'optional_question': 'سؤال اختياري',
      'plant_question_hint':
          'صف الأعراض أو اسأل عن العلاج أو نوع المحصول أو شدة المرض...',

      // ── Market ──
      'market_prices': 'أسعار المحاصيل',
      'market_subtitle': 'أسعار حية · تحديث كل ١٥ دقيقة',
      'all_commodities': 'كل السلع',
      'crops': 'محاصيل',
      'fruits': 'فواكه',
      'vegetables': 'خضروات',
      'grains': 'حبوب',
      'sort': 'ترتيب',
      'sort_default': 'الافتراضي',
      'sort_price_high': 'السعر: الأعلى للأقل',
      'sort_price_low': 'السعر: الأقل للأعلى',
      'sort_change_high': 'الأعلى تغيراً',
      'forecast_details': 'تفاصيل التوقعات',
      'current_price': 'السعر الحالي',
      'failed_to_load_market': 'فشل تحميل أسعار السوق.',
      'no_market_for_crop': 'لا يتوفر سعر سوق لـ{crop} حالياً.',
      'per_ton': '/طن',
      'wheat': 'قمح',
      'maize': 'ذرة',
      'rice': 'أرز',
      'mango': 'مانجو',
      'potato': 'بطاطس',
      'tomato': 'طماطم',
      'jowar_(sorghum)': 'ذرة رفيعة (سورغم)',
      'green_fodder': 'علف أخضر',
      'field_alpha': 'الحقل ألفا',
      'field_beta': 'الحقل بيتا',
      'field_gamma': 'الحقل جاما',
      'model_training_complete': 'اكتمل تدريب النموذج',

      // ── My Farm ──
      'all_fields': 'جميع الحقول',
      'total_area': 'المساحة الإجمالية',
      'healthy_fields': 'حقول بحالة جيدة',
      'alerts': 'تنبيهات',
      'healthy': 'بحالة جيدة',
      'warning': 'يحتاج انتباه',
      'critical': 'حالة حرجة',
      'field_name': 'اسم الحقل',
      'latitude': 'خط العرض',
      'longitude': 'خط الطول',
      'use_gps': 'استخدم موقعي الحالي (GPS)',
      'fetching_gps': 'جارِ تحديد الموقع...',
      'crop_type': 'نوع المحصول',
      'area_hectares': 'المساحة (هكتار)',
      'add_new_field': 'إضافة حقل جديد',
      'field_added': '✅ تمت الإضافة بنجاح!',
      'no_farm_selected': 'لم يتم اختيار مزرعة',
      'farm_details': 'تفاصيل مزرعتك في مكان واحد',
      'farm_overview': 'نظرة عامة على المزرعة',
      'location': 'الموقع',
      'view_map': 'عرض على الخريطة',
      'view_map_btn': 'عرض الخريطة',
      'change_crop': 'تغيير المحصول',
      'location_coordinates': 'إحداثيات الموقع',
      'coords_short_format': '{lat} , {lng}',
      'no_recent_activity': 'لا يوجد نشاط حديث',
      'health': 'الحالة الصحية',
      'last_scan': 'آخر فحص',

      // ── Farm History ──
      'history': 'السجل',
      'recent_operations': 'آخر العمليات',
      'no_operations': 'لا توجد عمليات بعد',
      'fertilizer_applied': 'تم وضع السماد',
      'irrigation_completed': 'تم الري',
      'disease_scan_run': 'تم فحص النبات',
      'crop_planted': 'تمت الزراعة',
      'weather_alert': 'تنبيه طقس',
      'farm_created': 'تم إنشاء المزرعة',
      'op_ai_crop_recommendation': 'اقتراح المحصول',
      'op_ai_yield_prediction': 'توقع المحصول',
      'op_ai_irrigation_planner': 'تخطيط الري',
      'op_ai_market_forecast': 'توقعات السوق',
      'op_ai_disease_detection': 'كشف الأمراض',
      'no_activity_yet': 'لا يوجد نشاط بعد',
      'activity_on_farm': 'المزرعة: {farm}',
      'ndvi_scan': 'فحص NDVI',
      'ndvi_scan_result': 'متوسط NDVI {value}',
      'ndvi_no_location': 'أضف إحداثيات GPS لتشغيل فحص NDVI',
      'ndvi_analyzing': 'جارِ تحليل الغطاء النباتي...',
      'ndvi_healthy': 'صحي',
      'ndvi_stressed': 'مجهد',
      'gps_coordinates': 'إحداثيات GPS',
      'lat_lng_format': 'خط العرض: {lat} · خط الطول: {lng}',
      'lat_lng_format_ar': 'خط العرض: {lat} · خط الطول: {lng}',
      'planting_date': 'تاريخ الزراعة',
      'select_planting_date': 'اختر تاريخ الزراعة',
      'no_planting_date': 'غير محدد',
      'crop_lifecycle': 'دورة حياة المحصول',
      'profit_calculator': 'حاسبة الأرباح',
      'estimated_yield': 'المحصول المقدر',
      'current_market_price': 'سعر السوق الحالي',
      'source': 'المصدر',
      'total_expected_profit': 'إجمالي الربح المتوقع',
      'day_n': 'اليوم {n}',
      'sowing': 'البذر',
      'expected_harvest': 'الحصاد المتوقع',
      'set_planting_date_hint': 'حدد تاريخ الزراعة عند إضافة المزرعة',
      'stage_germination': 'الإنبات',
      'stage_emergence': 'الظهور',
      'stage_vegetative': 'الطور الخضري',
      'stage_tillering': 'التفرع',
      'stage_heading': 'التكوين',
      'stage_maturity': 'النضج',
      'stage_seedling': 'الشتلة',
      'stage_panicle': 'السنابل',
      'stage_ripening': 'النضج',
      'stage_transplant': 'الزراعة',
      'stage_flowering': 'الإزهار',
      'stage_fruiting': 'إثمار',
      'stage_sprouting': 'التبرعم',
      'stage_canopy_growth': 'نمو الظلة',
      'stage_tuber_bulking': 'زيادة الدرنات',
      'stage_maturation': 'النضج',
      'stage_flush': 'التبرعم',
      'stage_fruit_set': 'تكوين الثمار',
      'stage_booting': 'الطمأنة',
      'stage_grain_maturity': 'نضج الحبوب',
      'stage_establishment': 'التأسيس',
      'stage_leaf_growth': 'نمو الأوراق',
      'stage_cutting': 'القطع',
      'map_preview': 'معاينة الخريطة',
      'map_satellite_attribution': '© Mapbox © Maxar',
      'tap_map_set_location': 'اضغط على الخريطة لتحديد الموقع',
      'about': 'حول',
      'auto_filled_gps': 'يملأ تلقائيًا من GPS المزرعة',
      'api_error': 'خطأ API {code}',
      'connection_error':
          'تعذّر الاتصال. قد يكون النموذج في وضع السكون — أعد المحاولة بعد 30 ثانية.',
      'clear_all': 'مسح الكل',
      'no_notifications': 'لا توجد إشعارات',
      'time_ago_minutes': 'منذ {n} دقيقة',
      'time_ago_hours': 'منذ {h} ساعة',
      'time_ago_days': 'منذ {d} يوم',
      'task_automation': 'المهام التالية',
      'location_fetch_failed': 'فشل الحصول على الموقع',
      'year': 'السنة',
      'notifications_off': 'الإشعارات معطّلة.',
      'no_notifications_match': 'لا توجد إشعارات تطابق إعداداتك.',
      'notifications_subtitle': 'تنبيهات الطقس والسوق والمزرعة في مكان واحد',
      'notifications_empty_hint':
          'اسحب للأسفل للتحديث أو عدّل إعدادات التنبيهات من الملف الشخصي.',
      'mark_all_read': 'تعليم الكل كمقروء',
      'enable_push_prompt':
          'فعّل الإشعارات الفورية لتلقي تنبيهات الطقس والأسعار.',
      'enable': 'تفعيل',

      // ── Chat ──
      'farmbrain_ai': 'المساعد الذكي',
      'ask_anything': 'اسأل أي سؤال عن مزرعتك...',
      'new_chat': 'محادثة جديدة',
      'chat_history': 'المحادثات السابقة',
      'question_field_health': '🌿 ما هي علامات الصحة العامة للمحاصيل؟',
      'question_irrigation': '💧 ما هي أفضل ممارسات الري؟',
      'question_disease': '🦠 كيف أكتشف أمراض المحاصيل مبكرًا؟',
      'question_market': '📈 ما هي اتجاهات سوق الزراعة الحالية؟',
      'question_crop': '🌱 ما المحاصيل المناسبة للموسم القادم؟',
      'suggestion_analyze': '🌿 فحص الحقل',
      'suggestion_irrigation': '💧 جدول الري',
      'suggestion_disease': '🦠 كشف الأمراض',
      'suggestion_market': '📈 أسعار اليوم',
      'suggestion_crop': '🌱 اقتراح محصول',

      // ── Profile / Settings ──
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'dark_mode': 'الوضع الداكن',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'notifications': 'الإشعارات',
      'logout': 'تسجيل الخروج',
      'sign_out': 'تسجيل الخروج',
      'sign_out_confirm': 'تسجيل الخروج؟',
      'sign_out_message':
          'ستحتاج لتسجيل الدخول مجدداً للوصول إلى بيانات مزرعتك.',
      'edit_profile': 'تعديل الملف الشخصي',
      'change_password': 'تغيير كلمة المرور',
      'save_changes': 'حفظ التعديلات',
      'update_password': 'تحديث كلمة المرور',
      'current_password': 'كلمة المرور الحالية',
      'new_password': 'كلمة المرور الجديدة',
      'confirm_password': 'تأكيد كلمة المرور',
      'profile_updated': 'تم تحديث الملف الشخصي!',
      'appearance': 'المظهر',
      'account': 'الحساب',
      'support': 'المساعدة والدعم',
      'help_faq': 'الأسئلة الشائعة',
      'about_us': 'من نحن',
      'contact': 'اتصل بنا',
      'app_version': 'إصدار التطبيق',
      'farm_statistics': 'إحصائيات المزرعة',
      'efficiency': 'الكفاءة',
      'push_notifications': 'إشعارات فورية',
      'weather_alerts': 'تنبيهات الطقس',
      'market_price_alerts': 'تنبيهات الأسعار',
      'disease_alerts': 'تنبيهات الأمراض',

      // ── General ──
      'loading': 'جارِ التحميل...',
      'error': 'حدث خطأ',
      'retry': 'إعادة المحاولة',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'done': 'تم',
      'failed_to_load': 'تعذّر تحميل البيانات',
      'synchronizing': 'جارِ مزامنة بيانات التربة',
      'version': '@فارم تك v2.0',

      // ── Onboarding ──
      'skip': 'تخطي',
      'next': 'التالي',
      'get_started': 'البدء',
      'skip_onboarding': 'تخطي الترحيب',
      'onboarding_title_1': 'ضاعف أرباحك',
      'onboarding_subtitle_1':
          'متابعة أسعار السوق مباشرة وتوقعات ذكية لمساعدتك في البيع في الوقت المثالي.',
      'onboarding_label_veg_index': 'مؤشر الغطاء النباتي',
      'onboarding_val_veg_index': '٠.٨٢ NDVI',
      'onboarding_sub_veg_index': '+٤٪ مقارنة بالفحص الأخير',
      'onboarding_label_light_exp': 'التعرض للضوء',
      'onboarding_val_light_exp': '٩٤٪',
      'onboarding_title_2': 'تحليلات مدعومة\nبالذكاء الاصطناعي',
      'onboarding_subtitle_2':
          'ارفع صور محاصيلك للتعرف الفوري على الأمراض وتحليل العناصر الغذائية.',
      'onboarding_label_status': 'الحالة',
      'onboarding_val_status_progress': 'جارِ التحليل...',
      'onboarding_label_detection': 'التشخيص',
      'onboarding_val_confidence': 'نسبة دقة ٩٨.٤٪',
      'onboarding_title_3': 'استهلاك مثالي\nلكل قطرة',
      'onboarding_subtitle_3':
          'خطط ري ذكية تتكيف تلقائيًا مع توقعات الطقس ورطوبة التربة.',
      'onboarding_tag_smart_irrigation': 'ري ذكي',
      'onboarding_label_moisture': 'الرطوبة',
      'onboarding_val_moisture': '٦٨٪',
      'onboarding_label_forecast': 'التوقعات',
      'onboarding_val_forecast_rain': 'مطر ٢ ظهراً',
      'onboarding_feat_title_scaling': 'جدولة ذكية',
      'onboarding_feat_desc_scaling':
          'يقوم النظام بضبط كمية المياه قبل ١٢ ساعة من هطول المطر.',

      // ── Units & Measures ──
      'ppm': 'جزء في المليون',
      'ha': 'هكتار',
      'seconds_abbr': ' ث',
      'thousands_abbr': ' ألف',

      // ── Extra Dashboard ──
      'ai_reco_apply_urea':
          'ضع ١٥ كجم/هكتار من اليوريا لمزرعة {farm} للحصول على نيتروجين مثالي قبل هطول الأمطار القادم.',
      'precipitation_value': '{value} ملم',
      'wind_value': '{value} كم/س',
      'temp_value': '{value}°م',
      'soil_temp_value': '{value}°م',
      'forecast_5day': 'توقعات الأيام القادمة',
      'weather_unavailable': 'تعذّر تحميل الطقس',
      'alert': 'تنبيه',
      'monitor': 'راقب المزرعة',
      'nitrogen_n': 'نيتروجين (N)',
      'phosphorus_p': 'فوسفور (P)',
      'potassium_k': 'بوتاسيوم (K)',
      'ph_level': 'مستوى الحموضة (pH)',

      // ── Extra AI Models ──
      'parameters_count': '{count} معلمات',
      'models_live_count': '{count} نشط',
      'recommended_crop': '🌾 المحصول المقترح: {crop}',
      'yield_predicted': '📊 المحصول المتوقع: {yield} {unit}',
      'irrigation_need': '💧 الاحتياج: {need} ملم ({class})',

      // ── Extra Chat ──
      'chat_welcome':
          'مرحباً! أنا فارم برين، مساعدك الذكي في الزراعة. كيف يمكنني مساعدتك اليوم؟',
      'new_conversation_started': 'بدأت محادثة جديدة. كيف يمكنني مساعدتك؟',

      // ── Extra Market ──
      'per_ton_full': 'لكل طن',
      'quarter_format': 'الربع {quarter} {year}',

      // ── Extra Profile ──
      'profile_user_name': 'أحمد الرشيد',
      'profile_user_role': 'مدير مزرعة أول · ٨ سنوات',
      'north_region': 'المنطقة الشمالية',

      // ── Extra Support & FAQ ──
      'help_faq_heading': 'كيف يمكننا مساعدتك؟',
      'help_faq_summary':
          'إجابات سريعة لكافة أقسام تطبيق فارم تك: لوحة التحكم، المزارع، نماذج الذكاء الاصطناعي، NDVI، بيانات السوق، الإشعارات، الملف الشخصي، وإعدادات الحساب.',
      'faq_sec_ndvi': 'استخدام مؤشر NDVI',
      'faq_sec_ndvi_line1':
          'افتح صفحة "مزرعتي"، اختر حقلاً، ثم اضغط على "تشغيل الفحص" لتحديث مؤشر الغطاء النباتي.',
      'faq_sec_ndvi_line2':
          'القيم القريبة من ١.٠٠ تشير إلى نمو قوي وصحي للنبات. القيم الأقل تدل على نقص المياه، الغذاء، أو الإصابة بالآفات.',
      'faq_sec_dash': 'لوحة التحكم وحساب الأرباح',
      'faq_sec_dash_line1':
          'تلخص لوحة التحكم حالة الطقس والمزرعة والمهام وأسعار السوق والربح الإجمالي المتوقع.',
      'faq_sec_dash_line2':
          'حساب الأرباح يعتمد على آخر نتيجة لتوقع المحصول ويضربها في سعر السوق الحالي للمحصول.',
      'faq_sec_ai': 'نماذج الذكاء الاصطناعي',
      'faq_sec_ai_line1':
          'افتح صفحة "الذكاء الاصطناعي" لتشغيل نماذج التوصية بالمحاصيل، التعرف على الأمراض، وتوقعات الإنتاج والري والتسميد.',
      'faq_sec_ai_line2':
          'يقوم نموذج توقع الإنتاج بحفظ آخر نتيجة تلقائيًا لتستخدمها حاسبة الأرباح في لوحة التحكم.',
      'faq_sec_fields': 'إدارة الحقول',
      'faq_sec_fields_line1':
          'استخدم "إضافة حقل" لحفظ الاسم، المحصول، المساحة، وإحداثيات GPS للحقل.',
      'faq_sec_fields_line2':
          'اضغط على بطاقة أي حقل لعرض دورة حياة المحصول الحالية، قراءات التربة، فحص NDVI، السجل والتوصيات.',
      'faq_sec_lifecycle': 'دورة حياة المحصول',
      'faq_sec_lifecycle_line1':
          'تعرض بطاقات دورة حياة المحصول نافذة المراحل الزمنية والخطوات المطلوبة لكل نوع محصول.',
      'faq_sec_lifecycle_line2':
          'تشمل المحاصيل المدعومة القمح، الذرة، الأرز، الطماطم، البطاطس، المانجو، الذرة الرفيعة، والعلف الأخضر.',
      'faq_sec_market': 'السوق والإشعارات',
      'faq_sec_market_line1':
          'يعرض قسم السوق أسعار المحاصيل وتفاصيل التوقعات بناءً على قراءات السوق الحية.',
      'faq_sec_market_line2':
          'يتحكم الملف الشخصي في تفعيل إشعارات الجوال والتنبيهات للطقس وأسعار السوق.',
      'faq_sec_alerts': 'التنبيهات والإشعارات',
      'faq_sec_alerts_line1':
          'يمكن تفعيل أو تعطيل تنبيهات الطقس والأسعار من قسم الإعدادات بالملف الشخصي.',
      'faq_sec_alerts_line2':
          'يجب فحص الحالات الحرجة ميدانياً دائماً والتأكد منها قبل وضع أي خطة علاج كيميائي أو تسميد إضافي.',

      'privacy_heading': 'بيانات مزرعتك تبقى ملكاً لك',
      'privacy_summary':
          'يستخدم فارم تك بيانات الحساب والمزرعة والموقع فقط لتقديم خدمات المراقبة والتوصيات الزراعية وتسهيل عملك.',
      'privacy_sec_data': 'البيانات المستخدمة',
      'privacy_sec_data_line1':
          'بيانات الملف الشخصي، المزارع المحددة، المحاصيل، مواقع الحقول، وإعدادات التطبيق المفضلة.',
      'privacy_sec_data_line2':
          'يُستفاد من الإحداثيات للخرائط وتوقعات الطقس الدقيقة وتحديد حواف الحقول و NDVI.',
      'privacy_sec_protect': 'كيفية حماية البيانات',
      'privacy_sec_protect_line1':
          'تُحفظ تفضيلاتك محلياً على هاتفك لتوفير تجربة استخدام أسرع وأكثر أماناً.',
      'privacy_sec_protect_line2':
          'نحن لا نبيع بياناتك الشخصية أو بيانات مزرعتك. وندعوك لمشاركة التقارير فقط مع من تثق بهم.',
      'privacy_sec_choices': 'خياراتك وحقوقك',
      'privacy_sec_choices_line1':
          'يمكنك تعديل تفاصيل ملفك، وتخصيص تنبيهات الإشعارات، أو تسجيل الخروج بالكامل في أي وقت.',
      'privacy_sec_choices_line2':
          'يمكنك حذف أي مزرعة مخزنة عندما ترغب في إزالتها نهائياً من التطبيق.',

      'about_heading': 'ذكاء زراعي دقيق لمزرعتك',
      'about_summary':
          'يجمع فارم تك بين فحص الحقول والتحليل بالاقمار الصناعية وقراءات الطقس والأسعار وتوجيهات الذكاء الاصطناعي في واجهة واحدة.',
      'about_sec_build': 'ما نقوم ببنائه',
      'about_sec_build_line1':
          'أدوات تساعد المزارعين على فهم صحة المحاصيل، مستويات رطوبة وعناصر التربة، وجدولة الري وتغيرات السوق.',
      'about_sec_build_line2':
          'سير عمل ميداني بسيط يسهل الاستفادة من البيانات والخرائط أثناء التواجد بالأرض.',
      'about_sec_approach': 'منهجنا ورؤيتنا',
      'about_sec_approach_line1':
          'توصيات واضحة ومقاييس عملية مع وصول سريع وحرص كامل على استهلاك الموارد بكفاءة.',
      'about_sec_approach_line2':
          'مساعد الذكاء الاصطناعي مصمم لدعم اتخاذ القرار وتوفير بدائل عملية، وليس بديلاً عن المعاينة الميدانية.',

      'contact_heading': 'تحدث مع دعم فارم تك',
      'contact_summary':
          'اتصل بنا للمساعدة في الحساب، استفسارات إعداد الحقول، التعليقات الفنية، أو طلبات الشراكة.',
      'contact_sec_support': 'الدعم الفني والاتصال',
      'contact_sec_support_line1': 'البريد الإلكتروني: support@farmtec.io',
      'contact_sec_support_line2': 'الهاتف: +20 100 000 0000',
      'contact_sec_support_line3':
          'ساعات العمل: الأحد إلى الخميس، من ٩:٠٠ صباحاً وحتى ٦:٠٠ مساءً بتوقيت القاهرة.',
      'contact_sec_when': 'عند الاتصال بنا',
      'contact_sec_when_line1':
          'يرجى إرفاق اسم المزرعة والحقل والمحصول والمشكلة بالتفصيل لتسريع المساعدة.',
      'contact_sec_when_line2':
          'لمشاكل الخريطة أو NDVI يرجى إرسال إحداثيات GPS إن أمكن.',

      // ── Extra Notifications ──
      'market_update': 'تحديث الأسعار',
      'just_now': 'الآن',
      'notif_market_changed':
          'تغير سعر القمح إلى {price}/طن. يرجى مراجعة استراتيجية البيع.',
      'notif_market_up':
          'ارتفع سعر القمح بنسبة ٢.٣٪ إلى ٢٨٧.٥٠ دولار/طن. فكر في البيع هذا الأسبوع.',
      'notif_weather_adjust':
          'يُتوقع تغير ملحوظ في درجات الحرارة غداً. يرجى تعديل الري بناءً على ذلك.',
    },
  };

  String tr(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  /// Translates [key] when present; otherwise returns [fallback] unchanged.
  String trOr(String? key, String fallback) {
    if (key == null || key.isEmpty) return fallback;
    final value = tr(key);
    return value == key ? fallback : value;
  }

  String trParams(String key, Map<String, String> params) {
    var value = tr(key);
    params.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
