# Flutter Performance Audit Report

## 1. Home nested list

1. File: `lib/view/home_view.dart` around the recommended jobs section.
2. Type: UI Performance / Widget Rebuild Audit.
3. Description: Recommended jobs were rendered with `ListView.builder(shrinkWrap: true)` inside a `CustomScrollView`.
4. Cause: A nested non-scrollable list forces the framework to measure the full inner list instead of lazily composing it as part of the parent sliver tree.
5. Impact:
   - Performance: extra layout work while opening/scrolling Home.
   - Memory: more job cards can be built earlier than needed.
   - UX: higher chance of scroll jank on long recommendation lists.
6. Severity: High.
7. Confidence: 100%.
8. Safe fix: Yes.
9. Current code: `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), ...)`.
10. Improved code: `SliverPadding(sliver: SliverList.builder(...))`.
11. Why it improves: Keeps a single lazy scroll pipeline and removes shrink-wrap layout cost.
12. Risk: Safe.

## 2. Search nested list

1. File: `lib/view/search_view.dart` around the results list.
2. Type: UI Performance / Widget Rebuild Audit.
3. Description: Search results were rendered through `ListView.builder(shrinkWrap: true)` inside a `SingleChildScrollView`.
4. Cause: The whole results list had to be laid out by the parent scroll view.
5. Impact:
   - Performance: expensive rebuild/layout when filters or query results update.
   - Memory: unnecessary item build pressure for longer result sets.
   - UX: search screen can stutter during result updates and scrolling.
6. Severity: High.
7. Confidence: 100%.
8. Safe fix: Yes.
9. Current code: `SingleChildScrollView` containing filters plus a shrink-wrapped results `ListView.builder`.
10. Improved code: `CustomScrollView` with a header `SliverToBoxAdapter` and results `SliverList.builder`.
11. Why it improves: Preserves the same layout order while making results lazy and scroll-native.
12. Risk: Low Risk.

## 3. Duplicate applications fetch

1. File: `lib/main.dart`, `lib/view/main_view.dart`, and `lib/view/applications_view.dart`.
2. Type: Async Operations / State Management.
3. Description: `ApplicationsViewModel` auto-fetched at provider creation, while `ApplicationsView.initState` also fetches when the screen is shown.
4. Cause: Global provider construction, tab tap handling, and screen lifecycle could trigger the same network-backed load.
5. Impact:
   - Performance: unnecessary background work.
   - Memory: extra temporary response/model allocations.
   - UX: more loading notifications and possible redundant refresh when entering the tab.
6. Severity: Medium.
7. Confidence: 100%.
8. Safe fix: Yes.
9. Current code: `ChangeNotifierProvider(create: (_) => ApplicationsViewModel())` plus a tab `onTap` fetch.
10. Improved code: `ApplicationsViewModel(autoFetch: false)` and first load handled by `ApplicationsView.initState`.
11. Why it improves: Defers the fetch to the screen lifecycle without changing repositories or API flow.
12. Risk: Low Risk.

## 4. Small network images decoded at full size

1. Files: `lib/widget/home/job_card.dart`, `lib/widget/home/home_header.dart`, `lib/widget/search/search_job_card.dart`, `lib/widget/applications/application_card.dart`, `lib/widget/notifications/notification_card.dart`, `lib/widget/profile/profile_header_card.dart`, `lib/widget/edit_profile/edit_avatar_section.dart`, `lib/view/job_details_view.dart`, `lib/view/interview_details_view.dart`.
2. Type: Image Performance / Memory Audit.
3. Description: Small avatars/logos used `Image.network` without decode size hints.
4. Cause: Flutter may decode the source image at its original dimensions even when displayed as 46-100 logical pixels.
5. Impact:
   - Performance: larger image decode work.
   - Memory: higher image cache memory usage.
   - UX: increased jank risk in scrolling cards.
6. Severity: Medium.
7. Confidence: 100%.
8. Safe fix: Yes.
9. Current code: `Image.network(url, fit: BoxFit.cover/contain, errorBuilder: ...)`.
10. Improved code: same image URLs plus `cacheWidth/cacheHeight` or `ResizeImage.resizeIfNeeded` sized for the displayed widget.
11. Why it improves: Keeps the same URL and fallback UI while reducing decoded pixel count.
12. Risk: Safe.

