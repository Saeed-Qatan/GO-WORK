enum ApplicationStatus { sent, inReview, accepted, rejected }

class ApplicationModel {
  final String id;
  final String role;
  final String company;
  final String companyLogo;
  final String date;
  final ApplicationStatus status;

  ApplicationModel({
    required this.id,
    required this.role,
    required this.company,
    required this.companyLogo,
    required this.date,
    required this.status,
  });
}
