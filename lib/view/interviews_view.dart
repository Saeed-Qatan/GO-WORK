import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../core/constants/app_constants.dart';
import '../model/interview_model.dart';
import '../theme/app_colors.dart';
import '../viewmodel/interviews_view_model.dart';
import '../widget/common/animated_empty_state.dart';
import '../widget/common/animated_error_state.dart';
import '../widget/interviews/interview_card.dart';

class InterviewsView extends StatefulWidget {
  const InterviewsView({super.key});

  @override
  State<InterviewsView> createState() => _InterviewsViewState();
}

class _InterviewsViewState extends State<InterviewsView> {
  final List<InterviewModel> _dummyInterviews = List.generate(
    3,
    (index) => InterviewModel(
      id: 'dummy_$index',
      role: 'Backend Developer',
      company: 'Osama Company',
      date: '2026-06-30',
      time: '10:00',
      scheduledAt: DateTime(2026, 6, 30, 10),
      location: 'اربعين شقة - ابراج بن محفوظ, حضرموت, اليمن',
      status: InterviewStatus.scheduled,
      interviewType: index.isEven ? 'InPerson' : 'Online',
      meetingLink: index.isEven ? null : 'https://meet.google.com',
      notes: 'الرجاء الالتزام بزي رسمي',
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InterviewsViewModel>().fetchInterviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<InterviewsViewModel>(
        builder: (context, viewModel, _) {
          final isInitialLoading =
              viewModel.isLoading && viewModel.interviews.isEmpty;
          final interviews =
              isInitialLoading ? _dummyInterviews : viewModel.interviews;

          return Skeletonizer(
            enabled: isInitialLoading,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => viewModel.fetchInterviews(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── App Bar ──────────────────────────────────────────────
                  _buildAppBar(context, viewModel),

                  // ── Content: Error / Empty / List ────────────────────────
                  if (viewModel.errorMessage != null &&
                      viewModel.interviews.isEmpty &&
                      !isInitialLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AnimatedErrorState(
                        title: 'تعذر تحميل المقابلات',
                        message: viewModel.errorMessage!,
                        onRetry: () => viewModel.fetchInterviews(),
                      ),
                    )
                  else if (interviews.isEmpty && !isInitialLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AnimatedEmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'لا توجد مقابلات',
                        subtitle:
                            'لا يوجد لديك أي مقابلات مجدولة حالياً.\nسيتم إشعارك فور تحديد موعد جديد.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      sliver: SliverList.separated(
                        itemCount: interviews.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final interview = interviews[index];
                          return InterviewCard(interview: interview)
                              .animate(
                                key: ValueKey(
                                  'interview_${isInitialLoading}_${interview.id}',
                                ),
                              )
                              .fade(duration: 360.ms, delay: (index * 80).ms)
                              .slideY(
                                begin: 0.1,
                                duration: 360.ms,
                                delay: (index * 80).ms,
                                curve: Curves.easeOutCubic,
                              );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    InterviewsViewModel viewModel,
  ) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        AppConstants.interviewsTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'تحديث',
          onPressed:
              viewModel.isLoading ? null : () => viewModel.fetchInterviews(),
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}
