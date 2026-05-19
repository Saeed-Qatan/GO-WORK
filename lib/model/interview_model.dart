enum InterviewStatus { confirmed, waiting, scheduled }

class InterviewModel {
  final String id;
  final String role;
  final String company;
  final String? companyLogo;
  final String date;
  final String time;
  final String location; // Physical or Zoom/Online
  final String? interviewerName;
  final String? interviewerRole;
  final InterviewStatus status;
  final String? interviewType;
  final String? meetingLink;
  final String? notes;

  InterviewModel({
    required this.id,
    required this.role,
    required this.company,
    this.companyLogo,
    required this.date,
    required this.time,
    required this.location,
    this.interviewerName,
    this.interviewerRole,
    required this.status,
    this.interviewType,
    this.meetingLink,
    this.notes,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    String parsedDate = '';
    String parsedTime = '';

    if (json['interviewDate'] != null) {
      try {
        final DateTime dt = DateTime.parse(json['interviewDate']);
        parsedDate = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
        parsedTime = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        parsedDate = json['date'] ?? '';
        parsedTime = json['time'] ?? '';
      }
    } else {
      parsedDate = json['date'] ?? '';
      parsedTime = json['time'] ?? '';
    }

    return InterviewModel(
      id: json['id']?.toString() ?? '',
      role: json['jobTitle'] ?? json['role'] ?? '',
      company: json['companyName'] ?? json['company'] ?? '',
      companyLogo: json['companyLogo'],
      date: parsedDate,
      time: parsedTime,
      location: json['location'] ?? '',
      interviewerName: json['interviewerName'],
      interviewerRole: json['interviewerRole'],
      status: _parseStatus(json['status']?.toString()),
      interviewType: json['interviewType'],
      meetingLink: json['meetingLink'],
      notes: json['notes'],
    );
  }

  static InterviewStatus _parseStatus(String? statusString) {
    if (statusString == null) return InterviewStatus.waiting;
    final s = statusString.toLowerCase();
    if (s == 'confirmed') return InterviewStatus.confirmed;
    if (s == 'scheduled') return InterviewStatus.scheduled;
    if (s == 'waiting' || s == 'pending') return InterviewStatus.waiting;
    return InterviewStatus.waiting;
  }
}
