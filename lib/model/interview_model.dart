import '../utils/timezone_utils.dart';

enum InterviewStatus {
  scheduled,
  completed,
  cancelled,
  confirmed,
  missingInterview,
  withdrawn,
}

class InterviewModel {
  final String id;
  final String role;
  final String company;
  final String? companyLogo;
  final String date;
  final String time;
  final DateTime? scheduledAt;
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
    this.scheduledAt,
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
    DateTime? scheduledAt;

    if (json['interviewDate'] != null) {
      try {
        scheduledAt = TimezoneUtils.tryParseUtcToLocal(json['interviewDate']);
        if (scheduledAt == null) throw const FormatException();
        parsedDate =
            "${scheduledAt.year}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')}";
        parsedTime =
            "${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}";
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
      scheduledAt: scheduledAt,
      location: json['location'] ?? '',
      interviewerName: json['interviewerName'],
      interviewerRole: json['interviewerRole'],
      status: _parseStatus(json['status']),
      interviewType: json['interviewType'],
      meetingLink: json['meetingLink'],
      notes: json['notes'],
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'company': company,
      'companyLogo': companyLogo,
      'date': date,
      'time': time,
      'interviewDate': scheduledAt?.toUtc().toIso8601String(),
      'location': location,
      'interviewerName': interviewerName,
      'interviewerRole': interviewerRole,
      'status': status == InterviewStatus.withdrawn ? 'withdraw' : status.name,
      'interviewType': interviewType,
      'meetingLink': meetingLink,
      'notes': notes,
    };
  }

  static InterviewStatus _parseStatus(dynamic statusVal) {
    if (statusVal == null) return InterviewStatus.scheduled;

    // If it's an integer
    if (statusVal is int || int.tryParse(statusVal.toString()) != null) {
      final val = statusVal is int ? statusVal : int.parse(statusVal.toString());
      switch (val) {
        case 1:
          return InterviewStatus.scheduled;
        case 2:
          return InterviewStatus.completed;
        case 3:
          return InterviewStatus.cancelled;
        case 6:
          return InterviewStatus.confirmed;
        case 7:
          return InterviewStatus.missingInterview;
        case 8:
          return InterviewStatus.withdrawn;
      }
    }

    // Fallback for strings
    final s = statusVal.toString().trim().toLowerCase();
    final normalized = s.replaceAll(RegExp(r'[\s_\-]+'), '');
    if (s == 'scheduled') return InterviewStatus.scheduled;
    if (s == 'completed') return InterviewStatus.completed;
    if (s == 'cancelled' || s == 'canceled') return InterviewStatus.cancelled;
    if (normalized == 'confirmed' || normalized == 'confirmattendance') {
      return InterviewStatus.confirmed;
    }
    if (normalized == 'missinginterview' || normalized == 'missedinterview') {
      return InterviewStatus.missingInterview;
    }
    if (s == 'withdrawn' || s == 'withdraw') return InterviewStatus.withdrawn;

    return InterviewStatus.scheduled; // Default fallback
  }

  bool get isPast {
    if (scheduledAt == null) return false;
    return scheduledAt!.isBefore(DateTime.now());
  }

  InterviewModel copyWith({InterviewStatus? status}) {
    return InterviewModel(
      id: id,
      role: role,
      company: company,
      companyLogo: companyLogo,
      date: date,
      time: time,
      scheduledAt: scheduledAt,
      location: location,
      interviewerName: interviewerName,
      interviewerRole: interviewerRole,
      status: status ?? this.status,
      interviewType: interviewType,
      meetingLink: meetingLink,
      notes: notes,
    );
  }
}
