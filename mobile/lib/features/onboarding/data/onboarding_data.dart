import 'package:farmtec/core/utils/assets.dart';
import 'package:farmtec/features/onboarding/data/onboarding_page_model.dart';

class OnboardingData {
  static const List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      image: Assets.onboardingFirst,
      title: 'onboarding_title_1',
      subtitle: 'onboarding_subtitle_1',
      topCard: OnboardingCardData(
        emoji: '📈',
        label: 'onboarding_label_veg_index',
        value: 'onboarding_val_veg_index',
        subtitle: 'onboarding_sub_veg_index',
      ),
      bottomCard: OnboardingCardData(
        emoji: '☀️',
        label: 'onboarding_label_light_exp',
        value: 'onboarding_val_light_exp',
      ),
    ),
    OnboardingPageModel(
      image: Assets.onboardingSecond,
      title: 'onboarding_title_2',
      subtitle: 'onboarding_subtitle_2',
      topCard: OnboardingCardData(
        emoji: '📊',
        label: 'onboarding_label_status',
        value: 'onboarding_val_status_progress',
      ),
      bottomCard: OnboardingCardData(
        emoji: '🌿',
        label: 'onboarding_label_detection',
        value: 'onboarding_val_confidence',
      ),
    ),
    OnboardingPageModel(
      image: Assets.onboardingThird,
      title: 'onboarding_title_3',
      subtitle: 'onboarding_subtitle_3',
      tagLabel: 'onboarding_tag_smart_irrigation',
      topCard: OnboardingCardData(
        emoji: '💧',
        label: 'onboarding_label_moisture',
        value: 'onboarding_val_moisture',
      ),
      bottomCard: OnboardingCardData(
        emoji: '☁️',
        label: 'onboarding_label_forecast',
        value: 'onboarding_val_forecast_rain',
      ),
      featureItem: OnboardingFeature(
        emoji: '🤖',
        title: 'onboarding_feat_title_scaling',
        description: 'onboarding_feat_desc_scaling',
      ),
    ),
  ];
}
