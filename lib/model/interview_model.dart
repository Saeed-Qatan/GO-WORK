import '../utils/timezone_utils.dart';

enum InterviewStatus {
  confirmed,
  scheduled,
  declined,
  withdrawn,
  missedInterview,
  waiting,
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
      status: _resolveStatus(
        _parseStatus(json['status']?.toString()),
        scheduledAt,
      ),
      interviewType: json['interviewType'],
      meetingLink: json['meetingLink'],
      notes: json['notes'],
    );
  }

  static InterviewStatus _resolveStatus(
      InterviewStatus parsedStatus, DateTime? scheduledAt) {
    if (scheduledAt != null && scheduledAt.isBefore(DateTime.now())) {
      // If the time has passed and the backend returned 'declined' (which covers 'rejected' from timeouts),
      // we mark it as missed. We do not override 'waiting' or 'scheduled' here so that
      // shouldMarkAsMissed can still trigger the backend sync for them.
      if (parsedStatus == InterviewStatus.declined) {
        return InterviewStatus.missedInterview;
      }
    }
    return parsedStatus;
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

  static InterviewStatus _parseStatus(String? statusString) {
    if (statusString == null) return InterviewStatus.waiting;
    final s = statusString.trim().toLowerCase();
    if (s == 'confirmed') return InterviewStatus.confirmed;
    if (s == 'scheduled') return InterviewStatus.scheduled;
    if (s == 'missinterview' ||
        s == 'missinginterview' ||
        s == 'missedinterview' ||
        s == 'no_show') {
      return InterviewStatus.missedInterview;
    }
    if (s == 'withdraw' || s == 'withdrawn') {
      return InterviewStatus.withdrawn;
    }
    if (s == 'declined' ||
        s == 'rejected' ||
        s == 'cancelled' ||
        s == 'not_attending') {
      return InterviewStatus.declined;
    }
    if (s == 'waiting' || s == 'pending') return InterviewStatus.waiting;
    return InterviewStatus.waiting;
  }

  bool get isPast {
    if (scheduledAt == null) return false;
    return scheduledAt!.isBefore(DateTime.now());
  }

  bool get shouldMarkAsMissed {
    return isPast &&
        (status == InterviewStatus.scheduled ||
            status == InterviewStatus.waiting);
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
