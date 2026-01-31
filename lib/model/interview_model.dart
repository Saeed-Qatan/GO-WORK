enum InterviewStatus { confirmed, waiting, scheduled }

class InterviewModel {
  final String id;
  final String role;
  final String company;
  final String companyLogo;
  final String date;
  final String time;
  final String location; // Physical or Zoom/Online
  final String interviewerName;
  final String interviewerRole;
  final InterviewStatus status;

  InterviewModel({
    required this.id,
    required this.role,
    required this.company,
    required this.companyLogo,
    required this.date,
    required this.time,
    required this.location,
    required this.interviewerName,
    required this.interviewerRole,
    required this.status,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      id: json['id']?.toString() ?? '',
      role: json['role'] ?? '',
      company: json['company'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      interviewerName: json['interviewerName'] ?? '',
      interviewerRole: json['interviewerRole'] ?? '',
      status: InterviewStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => InterviewStatus.waiting,
      ),
    );
  }
}
