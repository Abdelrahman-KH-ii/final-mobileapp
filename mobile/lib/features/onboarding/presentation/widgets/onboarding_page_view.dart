import 'package:farmtec/features/onboarding/data/onboarding_data.dart';
import 'package:farmtec/features/onboarding/presentation/widgets/page_view_item.dart';
import 'package:flutter/material.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: OnboardingData.pages.length,
      itemBuilder: (context, index) {
        return PageViewItem(model: OnboardingData.pages[index]);
      },
    );
  }
}
