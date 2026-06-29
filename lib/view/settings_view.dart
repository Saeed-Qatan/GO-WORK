import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/widget/settings/delete_button.dart';

import '../../routing/app_router.dart';
import '../../theme/app_colors.dart';
import '../../widget/settings/settings_section_header.dart';
import '../../widget/settings/settings_card.dart';
import '../../widget/settings/settings_tile.dart';
import '../../widget/settings/logout_button.dart';
import 'policies_recommendations_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'الإعدادات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: 'الحساب'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'تعديل الملف الشخصي',
                  onTap: () {
                    context.push(AppRoutes.editProfile);
                  },
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'تغيير كلمة المرور',
                  onTap: () {
                    context.push(AppRoutes.changePassword);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: 'عام'),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.policy_outlined,
                  title: 'السياسات والتوصيات',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PoliciesRecommendationsView(),
                      ),
                    );
                  },
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'الشكاوى والاقتراحات',
                  onTap: () {
                    context.push(AppRoutes.feedback);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const LogoutButton(),
            const SizedBox(height: 20),
            const DeleteAccountButton(),
          ],
        ),
      ),
    );
  }
}
