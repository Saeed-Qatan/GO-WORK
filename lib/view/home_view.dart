import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodel/home_view_model.dart';
import '../viewmodel/job_application_state_view_model.dart';
import '../viewmodel/notifications_view_model.dart';
import '../model/home/home_model.dart';
import '../widget/home/home_header.dart';
import '../widget/home/stat_card.dart';
import '../widget/home/job_card.dart';
import '../core/constants/app_constants.dart';
import '../widget/home/recommended_jobs_header.dart';
import '../utils/stat_ui_helper.dart';
import '../widget/common/animated_empty_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Dummy data for skeletonizer
  final List<StatModel> _dummyStats = List.generate(
    3,
    (index) =>
        StatModel(count: '00', label: 'جارٍ التحميل', type: StatType.unknown),
  );

  final List<JobModel> _dummyJobs = List.generate(
    4,
    (index) => JobModel(
      id: 'dummy_$index',
      title: 'جارٍ تحميل الوظيفة',
      company: 'جارٍ تحميل الشركة',
      companyLogoUrl: '',
      category: 'المجال',
      location: 'الموقع',
      country: 'الدولة',
      type: 'دوام كامل',
      workMode: 'عن بعد',
      minSalary: '0000',
      maxSalary: '0000',
    ),
  );

  @override
  void initState() {
    super.initState();
    // Fetch data when view inits
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<HomeViewModel>(context, listen: false).fetchHomeData();
        Provider.of<NotificationsViewModel>(
          context,
          listen: false,
        ).fetchUnreadCount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background for contrast
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final isLoading = viewModel.isLoading;
          final stats = isLoading ? _dummyStats : viewModel.stats;
          final jobs = isLoading ? _dummyJobs : viewModel.filteredJobs;

          return Skeletonizer(
            enabled: isLoading,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    if (!isLoading) {
                      await Future.wait([
                        Provider.of<HomeViewModel>(
                          context,
                          listen: false,
                        ).fetchHomeData(forceRefresh: true),
                        Provider.of<NotificationsViewModel>(
                          context,
                          listen: false,
                        ).fetchUnreadCount(),
                      ]);
                    }
                  },
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HomeHeader(),
                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(stats.length, (index) {
                            final stat = stats[index];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child:
                                    StatCard(
                                          count: stat.count,
                                          label: stat.label,
                                          icon: StatUiHelper.getIcon(stat.type),
                                          iconColor: StatUiHelper.getColor(
                                            stat.type,
                                          ),
                                        )
                                        .animate(
                                          key: ValueKey(
                                            'stat_${isLoading}_${stat.label}',
                                          ),
                                        )
                                        .fade(
                                          duration: 400.ms,
                                          delay: (index * 100).ms,
                                        )
                                        .slideY(
                                          begin: 0.2,
                                          duration: 400.ms,
                                          curve: Curves.easeOutQuad,
                                        ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const RecommendedJobsHeader(),
                      const SizedBox(height: 16),
                      // Jobs List or Error/Empty State
                      if (viewModel.errorMessage != null && !isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: AnimatedEmptyState(
                            icon: Icons.wifi_off_rounded,
                            title: 'تعذّر تحميل الوظائف',
                            subtitle: viewModel.errorMessage!,
                          ),
                        )
                      else if (jobs.isEmpty && !isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 32.0),
                          child: AnimatedEmptyState(
                            icon: Icons.work_off_outlined,
                            title: 'لا توجد وظائف مقترحة',
                            subtitle:
                                'يرجى استكمال ملفك الشخصي أو العودة لاحقاً لرؤية الوظائف المناسبة لك',
                          ),
                        ),
                      if (!isLoading &&
                          (viewModel.errorMessage != null || jobs.isEmpty))
                        const SizedBox(height: 24),
                    ],
                  ),
                ),
                if (isLoading ||
                    (viewModel.errorMessage == null && jobs.isNotEmpty))
                  Consumer<JobApplicationStateViewModel>(
                    builder: (context, appState, child) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        sliver: SliverList.builder(
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            final resolvedJob = appState.resolveJob(job);
                            return JobCard(
                                  job: resolvedJob,
                                  applyButtonText:
                                      resolvedJob.canApply == false
                                      ? 'تم التقديم'
                                      : AppConstants.applyNow,
                                )
                                .animate(
                                  key: ValueKey('job_${isLoading}_${job.id}'),
                                )
                                .fade(
                                  duration: 500.ms,
                                  delay: (index * 100).ms,
                                )
                                .slideY(
                                  begin: 0.1,
                                  duration: 500.ms,
                                  curve: Curves.easeOutQuart,
                                );
                          },
                        ),
                      );
                    },
                  ),
                if (isLoading ||
                    (viewModel.errorMessage == null && jobs.isNotEmpty))
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
