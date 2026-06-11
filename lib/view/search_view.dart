import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/search_view_model.dart';
import '../viewmodel/job_application_state_view_model.dart';
import '../widget/search/custom_search_header.dart';
import '../widget/search/filter_dropdown.dart';
import '../widget/search/search_job_card.dart';
import '../theme/app_colors.dart';
import '../routing/app_router.dart';
import '../widget/common/animated_empty_state.dart';
import '../model/search/filter_option.dart';

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
      // Builder separates the provider scope from the consumer scope so that
      // CustomSearchHeader (and its TextField) is NOT inside Consumer and
      // therefore does NOT rebuild on every notifyListeners() call. Without
      // this, each keystroke triggers _isLoading = true → notifyListeners() →
      // Consumer rebuild → TextField recreated → focus lost.
      child: Builder(
        builder: (context) {
          // Read once — the callback ref is stable and causes no rebuilds.
          final viewModel = context.read<SearchViewModel>();

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: Column(
              children: [
                // Header lives OUTSIDE Consumer — never rebuilt during search.
                CustomSearchHeader(
                  searchController: _searchController,
                  onSearchChanged: viewModel.onSearchChanged,
                  onSubmitted: viewModel.onSearchChanged,
                  onFilterTap: () {
                    // Logic to show advanced filters or bottom sheet if needed
                  },
                ),

                // Only the results / filters section rebuilds on ViewModel changes.
                Expanded(
                  child: Consumer<SearchViewModel>(
                    builder: (context, viewModel, child) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),

                            // Filters Row — Category
                            Row(
                              children: [
                                Expanded(
                                  child: FilterDropdown(
                                    label: 'المجال',
                                    hint: 'جميع المجالات',
                                    value: viewModel.selectedCategory,
                                    items: viewModel.isCategoriesLoading
                                        ? [
                                            FilterOption(
                                              label: 'جاري التحميل...',
                                              rawValue: '',
                                            ),
                                          ]
                                        : viewModel.categoryOptions,
                                    onChanged: viewModel.setCategory,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Filters Row — Location type & Country
                            Row(
                              children: [
                                Expanded(
                                  child: FilterDropdown(
                                    label: 'مكان العمل',
                                    hint: 'الكل',
                                    value: viewModel.selectedLocation,
                                    items: viewModel.isLocationTypesLoading
                                        ? [
                                            FilterOption(
                                              label: 'جاري التحميل...',
                                              rawValue: '',
                                            ),
                                          ]
                                        : viewModel.locationOptions,
                                    onChanged: viewModel.setLocation,
                                    showSearch: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FilterDropdown(
                                    label: 'الدولة',
                                    hint: 'الكل',
                                    value: viewModel.selectedCountry,
                                    items: viewModel.isCountriesLoading
                                        ? [
                                            FilterOption(
                                              label: 'جاري التحميل...',
                                              rawValue: '',
                                            ),
                                          ]
                                        : viewModel.countryOptions,
                                    onChanged: viewModel.setCountry,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Filters Row — Job type
                            Row(
                              children: [
                                Expanded(
                                  child: FilterDropdown(
                                    label: 'نوع الوظيفة',
                                    hint: 'الكل',
                                    value: viewModel.selectedType,
                                    items: viewModel.isJobTypesLoading
                                        ? [
                                            FilterOption(
                                              label: 'جاري التحميل...',
                                              rawValue: '',
                                            ),
                                          ]
                                        : viewModel.jobTypeOptions,
                                    onChanged: viewModel.setType,
                                    showSearch: false,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Sort & Result Count Row
                            Row(
                              children: [
                                PopupMenuButton<String>(
                                  onSelected: viewModel.setSortBy,
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
                                          fontWeight:
                                              viewModel.sortBy == 'date'
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
                                          fontWeight:
                                              viewModel.sortBy == 'salary'
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
                                      border:
                                          Border.all(color: AppColors.border),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
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
                            else if (viewModel.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 64.0),
                                child: AnimatedEmptyState(
                                  icon: Icons.error_outline_rounded,
                                  title: 'حدث خطأ',
                                  subtitle: viewModel.errorMessage!,
                                ),
                              )
                            else if (viewModel.jobs.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 64.0),
                                child: AnimatedEmptyState(
                                  icon: Icons.search_off_rounded,
                                  title: 'لا توجد نتائج',
                                  subtitle:
                                      'لم نعثر على وظائف تطابق معايير البحث الخاصة بك.\nجرب تغيير الفلاتر أو كلمات البحث.',
                                ),
                              )
                            else
                              Consumer<JobApplicationStateViewModel>(
                                builder: (context, appState, child) {
                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: viewModel.jobs.length,
                                    itemBuilder: (context, index) {
                                      final jobItem = viewModel.jobs[index];
                                      final resolvedJob =
                                          appState.resolveJob(jobItem);
                                      return SearchJobCard(
                                        job: resolvedJob,
                                        isUrgent: index == 0,
                                        onTap: () {
                                          context.push(
                                            AppRoutes.jobDetails,
                                            extra: resolvedJob,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
