import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) return;

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('app_colors.dart') || file.path.contains('app_theme.dart') || file.path.contains('app_shadows.dart')) continue;

    String content = file.readAsStringSync();
    bool changed = false;

    // Replace basic colors
    final replacements = {
      'Colors.grey.withValues(alpha: 0.1)': 'AppColors.inputBackground',
      'Colors.grey.withValues(alpha: 0.2)': 'AppColors.border',
      'Colors.grey.withValues(alpha: 0.5)': 'AppColors.textHint',
    };

    for (final entry in replacements.entries) {
      if (content.contains(entry.key)) {
        content = content.replaceAll(entry.key, entry.value);
        changed = true;
      }
    }

    if (changed) {
      // Ensure AppColors is imported if we use it
      if (!content.contains('app_colors.dart')) {
        // Find the first import
        final importIndex = content.indexOf('import ');
        if (importIndex != -1) {
          content = content.replaceFirst('import ', "import 'package:gowork/theme/app_colors.dart';\nimport ");
        }
      }
      file.writeAsStringSync(content);
      print('Updated: ${file.path}');
    }
  }
}
