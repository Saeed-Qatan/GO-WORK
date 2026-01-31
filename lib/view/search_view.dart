import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/search_view_model.dart';
import '../widget/custom_search_header.dart';
import '../widget/filter_dropdown.dart';
import '../widget/search_job_card.dart';
import '../theme/app_colors.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Consumer<SearchViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Header
                CustomSearchHeader(
                  searchController: _searchController,
                  onSearchChanged: viewModel.onSearchChanged,
                  onFilterTap: () {
                    // Logic to show advanced filters or bottom sheet if needed
                    // For now, toggle visibility or scroll to filters
                  },
                ),

                // Filters & Results
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Filters Row
                        Row(
                          children: [
                            Expanded(
                              child: FilterDropdown(
                                label: 'المجال',
                                hint: 'جميع المجالات',
                                value: viewModel.selectedCategory,
                                items: const [
                                  'جميع المجالات',
                                  'تطوير برمجيات',
                                  'Data',
                                  'Design',
                                  'Mobile Dev',
                                ],
                                onChanged: viewModel.setCategory,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilterDropdown(
                                label: 'مكان العمل',
                                hint: 'الكل',
                                value: viewModel.selectedLocation,
                                items: const [
                                  'الكل',
                                  'الرياض',
                                  'جده',
                                  'الدمام',
                                  'عن بعد',
                                ],
                                onChanged: viewModel.setLocation,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilterDropdown(
                                label: 'نوع الوظيفة',
                                hint: 'الكل',
                                value: viewModel.selectedType,
                                items: const [
                                  'الكل',
                                  'دوام كامل',
                                  'عقد',
                                  'بارت تايم',
                                ],
                                onChanged: viewModel.setType,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Result Count
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.sort,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'تم العثور على ${viewModel.jobs.length} وظيفة',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Results List
                        if (viewModel.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (viewModel.jobs.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'لا توجد وظائف مطابقة للبحث',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: viewModel.jobs.length,
                            itemBuilder: (context, index) {
                              return SearchJobCard(
                                job: viewModel.jobs[index],
                                isUrgent: index == 0,
                                showBookmark: true,
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
