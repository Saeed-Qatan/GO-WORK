import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/interviews_view_model.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
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
              onPressed: () {
                // Main layout handles nav usually, but if this needs to go back to "Home" tab explicitly?
                // Or maybe no action if it's top level. Icon is "arrow_forward" in screenshot (RTL back).
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false, // Custom leading/actions
      ),
      backgroundColor: Colors.white,
      body: Consumer<InterviewsViewModel>(
        builder: (context, viewModel, child) {
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
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: viewModel.interviews.length,
                        itemBuilder: (context, index) {
                          return InterviewCard(
                            interview: viewModel.interviews[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
