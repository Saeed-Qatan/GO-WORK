import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../core/constants/app_constants.dart';
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

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => viewModel.fetchInterviews(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context, viewModel),
                if (isInitialLoading)
                  _buildLoadingList()
                else if (viewModel.errorMessage != null &&
                    viewModel.interviews.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AnimatedErrorState(
                      title: 'تعذر تحميل المقابلات',
                      message: viewModel.errorMessage!,
                      onRetry: () => viewModel.fetchInterviews(),
                    ),
                  )
                else if (viewModel.interviews.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: AnimatedEmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'لا توجد مقابلات',
                      subtitle:
                          'لا يوجد لديك أي مقابلات مجدولة حاليا.\nسيتم إشعارك فور تحديد موعد جديد.',
                    ),
                  )
                else
                  _buildInterviewsList(viewModel),
              ],
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
          onPressed: viewModel.isLoading
              ? null
              : () => viewModel.fetchInterviews(),
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildLoadingList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      sliver: SliverList.separated(
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Skeletonizer(
                enabled: true,
                child: const _InterviewSkeletonCard(),
              )
              .animate(key: ValueKey('interview_loading_$index'))
              .fade(duration: 360.ms, delay: (index * 80).ms)
              .slideY(
                begin: 0.1,
                duration: 360.ms,
                delay: (index * 80).ms,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }

  Widget _buildInterviewsList(InterviewsViewModel viewModel) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      sliver: SliverList.separated(
        itemCount: viewModel.interviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final interview = viewModel.interviews[index];
          return InterviewCard(interview: interview)
              .animate(key: ValueKey('interview_loaded_${interview.id}'))
              .fade(duration: 360.ms, delay: (index * 80).ms)
              .slideY(
                begin: 0.1,
                duration: 360.ms,
                delay: (index * 80).ms,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}

class _InterviewSkeletonCard extends StatelessWidget {
  const _InterviewSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(width: 62, height: 70, radius: 14),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(height: 18, radius: 8),
                    SizedBox(height: 10),
                    _SkeletonBox(width: 150, height: 12, radius: 6),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        _SkeletonBox(width: 86, height: 28, radius: 14),
                        SizedBox(width: 8),
                        _SkeletonBox(width: 76, height: 28, radius: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _SkeletonDetailsPanel(),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 42, radius: 12)),
              SizedBox(width: 10),
              Expanded(child: _SkeletonBox(height: 42, radius: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonDetailsPanel extends StatelessWidget {
  const _SkeletonDetailsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          _SkeletonDetailRow(width: 180),
          SizedBox(height: 12),
          _SkeletonDetailRow(width: 235),
        ],
      ),
    );
  }
}

class _SkeletonDetailRow extends StatelessWidget {
  final double width;

  const _SkeletonDetailRow({required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _SkeletonBox(width: 27, height: 27, radius: 8),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SkeletonBox(width: 58, height: 10, radius: 5),
              const SizedBox(height: 6),
              _SkeletonBox(width: width, height: 13, radius: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonBox({this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
