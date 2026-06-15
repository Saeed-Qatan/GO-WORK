import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import '../../viewmodel/home_view_model.dart';
import '../../viewmodel/profile_view_model.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widget/notifications/notification_badge.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeViewModel, ProfileViewModel>(
      builder: (context, homeViewModel, profileViewModel, child) {
        final profile = profileViewModel.profile;
        final displayName = profile?.name.trim().isNotEmpty == true
            ? profile!.name.trim()
            : homeViewModel.userName.trim();
        final profileImage = profile?.avatarUrl.trim().isNotEmpty == true
            ? profile!.avatarUrl.trim()
            : homeViewModel.userProfileImage.trim();

        return Stack(
          children: [
            // Background with Gradient
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF448AFF), // Lighter Blue
                    AppColors.primary, // Deep Blue
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
            ),
            // Decorative Circles (to match the "rich" look)
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 18,
              left: 28,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  28,
                ), // Added bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Profile (Right), Text (Center), Settings (Left)
                    // In RTL: Row starts from Right.
                    // So Order: Profile -> Expanded(Text) -> Settings
                    Row(
                      children: [
                        // Profile Avatar (Right in RTL)
                        GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.profile);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              backgroundImage: profileImage.isNotEmpty
                                  ? ResizeImage.resizeIfNeeded(
                                      144,
                                      144,
                                      NetworkImage(profileImage),
                                    )
                                  : null,
                              child: profileImage.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Welcome Text (Center)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align to Start (Right in RTL)
                            children: [
                              Text(
                                displayName.isNotEmpty
                                    ? '${AppConstants.homeWelcome}، $displayName'
                                    : AppConstants.homeWelcome,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppConstants.homeSubtitle,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),

                        // Notification Badge (Left in RTL)
                        NotificationBadge(
                          onTap: () {
                            context.push(AppRoutes.notifications);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      onChanged: homeViewModel.onSearchChanged,
                      textInputAction: TextInputAction.search,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: AppConstants.searchHint,
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
