import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import '../viewmodel/profile_view_model.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../utils/snackbar_service.dart';
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
    // Fetch profile and resume URL when this page is shown (after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProfileViewModel>();
      vm.fetchProfile();
      vm.fetchResume();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.primary,
          tooltip: 'رجوع',
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppConstants.profileTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                  isResumeLoading: viewModel.isResumeLoading,
                  onEditProfile: () {
                    context.push(AppRoutes.editProfile);
                  },
                  onViewResume: () async {
                    debugPrint('[DEBUG_RCA] "View Resume" button pressed.');
                    // Always try to fetch a fresh signed URL before opening
                    await viewModel.fetchResume();
                    final resumeUrl = viewModel.resumeUrl;
                    debugPrint('[DEBUG_RCA] viewModel.resumeUrl is: "$resumeUrl"');

                    if (resumeUrl.isEmpty) {
                      debugPrint('[DEBUG_RCA] Resume URL is empty. Warning shown.');
                      SnackbarService.showWarning(
                        viewModel.resumeError ?? 'لا يوجد سيرة ذاتية للعرض',
                      );
                      return;
                    }

                    final uri = Uri.parse(resumeUrl);
                    debugPrint('[DEBUG_RCA] Uri object parsed: $uri');

                    debugPrint('[DEBUG_RCA] Checking canLaunchUrl(uri)...');
                    final canLaunch = await canLaunchUrl(uri);
                    debugPrint('[DEBUG_RCA] canLaunchUrl(uri) result: $canLaunch');

                    if (canLaunch) {
                      debugPrint('[DEBUG_RCA] canLaunch is true, invoking launchUrl...');
                      try {
                        final success = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                        debugPrint('[DEBUG_RCA] launchUrl completed. Success: $success');
                      } catch (e, stack) {
                        debugPrint('[DEBUG_RCA] Exception during launchUrl: $e');
                        debugPrint('[DEBUG_RCA] Stack: $stack');
                        if (context.mounted) {
                          SnackbarService.showError('تعذر فتح رابط السيرة الذاتية');
                        }
                      }
                    } else {
                      debugPrint('[DEBUG_RCA] canLaunch is false! Android 11+ Package Visibility likely blocking.');
                      debugPrint('[DEBUG_RCA] Attempting direct launchUrl fallback as recommended...');
                      bool fallbackSuccess = false;
                      try {
                        fallbackSuccess = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                        debugPrint('[DEBUG_RCA] Fallback launchUrl success: $fallbackSuccess');
                      } catch (e, stack) {
                        debugPrint('[DEBUG_RCA] Fallback launchUrl threw exception: $e');
                        debugPrint('[DEBUG_RCA] Stack: $stack');
                      }

                      if (!fallbackSuccess && context.mounted) {
                        debugPrint('[DEBUG_RCA] Both canLaunchUrl and fallback launchUrl failed.');
                        SnackbarService.showError(
                          'تعذر فتح رابط السيرة الذاتية',
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