## 5. Notifications app bar rebuild scope

1. File: `lib/view/notifications_view.dart`.
2. Type: Widget Rebuild Audit.
3. Description: The app bar action used a full `Consumer<NotificationsViewModel>` even though it only depends on `unreadCount`.
4. Cause: Broad provider listening for a small derived value.
5. Impact:
   - Performance: unnecessary rebuilds of the action area on unrelated notification state changes.
   - Memory: negligible.
   - UX: minor, but helps keep notification interactions smoother.
6. Severity: Low.
7. Confidence: 100%.
8. Safe fix: Yes.
9. Current code: `Consumer<NotificationsViewModel>` reads `viewModel.unreadCount`.
10. Improved code: `Selector<NotificationsViewModel, int>` selects only `unreadCount`.
11. Why it improves: Narrows rebuilds to the value that actually affects the UI.
12. Risk: Safe.

## 6. Memory lifecycle review

1. Files: `lib/view/auth/*`, `lib/view/notifications_view.dart`, `lib/view/onboarding_view.dart`, `lib/viewmodel/auth/*`, `lib/viewmodel/home_view_model.dart`, `lib/viewmodel/notifications_view_model.dart`, `lib/services/push_notification_service.dart`, `lib/widget/custom_bottom_nav_bar.dart`, `lib/widget/search/filter_dropdown.dart`.
2. Type: Memory Audit.
3. Description: Controllers, timers, listeners, observers, and subscriptions were checked by static search.
4. Cause: These objects commonly leak if not disposed.
5. Impact:
   - Performance: leaks can accumulate listeners and stale callbacks.
   - Memory: retained controllers/subscriptions.
   - UX: possible duplicate events or stale UI updates.
6. Severity: Low.
7. Confidence: High Confidence.
8. Safe fix: No changes required.
9. Current code: dispose/cancel/remove patterns are present for the inspected objects.
10. Improved code: N/A.
11. Why it improves: No 100% safe leak was found in the static pass.
12. Risk: Safe.

## 7. Notifications listener registration

1. Files: `lib/main.dart`, `lib/services/push_notification_service.dart`, `lib/viewmodel/notifications_view_model.dart`, `lib/viewmodel/home_view_model.dart`.
2. Type: Notifications Audit.
3. Description: FCM handlers use singleton service state and `_handlersRegistered`; ViewModels cancel their stream subscriptions.
4. Cause: Duplicate notification registration is a common production issue.
5. Impact:
   - Performance: duplicate handlers can duplicate work.
   - Memory: duplicate listeners can retain view models.
   - UX: duplicate notification navigation or repeated toasts.
6. Severity: Low.
7. Confidence: High Confidence.
8. Safe fix: No changes required.
9. Current code: `_handlersRegistered` gate and `dispose()` cancellation are present.
10. Improved code: N/A.
11. Why it improves: Existing flow already guards the main duplicate-handler risk; networking/token flow was intentionally not changed.
12. Risk: Safe.

## 8. Dead code candidates

1. File: whole `lib/`.
2. Type: Dead Code Audit.
3. Description: No deletion was performed.
4. Cause: Routes, Provider creation, callbacks, and navigation extras can hide valid usage from text search.
5. Impact:
   - Performance: unused code can increase maintenance cost, but deleting uncertain code risks behavior.
   - Memory: no direct runtime impact confirmed.
   - UX: no direct runtime impact confirmed.
6. Severity: Low.
7. Confidence: Medium Confidence.
8. Safe fix: Manual Verification Required.
9. Current code: Possible candidates should be checked with IDE index and runtime routes before deletion.
10. Improved code: N/A.
11. Why it improves: Avoids removing code that may be reached through navigation, callbacks, or tests.
12. Risk: High Risk for deletion without manual verification.

## Not Modified By Design

- API endpoints, base URLs, DTOs, backend models, authentication, tokens, session management, Dio configuration, interceptors, API services, and networking repositories were not changed.
- No new package was added.
- No `flutter` or `dart` command was run for this implementation pass.
