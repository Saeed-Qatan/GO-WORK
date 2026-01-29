import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/applications/applications_view_model.dart';
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
    // Fetch data on init
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
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: viewModel.applications.length,
                                itemBuilder: (context, index) {
                                  return ApplicationCard(
                                    application: viewModel.applications[index],
                                  );
                                },
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
}
