import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import '../viewmodel/profile_view_model.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../widget/profile/profile_header_card.dart';
import '../widget/profile/profile_action_buttons.dart';
import '../widget/profile/profile_contact_info_card.dart';
import '../widget/profile/profile_skills_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // Fetch profile only when this page is actually shown (after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppConstants.profileTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchProfile(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.profile == null) {
            return const Center(child: Text('لا يوجد بيانات للملف الشخصي'));
          }

          final profile = viewModel.profile!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // ── Profile Header Card ──
                ProfileHeaderCard(profile: profile),
                const SizedBox(height: 20),

                // ── Action Buttons ──
                ProfileActionButtons(
                  onEditProfile: () {
                    context.push(AppRoutes.editProfile);
                  },
                  onDownloadCV: () async {
                    final cvUrl = profile.cvUrl;
                    if (cvUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لا يوجد سيرة ذاتية للعرض'),
                        ),
                      );
                      return;
                    }
                    final uri = Uri.parse(cvUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تعذر فتح رابط السيرة الذاتية'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),

                // ── Contact Info Card ──
                ProfileContactInfoCard(
                  email: profile.email,
                  phone: profile.phone,
                ),
                const SizedBox(height: 20),

                // ── Skills Card ──
                ProfileSkillsCard(skills: profile.skills),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
