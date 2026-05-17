enum ApplicationStatus { sent, inReview, accepted, rejected, withdrawn }

class ApplicationModel {
  final String id;
  final String role;
  final String company;
  final String companyLogo;
  final String date;
  final String statusName;
  final ApplicationStatus status;

  ApplicationModel({
    required this.id,
    required this.role,
    required this.company,
    required this.companyLogo,
    required this.date,
    required this.statusName,
    required this.status,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Determine status
    final statusStrRaw =
        json['applicationStatus'] ?? json['status'] ?? json['statusName'];
    final statusStr = statusStrRaw?.toString().toLowerCase() ?? '';
    final statusNameRaw = statusStrRaw ?? 'قيد المراجعة';

    ApplicationStatus appStatus = ApplicationStatus.sent;
    if (statusStr.contains('review') || statusStr == '2') {
      appStatus = ApplicationStatus.inReview;
    } else if (statusStr.contains('accept') || statusStr == '3') {
      appStatus = ApplicationStatus.accepted;
    } else if (statusStr.contains('reject') || statusStr == '4') {
      appStatus = ApplicationStatus.rejected;
    } else if (statusStr.contains('withdraw') || statusStr.contains('cancel') || statusStr == '5') {
      appStatus = ApplicationStatus.withdrawn;
    }

    // Handle nested job object if present
    final jobObj = json['job'] as Map<String, dynamic>?;

    return ApplicationModel(
      id: json['applicationId']?.toString() ?? json['id']?.toString() ?? '',
      role: jobObj?['title'] ?? json['jobTitle'] ?? json['role'] ?? 'بدون مسمى',
      company:
          jobObj?['companyName'] ??
          json['companyName'] ??
          json['company'] ??
          'غير معروف',
      companyLogo: jobObj?['companyLogo'] ?? json['companyLogo'] ?? '',
      date:
          json['appliedDate'] ??
          json['appliedAt'] ??
          json['createdAt'] ??
          json['date'] ??
          '',
      statusName: statusNameRaw.toString(),
      status: appStatus,
    );
  }
}

extension ApplicationStatusExt on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.inReview:
        return 'قيد المراجعة';
      case ApplicationStatus.accepted:
        return 'مقبول';
      case ApplicationStatus.rejected:
        return 'مرفوض';
      case ApplicationStatus.sent:
        return 'مُرسل';
      case ApplicationStatus.withdrawn:
        return 'مسحوب';
    }
  }

  int get colorHex {
    switch (this) {
      case ApplicationStatus.inReview:
        return 0xFFB79C12; // Goldish
      case ApplicationStatus.accepted:
        return 0xFF2E7D32; // Green
      case ApplicationStatus.rejected:
        return 0xFFC62828; // Red
      case ApplicationStatus.sent:
        return 0xFF1565C0; // Blue
      case ApplicationStatus.withdrawn:
        return 0xFF616161; // Grey
    }
  }

  int get bgColorHex {
    switch (this) {
      case ApplicationStatus.inReview:
        return 0xFFFFF9C4; // Light Yellow
      case ApplicationStatus.accepted:
        return 0xFFE8F5E9; // Light Green
      case ApplicationStatus.rejected:
        return 0xFFFFEBEE; // Light Red
      case ApplicationStatus.sent:
        return 0xFFE3F2FD; // Light Blue
      case ApplicationStatus.withdrawn:
        return 0xFFF5F5F5; // Light Grey
    }
  }

  int? get iconCodePoint {
    switch (this) {
      case ApplicationStatus.inReview:
        return 0xe03a; // Icons.access_time
      case ApplicationStatus.accepted:
        return 0xe156; // Icons.check
      case ApplicationStatus.rejected:
        return 0xe14c; // Icons.close
      case ApplicationStatus.sent:
        return null;
      case ApplicationStatus.withdrawn:
        return 0xe4c2; // Icons.remove_circle_outline
    }
  }
}
