import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../routing/app_router.dart';
import '../../viewmodel/settings_view_model.dart';
import '../../viewmodels/app/app_viewmodel.dart';
import '../../widget/delete_account.dart';
import '../../widget/settings/logout_button.dart';
import '../../widget/settings/settings_card.dart';
import '../../widget/settings/settings_section_header.dart';
import '../../widget/settings/settings_tile.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/theme_switcher.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(AppConstants.navSettings),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context).name == 'rtl'
                ? Icons.arrow_forward
                : Icons.arrow_back,
          ),
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
                SettingsSectionHeader(title: AppConstants.account),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.person_outline,
                      title: AppConstants.editProfileTitle,
                      onTap: () => context.push(AppRoutes.editProfile),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.lock_outline,
                      title: AppConstants.changePassword,
                      onTap: () => context.push(AppRoutes.changePassword),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SettingsSectionHeader(title: AppConstants.preferences),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.notifications_none,
                      title: AppConstants.notifications,
                      trailing: Switch(
                        value: viewModel.notificationsEnabled,
                        onChanged: viewModel.toggleNotifications,
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
                      title: AppConstants.language,
                      trailing: const LanguageSwitcher(),
                      onTap: () => context.read<AppViewModel>().changeLanguage(
                        context.read<AppViewModel>().currentLanguageCode == 'ar'
                            ? 'en'
                            : 'ar',
                      ),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: AppConstants.changeTheme,
                      trailing: const ThemeSwitcher(),
                      onTap: () => context.read<AppViewModel>().toggleTheme(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SettingsSectionHeader(title: AppConstants.general),
                SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: AppConstants.privacyPolicy,
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.article_outlined,
                      title: AppConstants.termsAndConditions,
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.help_outline,
                      title: AppConstants.helpCenter,
                      onTap: () {},
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.feedback_outlined,
                      title: AppConstants.complaintsAndSuggestions,
                      onTap: () => context.push(AppRoutes.feedback),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const LogoutButton(),
                const SizedBox(height: 20),
                const DeleteAccount(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
