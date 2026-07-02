class OnboardingCardData {
  final String label;
  final String value;
  final String? subtitle;
  final String emoji;

  const OnboardingCardData({
    required this.label,
    required this.value,
    this.subtitle,
    required this.emoji,
  });
}

class OnboardingFeature {
  final String emoji;
  final String title;
  final String description;

  const OnboardingFeature({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class OnboardingPageModel {
  final String image;
  final String title;
  final String subtitle;
  final String? tagLabel;
  final OnboardingCardData topCard;
  final OnboardingCardData bottomCard;
  final OnboardingFeature? featureItem;

  const OnboardingPageModel({
    required this.image,
    required this.title,
    required this.subtitle,
    this.tagLabel,
    required this.topCard,
    required this.bottomCard,
    this.featureItem,
  });
}
