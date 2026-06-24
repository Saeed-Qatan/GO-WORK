part of 'application_model.dart';

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
    final backendLabel = _firstNonEmpty([
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
      label: ApplicationStatusLabels.arabicLabelFor([backendLabel, value, id]),
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
    return ApplicationStatusModel(
      id: value,
      value: value,
      label: ApplicationStatusLabels.arabicLabelFor([value]),
    );
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

  bool get isWithdrawn {
    return ApplicationStatusLabels.isWithdrawn(matchValues);
  }
}
