enum ApplicationStatus { sent, inReview, accepted, rejected, withdrawn }

class ApplicationModel {
  final String id;
  final String jobId;
  final String role;
  final String company;
  final String companyLogo;
  final String date;
  final String statusName;
  final String rawStatusName;
  final ApplicationStatus status;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.role,
    required this.company,
    required this.companyLogo,
    required this.date,
    required this.statusName,
    this.rawStatusName = '',
    required this.status,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final statusStrRaw =
        json['applicationStatus'] ?? json['status'] ?? json['statusName'];
    final rawStatus = statusStrRaw?.toString() ?? '';
    final appStatus = _parseStatus(rawStatus);

    // Handle nested job object if present
    final jobObj = json['job'] as Map<String, dynamic>?;

    return ApplicationModel(
      id: json['applicationId']?.toString() ?? json['id']?.toString() ?? '',
      jobId: jobObj?['id']?.toString() ?? json['jobId']?.toString() ?? '',
      role:
          jobObj?['title']?.toString() ??
          json['jobTitle']?.toString() ??
          json['role']?.toString() ??
          'بدون مسمى',
      company:
          jobObj?['companyName']?.toString() ??
          json['companyName']?.toString() ??
          json['company']?.toString() ??
          'غير معروف',
      companyLogo:
          jobObj?['companyLogo']?.toString() ??
          json['companyLogo']?.toString() ??
          '',
      date:
          json['appliedDate']?.toString() ??
          json['appliedAt']?.toString() ??
          json['createdAt']?.toString() ??
          json['date']?.toString() ??
          '',
      statusName: appStatus.arabicLabel,
      rawStatusName: rawStatus,
      status: appStatus,
    );
  }

  String get displayStatusName => status.arabicLabel;

  static ApplicationStatus _parseStatus(String rawStatus) {
    final statusStr = rawStatus
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '');
    if (statusStr.contains('review') ||
        statusStr.contains('pending') ||
        statusStr == '2') {
      return ApplicationStatus.inReview;
    } else if (statusStr.contains('accept') || statusStr == '3') {
      return ApplicationStatus.accepted;
    } else if (statusStr.contains('reject') || statusStr == '4') {
      return ApplicationStatus.rejected;
    } else if (statusStr.contains('withdraw') ||
        statusStr.contains('cancel') ||
        statusStr == '5') {
      return ApplicationStatus.withdrawn;
    }
    return ApplicationStatus.sent;
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
        return 'تم السحب';
    }
  }

  String get arabicLabel {
    switch (this) {
      case ApplicationStatus.sent:
        return 'تم التقديم';
      case ApplicationStatus.inReview:
        return 'قيد المراجعة';
      case ApplicationStatus.accepted:
        return 'تم القبول';
      case ApplicationStatus.rejected:
        return 'مرفوض';
      case ApplicationStatus.withdrawn:
        return 'تم السحب';
    }
  }

  String get englishApiValue {
    switch (this) {
      case ApplicationStatus.sent:
        return 'Sent';
      case ApplicationStatus.inReview:
        return 'PendingReview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
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
        return 0xFF757575; // Grey
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
        return 0xFFEEEEEE; // Light Grey
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
        return null;
    }
  }
}
