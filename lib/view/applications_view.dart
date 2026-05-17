import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodel/applications_view_model.dart';
import '../model/application_model.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../widget/applications/application_card.dart';
import '../widget/applications/applications_header.dart';
import '../widget/common/animated_empty_state.dart';

class ApplicationsView extends StatefulWidget {
  const ApplicationsView({super.key});

  @override
  State<ApplicationsView> createState() => _ApplicationsViewState();
}

class _ApplicationsViewState extends State<ApplicationsView> {
  final List<ApplicationModel> _dummyApplications = List.generate(
    4,
    (index) => ApplicationModel(
      id: 'dummy_$index',
      role: 'Loading Role...',
      company: 'Loading Company...',
      companyLogo: '',
      date: '00/00/0000',
      statusName: 'Loading...',
      status: ApplicationStatus.sent, jobId: '',
    ),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationsViewModel>().fetchApplications();
    });
  }

  void _handleWithdraw(
    BuildContext context,
    ApplicationsViewModel viewModel,
    String applicationId,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تأكيد سحب الطلب',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد سحب هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'تراجع',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'نعم، سحب الطلب',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
    }

    final success = await viewModel.withdrawApplication(applicationId);

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'تم سحب الطلب بنجاح'
                : viewModel.errorMessage ?? 'فشل سحب الطلب',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<ApplicationsViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              ApplicationsHeader(viewModel: viewModel),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Add filter button/icon on the left
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${viewModel.applications.length} ${AppConstants.applicationsCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Skeletonizer(
                          enabled: viewModel.isLoading,
                          child: _buildListContent(viewModel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListContent(ApplicationsViewModel viewModel) {
    if (viewModel.errorMessage != null && !viewModel.isLoading) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final apps = viewModel.isLoading
        ? _dummyApplications
        : viewModel.applications;

    if (apps.isEmpty && !viewModel.isLoading) {
      return const AnimatedEmptyState(
        icon: Icons.folder_open_rounded,
        title: 'لا توجد طلبات',
        subtitle:
            'لم تقم بتقديم أي طلبات توظيف حتى الآن.\nتصفح الوظائف المتاحة وابدأ مسيرتك المهنية!',
      );
    }

    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return ApplicationCard(
              application: apps[index],
              onWithdraw: () =>
                  _handleWithdraw(context, viewModel, apps[index].id),
            )
            .animate(
              key: ValueKey('app_\${viewModel.isLoading}_\${apps[index].id}'),
            )
            .fade(duration: 400.ms, delay: (index * 100).ms)
            .slideX(begin: 0.1, duration: 400.ms);
      },
    );
  }
}
