import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app/app_viewmodel.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = context.watch<AppViewModel>();

    return Switch(
      value: appViewModel.isDarkMode,
      onChanged: (_) => context.read<AppViewModel>().toggleTheme(),
    );
  }
}
