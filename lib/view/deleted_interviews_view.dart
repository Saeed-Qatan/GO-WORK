import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../viewmodel/interviews_view_model.dart';
import '../widget/common/animated_empty_state.dart';
import '../widget/interviews/interview_card.dart';

class DeletedInterviewsView extends StatelessWidget {
  const DeletedInterviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color surface = Color(0xFFF5F5F5); // Standard app background
    const Color onSurface = AppColors.textPrimary;
    const Color outlineVariant = AppColors.border;

    return Scaffold(
      backgroundColor: surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              elevation: 0,
              centerTitle: true,
              shape: const Border(
                bottom: BorderSide(color: outlineVariant, width: 0.2),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              title: Text(
                'المقابلات المؤرشفة / المحذوفة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<InterviewsViewModel>(
        builder: (context, viewModel, _) {
          final deletedList = viewModel.deletedInterviews;

          if (deletedList.isEmpty) {
            return const Center(
              child: AnimatedEmptyState(
                icon: Icons.delete_sweep_outlined,
                title: 'قائمة نظيفة',
                subtitle: 'لا توجد مقابلات محذوفة أو مؤرشفة حالياً.',
              ),
            );
          }

          return ListView.separated(
            cacheExtent: 650,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + kToolbarHeight + 24,
              left: 20,
              right: 20,
              bottom: 40 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: deletedList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final interview = deletedList[index];
              return Stack(
                    key: ValueKey(interview.id),
                    children: [
                      InterviewCard(interview: interview),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.restore_from_trash_rounded,
                              color: AppColors.primary,
                            ),
                            tooltip: 'استعادة المقابلة',
                            onPressed: () async {
                              await viewModel.restoreInterview(interview.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'تم استعادة المقابلة إلى القائمة الرئيسية بنجاح',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fade(duration: 350.ms, delay: (index * 50).ms)
                  .slideY(
                    begin: 0.1,
                    curve: Curves.easeOutCubic,
                    duration: 350.ms,
                    delay: (index * 50).ms,
                  );
            },
          );
        },
      ),
    );
  }
}
