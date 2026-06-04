import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/utils/app_error_parser.dart';

import 'localization_test_helper.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadTestTranslations();
  });

  test('unknown backend messages fall back to localized generic error', () {
    final message = AppErrorParser.parseResponseData({
      'message':
          '\u062e\u0637\u0623 \u063a\u064a\u0631 \u0645\u0639\u0631\u0648\u0641',
    });

    expect(message, 'genericError'.tr());
  });

  test('known backend messages are localized through translation keys', () {
    final message = AppErrorParser.parseResponseData({
      'message': 'Email already exists',
    });

    expect(message, 'emailAlreadyRegistered'.tr());
  });
}
