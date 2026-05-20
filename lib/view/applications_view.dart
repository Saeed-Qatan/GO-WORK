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
  bool _isWithdrawing = false;

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
    ApplicationsViewModel viewModel,
    String applicationId,
  ) async {
    // ── Step 1: Confirmation dialog ──────────────────────────────────────────
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'تأكيد سحب الطلب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            SizedBox(width: 8),
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
          ],
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد سحب هذا الطلب؟\nلا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.right,
          style: TextStyle(height: 1.6),
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
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.cancel_outlined, color: Colors.white, size: 16),
            label: const Text(
              'نعم، سحب الطلب',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // ── Step 2: Show local loading overlay via setState ──────────────────────
    if (!mounted) return;
    setState(() => _isWithdrawing = true);

    final errorMsg = await viewModel.withdrawApplication(applicationId);

    if (!mounted) return;
    setState(() => _isWithdrawing = false);

    // ── Step 3a: Success → SnackBar ──────────────────────────────────────────
    if (errorMsg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'تم سحب الطلب بنجاح',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // ── Step 3b: Failure → styled Dialog ────────────────────────────────────
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade700,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذّر سحب الطلب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
        ),

        // ── Withdrawal loading overlay ─────────────────────────────────────
        if (_isWithdrawing)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'جارٍ سحب الطلب...',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListContent(ApplicationsViewModel viewModel) {
    if (viewModel.errorMessage != null && !viewModel.isLoading) {
      return AnimatedEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'تعذّر تحميل الطلبات',
        subtitle: viewModel.errorMessage!,
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
                  _handleWithdraw(viewModel, apps[index].id),
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
