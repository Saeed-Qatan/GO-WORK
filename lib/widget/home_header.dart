import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with Gradient
        Container(
          height: 240, // Increased height slightly for better spacing
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF448AFF), // Lighter Blue
                AppColors.primary, // Deep Blue
              ],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
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

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              32,
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
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: AppColors.primary),
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
                            AppConstants.homeWelcome,
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

                    // Settings Button (Left in RTL)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.2,
                        ), // Glassy effect
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),
        ),
      ],
    );
  }
}
