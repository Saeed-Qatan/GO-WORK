import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../model/interview_model.dart';
import '../viewmodel/interviews_view_model.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../widget/interviews/interview_card.dart';
import '../widget/common/animated_empty_state.dart';

class InterviewsView extends StatefulWidget {
  const InterviewsView({super.key});

  @override
  State<InterviewsView> createState() => _InterviewsViewState();
}

class _InterviewsViewState extends State<InterviewsView> {
  /// Dummy data used exclusively by [Skeletonizer] to paint the loading
  /// skeleton that mirrors the real [InterviewCard] layout.
  final List<InterviewModel> _dummyInterviews = List.generate(
    3,
    (index) => InterviewModel(
      id: 'dummy_$index',
      role: 'Loading Role Title',
      company: 'Loading Company',
      companyLogo: '',
      date: '00/00/0000',
      time: '00:00',
      location: 'Loading location...',
      interviewerName: 'Loading Name',
      interviewerRole: 'Loading Role',
      status: InterviewStatus.waiting,
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<InterviewsViewModel>(context, listen: false).fetchInterviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppConstants.interviewsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: AppColors.textPrimary,
              ),
              onPressed: () {},
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Consumer<InterviewsViewModel>(
        builder: (context, viewModel, child) {
          final isLoading = viewModel.isLoading;
          final interviews = isLoading
              ? _dummyInterviews
              : viewModel.interviews;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8,
                ),
                child: Text(
                  '${viewModel.interviews.length} ${AppConstants.interviewsCountSuffix}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Skeletonizer(
                  enabled: isLoading,
                  child: _buildContent(viewModel, interviews, isLoading),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    InterviewsViewModel viewModel,
    List<InterviewModel> interviews,
    bool isLoading,
  ) {
    // Empty state with entrance animation
    if (interviews.isEmpty && !isLoading) {
      return const AnimatedEmptyState(
        icon: Icons.event_busy_rounded,
        title: 'لا توجد مقابلات',
        subtitle:
            'لا يوجد لديك أي مقابلات مجدولة حالياً.\nسيتم إشعارك فور تحديد موعد جديد.',
      );
    }

    // Staggered list — each card slides in from the right (RTL-friendly)
    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: interviews.length,
      itemBuilder: (context, index) {
        return InterviewCard(interview: interviews[index])
            .animate(
              key: ValueKey('interview_${isLoading}_${interviews[index].id}'),
            )
            .fade(duration: 450.ms, delay: (index * 120).ms)
            .slideX(
              begin: 0.12,
              duration: 450.ms,
              delay: (index * 120).ms,
              curve: Curves.easeOutQuart,
            );
      },
    );
  }
}
