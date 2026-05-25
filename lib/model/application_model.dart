class ApplicationStatusModel {
  final String id;
  final String value;
  final String label;
  final String? foregroundColorHex;
  final String? backgroundColorHex;
  final Map<String, dynamic> rawJson;

  const ApplicationStatusModel({
    required this.id,
    required this.value,
    required this.label,
    this.foregroundColorHex,
    this.backgroundColorHex,
    this.rawJson = const {},
  });

  factory ApplicationStatusModel.fromJson(Map<String, dynamic> json) {
    final id = _firstNonEmpty([
      json['id'],
      json['statusId'],
      json['applicationStatusId'],
      json['code'],
    ]);
    final value = _firstNonEmpty([
      json['value'],
      json['status'],
      json['statusValue'],
      json['statusName'],
      json['applicationStatus'],
      json['name'],
      json['code'],
      id,
    ]);
    final label = _firstNonEmpty([
      json['label'],
      json['displayName'],
      json['arabicName'],
      json['nameAr'],
      json['title'],
      json['name'],
      json['statusName'],
      json['status'],
      json['value'],
      id,
    ]);

    return ApplicationStatusModel(
      id: id,
      value: value,
      label: label,
      foregroundColorHex: _nullableString(
        json['color'] ?? json['foregroundColor'] ?? json['textColor'],
      ),
      backgroundColorHex: _nullableString(
        json['backgroundColor'] ?? json['bgColor'],
      ),
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  factory ApplicationStatusModel.fromValue(dynamic rawValue) {
    final value = _readString(rawValue);
    return ApplicationStatusModel(id: value, value: value, label: value);
  }

  bool matches(ApplicationModel application) {
    final statusValues = {
      application.statusId,
      application.statusValue,
      application.statusRaw,
    }.map(ApplicationStatusMatcher.normalize);

    return matchValues
        .map(ApplicationStatusMatcher.normalize)
        .any(statusValues.contains);
  }

  Set<String> get matchValues {
    return {
      id,
      value,
      label,
      for (final key in const [
        'id',
        'statusId',
        'applicationStatusId',
        'value',
        'status',
        'statusValue',
        'statusName',
        'applicationStatus',
        'name',
        'code',
      ])
        _readString(rawJson[key]),
    }.where((value) => value.isNotEmpty).toSet();
  }
}

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
    return _firstNonEmpty([statusLabel, statusRaw, statusValue, statusId]);
  }

  ApplicationModel attachStatus(ApplicationStatusModel status) {
    return copyWith(
      statusLabel: status.label,
      statusColorHex: status.foregroundColorHex,
      statusBackgroundColorHex: status.backgroundColorHex,
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
}

class ApplicationsData {
  final List<ApplicationModel> applications;
  final List<ApplicationStatusModel> statuses;

  const ApplicationsData({required this.applications, required this.statuses});
}

class ApplicationStatusMatcher {
  static String normalize(String? value) {
    return (value ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'[\s_\-]+'),
      '',
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _readString(dynamic value) {
  if (value is Map || value is Iterable) return '';
  return value?.toString().trim() ?? '';
}

String? _nullableString(dynamic value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}

String _firstNonEmpty(List<dynamic> values) {
  return _firstNonEmptyOrNull(values) ?? '';
}

String? _firstNonEmptyOrNull(List<dynamic> values) {
  for (final value in values) {
    final text = _readString(value);
    if (text.isNotEmpty) return text;
  }
  return null;
}

bool? _readBool(dynamic value) {
  if (value is bool) return value;
  final text = _readString(value).toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}
