class ProfileModel {
  final String firstName;
  final String middleName;
  final String lastName;
  final String jobTitle;
  final String avatarUrl;
  final String email;
  final String phone;
  final String cvUrl;
  final String categoryId;

  /// The human-readable category name returned by GET /Account/Me as
  /// `interestedInCategory`. The backend does NOT return a numeric/GUID
  /// category ID in this endpoint, so we store the name here and resolve
  /// the ID later by matching against the /Jobs/categories list.
  final String categoryName;

  final List<String> skills;

  ProfileModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.jobTitle,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.cvUrl,
    required this.categoryId,
    required this.categoryName,
    required this.skills,
  });

  /// Computed full name for display
  String get name =>
      [firstName, middleName, lastName]
          .where((s) => s.trim().isNotEmpty)
          .join(' ');

  /// Computed role (alias for jobTitle for backward compat)
  String get role => jobTitle;

  ProfileModel copyWith({String? categoryId, String? categoryName}) {
    return ProfileModel(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      jobTitle: jobTitle,
      avatarUrl: avatarUrl,
      email: email,
      phone: phone,
      cvUrl: cvUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      skills: skills,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final categoryId = _readCategoryId(json);
    final categoryName = _readCategoryName(json);

    return ProfileModel(
      firstName: json['firstName'] ?? json['FirstName'] ?? '',
      middleName: json['middleName'] ?? json['MiddleName'] ?? '',
      lastName: json['lastName'] ?? json['LastName'] ?? '',
      jobTitle: json['jobTitle'] ?? json['JobTitle'] ?? json['role'] ?? '',
      avatarUrl:
          json['avatarUrl'] ??
          json['profilPhotoUrl'] ??
          json['AvatarUrl'] ??
          '',
      email: json['email'] ?? json['Email'] ?? '',
      phone:
          json['phoneNo'] ??
          json['phone'] ??
          json['Phone'] ??
          json['PhoneNumber'] ??
          '',
      cvUrl: json['resumeUrl'] ?? json['cvUrl'] ?? json['CvUrl'] ?? '',
      categoryId: categoryId,
      categoryName: categoryName,
      skills: List<String>.from(json['skills'] ?? json['Skills'] ?? []),
    );
  }

  /// Public entry-point for [_readCategoryId] so that external classes
  /// (e.g. ProfileRepository) can reuse the same key-lookup logic when
  /// traversing nested API response objects without duplicating the list.
  static String readCategoryIdFromMap(Map<String, dynamic> json) =>
      _readCategoryId(json);

  /// Reads the category ID from any of the known key names the backend
  /// may use (ID-based keys or nested object with an id field).
  static String _readCategoryId(Map<String, dynamic> json) {
    for (final key in const [
      'categoryId',
      'CategoryId',
      'interstedInCategoryId',
      'InterstedInCategoryId',
      'interestedInCategoryId',
      'InterestedInCategoryId',
      'interestedCategoryId',
      'InterestedCategoryId',
      'jobCategoryId',
      'JobCategoryId',
    ]) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    for (final key in const [
      'category',
      'Category',
      'interstedInCategory',
      'InterstedInCategory',
      'interestedInCategory',
      'InterestedInCategory',
      'jobCategory',
      'JobCategory',
    ]) {
      final value = json[key];
      if (value is Map) {
        final id =
            value['id'] ??
            value['Id'] ??
            value['categoryId'] ??
            value['CategoryId'];
        if (id != null && id.toString().trim().isNotEmpty) {
          return id.toString();
        }
      }
    }

    return '';
  }

  /// Reads the human-readable category name from the response.
  /// GET /Account/Me returns `interestedInCategory` as a plain string
  /// name (e.g. "أبحاث المستخدم") rather than an ID — this captures it.
  static String _readCategoryName(Map<String, dynamic> json) {
    for (final key in const [
      'interestedInCategory',
      'InterstedInCategory',
      'interstedInCategory',
      'InterestedInCategory',
      'categoryName',
      'CategoryName',
      'jobCategory',
      'JobCategory',
      'category',
      'Category',
    ]) {
      final value = json[key];
      // Only treat plain strings as a name — Maps are handled by _readCategoryId
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
      'JobTitle': jobTitle,
      'Email': email,
      'PhoneNumber': phone,
      'CategoryId': categoryId,
      'Skills': skills,
    };
  }
}
