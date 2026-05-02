import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/applications_view_model.dart';
import '../theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../widget/application_card.dart';
import '../widget/applications_header.dart';

class ApplicationsView extends StatefulWidget {
  const ApplicationsView({super.key});

  @override
  State<ApplicationsView> createState() => _ApplicationsViewState();
}

class _ApplicationsViewState extends State<ApplicationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationsViewModel>().fetchApplications();
    });
  }

  void _handleWithdraw(BuildContext context, ApplicationsViewModel viewModel, String applicationId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأكيد سحب الطلب', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد أنك تريد سحب هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('نعم، سحب الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          content: Text(success ? 'تم سحب الطلب بنجاح' : viewModel.errorMessage ?? 'فشل سحب الطلب'),
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
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.tune, color: Colors.grey),
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
                        child: _buildListContent(viewModel),
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
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (viewModel.applications.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد طلبات لعرضها',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.applications.length,
      itemBuilder: (context, index) {
        return ApplicationCard(
          application: viewModel.applications[index],
          onWithdraw: () => _handleWithdraw(context, viewModel, viewModel.applications[index].id),
        );
      },
    );
  }
}
