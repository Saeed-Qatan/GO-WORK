import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/locale_keys.dart';
import '../viewmodels/app/app_viewmodel.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = context.watch<AppViewModel>();

    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'ar',
          label: Text(LocaleKeys.languageArabic.tr()),
          icon: Icon(Icons.language_rounded),
        ),
        ButtonSegment(
          value: 'en',
          label: Text(LocaleKeys.languageEnglish.tr()),
          icon: Icon(Icons.translate_rounded),
        ),
      ],
      selected: {appViewModel.currentLanguageCode},
      onSelectionChanged: (selection) {
        context.read<AppViewModel>().changeLanguage(selection.first);
      },
      showSelectedIcon: false,
    );
  }
}
