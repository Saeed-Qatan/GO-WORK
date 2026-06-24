part of 'application_model.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String role;
  final String company;
  final String companyLogo;
  final String date;
  final String statusId;
  final String statusValue;
  final String statusRaw;
  final String? statusLabel;
  final String? statusColorHex;
  final String? statusBackgroundColorHex;
  final bool? canWithdraw;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.role,
    required this.company,
    required this.companyLogo,
    required this.date,
    required this.statusId,
    required this.statusValue,
    required this.statusRaw,
    this.statusLabel,
    this.statusColorHex,
    this.statusBackgroundColorHex,
    this.canWithdraw,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final jobObj = _asMap(json['job']);
    final statusObj =
        _asMap(json['applicationStatus']) ?? _asMap(json['status']);

    final statusId = _firstNonEmpty([
      json['statusId'],
      json['applicationStatusId'],
      statusObj?['id'],
      statusObj?['statusId'],
      statusObj?['code'],
    ]);
    final statusValue = _firstNonEmpty([
      json['status'],
      json['statusValue'],
      json['statusName'],
      statusObj?['value'],
      statusObj?['status'],
      statusObj?['statusValue'],
      statusObj?['statusName'],
      statusObj?['name'],
      statusObj?['code'],
      json['applicationStatus'],
      statusId,
    ]);
    final statusRaw = _firstNonEmpty([
      statusValue,
      statusId,
      json['applicationStatus'],
      json['status'],
      json['statusName'],
    ]);

    return ApplicationModel(
      id: _firstNonEmpty([json['applicationId'], json['id']]),
      jobId: _firstNonEmpty([jobObj?['id'], json['jobId']]),
      role: _firstNonEmpty([
        jobObj?['title'],
        json['jobTitle'],
        json['role'],
        json['title'],
        'بدون مسمى',
      ]),
      company: _firstNonEmpty([
        jobObj?['companyName'],
        json['companyName'],
        json['company'],
        'غير معروف',
      ]),
      companyLogo: _firstNonEmpty([
        jobObj?['companyLogo'],
        jobObj?['companyLogoUrl'],
        json['companyLogo'],
        json['companyLogoUrl'],
      ]),
      date: _firstNonEmpty([
        json['appliedDate'],
        json['appliedAt'],
        json['createdAt'],
        json['date'],
      ]),
      statusId: statusId,
      statusValue: statusValue,
      statusRaw: statusRaw,
      statusLabel: _firstNonEmptyOrNull([
        statusObj?['label'],
        statusObj?['displayName'],
        statusObj?['arabicName'],
        statusObj?['nameAr'],
      ]),
      canWithdraw: _readBool(
        json['canWithdraw'] ??
            json['isWithdrawable'] ??
            json['allowWithdraw'] ??
            json['canCancel'],
      ),
    );
  }

  String get statusLabelFromBackend {
    return ApplicationStatusLabels.arabicLabelFor([
      statusLabel,
      statusRaw,
      statusValue,
      statusId,
    ]);
  }

  ApplicationModel attachStatus(ApplicationStatusModel status) {
    return copyWith(
      statusLabel: status.label,
      statusColorHex: status.foregroundColorHex,
      statusBackgroundColorHex: status.backgroundColorHex,
    );
  }

  ApplicationModel withStatus(ApplicationStatusModel status) {
    return copyWith(
      statusId: status.id.isNotEmpty ? status.id : statusId,
      statusValue: status.value.isNotEmpty ? status.value : statusValue,
      statusRaw: status.value.isNotEmpty ? status.value : statusRaw,
      statusLabel: status.label,
      statusColorHex: status.foregroundColorHex,
      statusBackgroundColorHex: status.backgroundColorHex,
      canWithdraw: false,
    );
  }

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? role,
    String? company,
    String? companyLogo,
    String? date,
    String? statusId,
    String? statusValue,
    String? statusRaw,
    String? statusLabel,
    String? statusColorHex,
    String? statusBackgroundColorHex,
    bool? canWithdraw,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      role: role ?? this.role,
      company: company ?? this.company,
      companyLogo: companyLogo ?? this.companyLogo,
      date: date ?? this.date,
      statusId: statusId ?? this.statusId,
      statusValue: statusValue ?? this.statusValue,
      statusRaw: statusRaw ?? this.statusRaw,
      statusLabel: statusLabel ?? this.statusLabel,
      statusColorHex: statusColorHex ?? this.statusColorHex,
      statusBackgroundColorHex:
          statusBackgroundColorHex ?? this.statusBackgroundColorHex,
      canWithdraw: canWithdraw ?? this.canWithdraw,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'role': role,
      'company': company,
      'companyLogo': companyLogo,
      'date': date,
      'statusId': statusId,
      'statusValue': statusValue,
      'statusRaw': statusRaw,
      'statusLabel': statusLabel,
      'statusColorHex': statusColorHex,
      'statusBackgroundColorHex': statusBackgroundColorHex,
      'canWithdraw': canWithdraw,
    };
  }
}
