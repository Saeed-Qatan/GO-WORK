import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../viewmodel/applications_view_model.dart';
import '../viewmodel/home_view_model.dart';
import '../viewmodel/interviews_view_model.dart';
import '../viewmodel/job_application_state_view_model.dart';
import '../viewmodel/job_details_view_model.dart';
import '../viewmodel/notifications_view_model.dart';
import '../viewmodel/profile_view_model.dart';

void resetSessionState(BuildContext context) {
  context.read<HomeViewModel>().resetSessionState(notify: false);
  context.read<JobApplicationStateViewModel>().resetSessionState(notify: false);
  context.read<ApplicationsViewModel>().resetSessionState(notify: false);
  context.read<InterviewsViewModel>().resetSessionState(notify: false);
  context.read<ProfileViewModel>().resetSessionState(notify: false);
  context.read<JobDetailsViewModel>().resetSessionState(notify: false);
  context.read<NotificationsViewModel>().resetSessionState(notify: false);
}
