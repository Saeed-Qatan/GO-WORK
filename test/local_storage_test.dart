import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('category selection is persisted per user and preserved on logout', () async {
    final storage = LocalStorage();

    await storage.saveString('userId', 'user-a');
    await storage.saveScopedString('categoryId', 'cat-a');

    await storage.clear();

    expect(await storage.getString('categoryId'), isNull);
    expect(await storage.getString('categoryId_user-a'), 'cat-a');

    await storage.saveString('userId', 'user-b');
    expect(await storage.getScopedString('categoryId'), isNull);

    await storage.saveScopedString('categoryId', 'cat-b');
    await storage.clear();

    await storage.saveString('userId', 'user-a');
    expect(await storage.getScopedString('categoryId'), 'cat-a');

    await storage.clear();
    await storage.saveString('userId', 'user-b');
    expect(await storage.getScopedString('categoryId'), 'cat-b');
  });
}
