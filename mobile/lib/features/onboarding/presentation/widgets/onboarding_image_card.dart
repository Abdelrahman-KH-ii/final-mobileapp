import 'package:farmtec/features/onboarding/data/onboarding_page_model.dart';
import 'package:farmtec/features/onboarding/presentation/widgets/onboarding_stat_card.dart';
import 'package:flutter/material.dart';

class OnboardingImageCard extends StatelessWidget {
  const OnboardingImageCard({super.key, required this.model});

  final OnboardingPageModel model;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                model.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: const Color(0xFF1B3A1A),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: OnboardingStatCard(data: model.topCard),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: OnboardingStatCard(data: model.bottomCard, highlight: true),
            ),
          ],
        ),
      ),
    );
  }
}
