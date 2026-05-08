import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodel/home_view_model.dart';
import '../model/home_model.dart';
import '../widget/home/home_header.dart';
import '../widget/home/stat_card.dart';
import '../widget/home/job_card.dart';
import '../core/constants/app_constants.dart';
import '../widget/home/home_filters.dart';
import '../utils/stat_ui_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Dummy data for skeletonizer
  final List<StatModel> _dummyStats = List.generate(
    3,
    (index) => StatModel(count: '00', label: 'Loading...', type: StatType.unknown),
  );

  final List<JobModel> _dummyJobs = List.generate(
    4,
    (index) => JobModel(
      id: 'dummy_$index',
      title: 'Loading Job Title',
      company: 'Loading Company',
      companyLogoUrl: '',
      category: 'Category',
      location: 'Location',
      country: 'Country',
      type: 'Full-Time',
      workMode: 'Remote',
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
          final jobs = isLoading ? _dummyJobs : viewModel.jobs;

          return Skeletonizer(
            enabled: isLoading,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeHeader(),
                  // Stats Row
                  Transform.translate(
                    offset: const Offset(0, -40), // Pull up to overlap header
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(stats.length, (index) {
                          final stat = stats[index];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: StatCard(
                                count: stat.count,
                                label: stat.label,
                                icon: StatUiHelper.getIcon(stat.type),
                                iconColor: StatUiHelper.getColor(stat.type),
                              )
                                  .animate(key: ValueKey('stat_\${isLoading}_\${stat.label}'))
                                  .fade(duration: 400.ms, delay: (index * 100).ms)
                                  .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOutQuad),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  // Filters Row
                  const HomeFilters(),
                  const SizedBox(height: 16),
                  // Jobs List
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return JobCard(
                        job: job,
                        applyButtonText: AppConstants.applyNow,
                      )
                          .animate(key: ValueKey('job_\${isLoading}_\${job.id}'))
                          .fade(duration: 500.ms, delay: (index * 100).ms)
                          .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutQuart);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
