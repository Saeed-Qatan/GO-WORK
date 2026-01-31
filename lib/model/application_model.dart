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

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id']?.toString() ?? '',
      role: json['role'] ?? '',
      company: json['company'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      date: json['date'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ApplicationStatus.sent,
      ),
    );
  }
}
