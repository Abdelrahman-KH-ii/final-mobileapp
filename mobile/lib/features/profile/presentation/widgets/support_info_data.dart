import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum SupportInfoPage { helpFaq, privacyPolicy, aboutUs, contact }

class SupportInfoSection {
  final String title;
  final List<String> lines;

  const SupportInfoSection(this.title, this.lines);
}

class SupportInfoData {
  final String title;
  final String heading;
  final String summary;
  final IconData icon;
  final Color color;
  final List<SupportInfoSection> sections;

  const SupportInfoData({
    required this.title,
    required this.heading,
    required this.summary,
    required this.icon,
    required this.color,
    required this.sections,
  });

  factory SupportInfoData.forPage(SupportInfoPage page, AppLocalizations l) {
    switch (page) {
      case SupportInfoPage.helpFaq:
        return SupportInfoData(
          title: l.tr('help_faq'),
          heading: l.tr('help_faq_heading'),
          summary: l.tr('help_faq_summary'),
          icon: Icons.help_outline_rounded,
          color: const Color(0xFF2196F3),
          sections: [
            SupportInfoSection(l.tr('faq_sec_ndvi'), [
              l.tr('faq_sec_ndvi_line1'),
              l.tr('faq_sec_ndvi_line2'),
            ]),
            SupportInfoSection(l.tr('faq_sec_dash'), [
              l.tr('faq_sec_dash_line1'),
              l.tr('faq_sec_dash_line2'),
            ]),
            SupportInfoSection(l.tr('faq_sec_ai'), [
              l.tr('faq_sec_ai_line1'),
              l.tr('faq_sec_ai_line2'),
            ]),
            SupportInfoSection(l.tr('faq_sec_fields'), [
              l.tr('faq_sec_fields_line1'),
              l.tr('faq_sec_fields_line2'),
            ]),
            SupportInfoSection(l.tr('faq_sec_lifecycle'), [
              l.tr('faq_sec_lifecycle_line1'),
              l.tr('faq_sec_lifecycle_line2'),
            ]),
            SupportInfoSection(l.tr('faq_sec_market'), [
              l.tr('faq_sec_market_line1'),
              l.tr('faq_sec_market_line2'),
            ]),
            SupportInfoSection(l.tr('faq_sec_alerts'), [
              l.tr('faq_sec_alerts_line1'),
              l.tr('faq_sec_alerts_line2'),
            ]),
          ],
        );
      case SupportInfoPage.privacyPolicy:
        return SupportInfoData(
          title: l.tr('privacy_policy'),
          heading: l.tr('privacy_heading'),
          summary: l.tr('privacy_summary'),
          icon: Icons.privacy_tip_outlined,
          color: const Color(0xFF7C3AED),
          sections: [
            SupportInfoSection(l.tr('privacy_sec_data'), [
              l.tr('privacy_sec_data_line1'),
              l.tr('privacy_sec_data_line2'),
            ]),
            SupportInfoSection(l.tr('privacy_sec_protect'), [
              l.tr('privacy_sec_protect_line1'),
              l.tr('privacy_sec_protect_line2'),
            ]),
            SupportInfoSection(l.tr('privacy_sec_choices'), [
              l.tr('privacy_sec_choices_line1'),
              l.tr('privacy_sec_choices_line2'),
            ]),
          ],
        );
      case SupportInfoPage.aboutUs:
        return SupportInfoData(
          title: l.tr('about_us'),
          heading: l.tr('about_heading'),
          summary: l.tr('about_summary'),
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF1B8F3A),
          sections: [
            SupportInfoSection(l.tr('about_sec_build'), [
              l.tr('about_sec_build_line1'),
              l.tr('about_sec_build_line2'),
            ]),
            SupportInfoSection(l.tr('about_sec_approach'), [
              l.tr('about_sec_approach_line1'),
              l.tr('about_sec_approach_line2'),
            ]),
          ],
        );
      case SupportInfoPage.contact:
        return SupportInfoData(
          title: l.tr('contact'),
          heading: l.tr('contact_heading'),
          summary: l.tr('contact_summary'),
          icon: Icons.contact_support_outlined,
          color: const Color(0xFFFF9800),
          sections: [
            SupportInfoSection(l.tr('contact_sec_support'), [
              l.tr('contact_sec_support_line1'),
              l.tr('contact_sec_support_line2'),
              l.tr('contact_sec_support_line3'),
            ]),
            SupportInfoSection(l.tr('contact_sec_when'), [
              l.tr('contact_sec_when_line1'),
              l.tr('contact_sec_when_line2'),
            ]),
          ],
        );
    }
  }
}
