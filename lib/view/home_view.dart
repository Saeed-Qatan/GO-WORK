import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_view_model.dart';
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
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                // Stats Row
                const SizedBox(height: 19.5),

                Transform.translate(
                  offset: const Offset(0, -40), // Pull up to overlap header
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: viewModel.stats
                          .map(
                            (stat) => StatCard(
                              count: stat.count,
                              label: stat.label,
                              icon: StatUiHelper.getIcon(stat.type),
                              iconColor: StatUiHelper.getColor(stat.type),
                            ),
                          )
                          .toList(),
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
                  itemCount: viewModel.jobs.length,
                  itemBuilder: (context, index) {
                    return JobCard(
                      job: viewModel.jobs[index],
                      applyButtonText: AppConstants.applyNow,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
