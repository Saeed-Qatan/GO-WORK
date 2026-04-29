import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/search_view_model.dart';
import '../widget/custom_search_header.dart';
import '../widget/filter_dropdown.dart';
import '../widget/search_job_card.dart';
import '../theme/app_colors.dart';
import '../routing/app_router.dart';

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
                                items: viewModel.isCategoriesLoading
                                    ? ['جاري التحميل...']
                                    : viewModel.categoryNames,
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
                                items: viewModel.isLocationTypesLoading
                                    ? ['جاري التحميل...']
                                    : viewModel.locationNames,
                                onChanged: viewModel.setLocation,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilterDropdown(
                                label: 'الدولة',
                                hint: 'الكل',
                                value: viewModel.selectedCountry,
                                items: viewModel.isCountriesLoading
                                    ? ['جاري التحميل...']
                                    : viewModel.countryNames,
                                onChanged: viewModel.setCountry,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilterDropdown(
                                label: 'نوع الوظيفة',
                                hint: 'الكل',
                                value: viewModel.selectedType,
                                items: viewModel.isJobTypesLoading
                                    ? ['جاري التحميل...']
                                    : viewModel.jobTypeNames,
                                onChanged: viewModel.setType,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Result Count
                        Row(
                          children: [
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                viewModel.setSortBy(value);
                              },
                              offset: const Offset(0, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'date',
                                  child: Text(
                                    'حسب التاريخ (الأحدث)',
                                    style: TextStyle(
                                      color: viewModel.sortBy == 'date'
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: viewModel.sortBy == 'date'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'salary',
                                  child: Text(
                                    'حسب الراتب (الأعلى)',
                                    style: TextStyle(
                                      color: viewModel.sortBy == 'salary'
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: viewModel.sortBy == 'salary'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.sort,
                                  color: AppColors.textSecondary,
                                ),
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
                              final jobItem = viewModel.jobs[index];
                              return SearchJobCard(
                                job: jobItem,
                                isUrgent: index == 0,
                                showBookmark: true,
                                onTap: () {
                                  context.push(AppRoutes.jobDetails, extra: jobItem);
                                },
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
