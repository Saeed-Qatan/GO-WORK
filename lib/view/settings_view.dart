import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../routing/app_router.dart';
import '../../theme/app_colors.dart';
import '../../viewmodel/settings_view_model.dart';
import '../../widget/settings/settings_section_header.dart';
import '../../widget/settings/settings_card.dart';
import '../../widget/settings/settings_tile.dart';
import '../../widget/settings/logout_button.dart';

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
        title: Text(
          'الإعدادات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
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
                        // Navigate to change password
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SettingsSectionHeader(title: 'التفضيلات'),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.notifications_none,
                      title: 'الإشعارات',
                      trailing: Switch(
                        value: viewModel.notificationsEnabled,
                        onChanged: (val) {
                          viewModel.toggleNotifications(val);
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                      onTap: () {
                        viewModel.toggleNotifications(
                          !viewModel.notificationsEnabled,
                        );
                      },
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.language,
                      title: 'اللغة',
                      trailing: Text(
                        viewModel.currentLanguage,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      onTap: () {
                        // Example toggle for language (expand with a dialog later if needed)
                        if (viewModel.currentLanguage == 'العربية') {
                          viewModel.changeLanguage('English');
                        } else {
                          viewModel.changeLanguage('العربية');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SettingsSectionHeader(title: 'عام'),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'سياسة الخصوصية',
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.article_outlined,
                      title: 'الشروط والأحكام',
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.help_outline,
                      title: 'مركز المساعدة',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const LogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
