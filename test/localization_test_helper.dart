import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/services.dart';

Future<void> loadTestTranslations() async {
  final raw = await rootBundle.loadString('lib/core/localization/ar.json');
  final decoded = json.decode(raw) as Map<String, dynamic>;
  Localization.load(
    const Locale('ar', 'AE'),
    translations: Translations(decoded),
  );
}
