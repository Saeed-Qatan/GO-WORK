import 'package:gowork/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Search header widget for the dedicated Search screen.
///
/// The [TextField] inside this widget is intentionally styled to match
/// [HomeHeader]'s working search field (filled background, OutlineInputBorder,
/// TextInputAction.search) so that:
///   - The keyboard shows a search action button (not "done").
///   - The focused state is clearly visible to the user.
///   - [onSubmitted] fires when the user taps the keyboard search button.
class CustomSearchHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearchChanged;

  /// Called when the user presses the search/done button on the keyboard.
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? searchController;

  const CustomSearchHeader({
    super.key,
    this.onBackTap,
    this.onFilterTap,
    this.onSearchChanged,
    this.onSubmitted,
    this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page title
          const Text(
            'البحث عن وظائف',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 24),

          // Search Field — matches HomeHeader's working implementation.
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            onSubmitted: onSubmitted,
            // Shows a magnifier action on the keyboard so the user knows
            // that pressing it will trigger the search.
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: 'ابحث عن وظيفة أو شركة...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
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
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

<<<<<<< HEAD
          // Filter Button — aligned to start (right in RTL)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'فلترة',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
=======
          // // Filter Button — aligned to start (right in RTL)
          // Align(
          //   alignment: AlignmentDirectional.centerStart,
          //   child: InkWell(
          //     onTap: onFilterTap,
          //     borderRadius: BorderRadius.circular(12),
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 20,
          //         vertical: 12,
          //       ),
          //       decoration: BoxDecoration(
          //         color: Colors.white.withValues(alpha: 0.2),
          //         borderRadius: BorderRadius.circular(12),
          //         border: Border.all(
          //           color: Colors.white.withValues(alpha: 0.3),
          //         ),
          //       ),
          //       child: const Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(Icons.tune, color: Colors.white, size: 20),
          //           SizedBox(width: 8),
          //           Text(
          //             'فلترة',
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
>>>>>>> e-all
        ],
      ),
    );
  }
}
