import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/repository/notifications_repository.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiClient extends ApiClient {
  final List<String> calls = [];
  Map<String, dynamic> nextGetResponse = {};
  Map<String, dynamic>? lastPostBody;
  bool failGet = false;
  bool failPut = false;
  bool failDelete = false;
  bool failPost = false;

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    calls.add('GET $endpoint');
    if (failGet) throw Exception('get failed');
    return nextGetResponse;
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    calls.add('PUT $endpoint');
    if (failPut) throw Exception('put failed');
    return {
      'success': true,
      'data': {'message': 'ok'},
    };
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    calls.add('POST $endpoint');
    lastPostBody = body;
    if (failPost) throw Exception('post failed');
    return {
      'success': true,
      'data': {'message': 'ok'},
    };
  }

  @override
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    calls.add('DELETE $endpoint');
    if (failDelete) throw Exception('delete failed');
    return {
      'success': true,
      'data': {'message': 'ok'},
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationsRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('fetches paginated notifications from documented endpoint', () async {
      final apiClient = _FakeApiClient()
        ..nextGetResponse = {
          'data': {
            'items': [
              {
                'id': 12,
                'title': 'Title',
                'body': 'Body',
                'type': 'General',
                'deliveryType': 'User',
                'createdAt': '2026-06-02T16:30:00Z',
                'isRead': false,
              },
            ],
            'currentPage': 2,
            'pageSize': 20,
            'totalCount': 41,
            'totalPages': 3,
          },
        };
      final repository = NotificationsRepository(apiClient: apiClient);

      final page = await repository.getNotifications(pageNumber: 2);

      expect(apiClient.calls, ['GET notifications?pageNumber=2&pageSize=20']);
      expect(page.items.single.id, 12);
      expect(page.currentPage, 2);
      expect(page.hasMore, isTrue);
    });

    test('uses default documented pagination params', () async {
      final apiClient = _FakeApiClient()
        ..nextGetResponse = {
          'data': {
            'items': [],
            'currentPage': 1,
            'pageSize': 20,
            'totalCount': 0,
            'totalPages': 1,
          },
        };
      final repository = NotificationsRepository(apiClient: apiClient);

      await repository.getNotifications();

      expect(apiClient.calls, ['GET notifications?pageNumber=1&pageSize=20']);
    });

    test('reads unread count from wrapped data response', () async {
      final apiClient = _FakeApiClient()
        ..nextGetResponse = {
          'data': {'count': 5},
        };
      final repository = NotificationsRepository(apiClient: apiClient);

      final count = await repository.getUnreadCount();

      expect(apiClient.calls, ['GET notifications/unread-count']);
      expect(count, 5);
    });

    test('uses only documented mutation endpoints', () async {
      final apiClient = _FakeApiClient();
      final repository = NotificationsRepository(apiClient: apiClient);

      await repository.markAsRead(12);
      await repository.markAllAsRead();
      await repository.hideNotification(12);
      await repository.registerDeviceToken(
        token: 'abc token',
        deviceType: 'android',
      );
      await repository.removeDeviceToken('abc token');

      expect(apiClient.calls, [
        'PUT notifications/12/read',
        'PUT notifications/read-all',
        'DELETE notifications/12',
        'POST notifications/device-tokens',
        'DELETE notifications/device-tokens/abc%20token',
      ]);
      expect(apiClient.lastPostBody, containsPair('token', 'abc token'));
      expect(apiClient.lastPostBody, containsPair('deviceType', 'android'));
      expect(apiClient.lastPostBody, contains('timeZone'));
      expect(apiClient.lastPostBody, contains('timezoneOffset'));
      expect(
        apiClient.lastPostBody?['timezoneOffset'],
        matches(RegExp(r'^[+-]\d{2}:\d{2}$')),
      );
    });

    test('rethrows get notifications failures', () async {
      final apiClient = _FakeApiClient()..failGet = true;
      final repository = NotificationsRepository(apiClient: apiClient);

      expect(repository.getNotifications(), throwsA(isA<Exception>()));
      expect(apiClient.calls, ['GET notifications?pageNumber=1&pageSize=20']);
    });

    test('rethrows unread count failures so view model can fallback', () async {
      final apiClient = _FakeApiClient()
        ..failGet = true
        ..failPost = true;
      final repository = NotificationsRepository(apiClient: apiClient);

      await expectLater(repository.getUnreadCount(), throwsA(isA<Exception>()));
      expect(apiClient.calls, [
        'GET notifications/unread-count',
        'GET notifications/unread',
        'POST notifications/unread-count',
        'POST notifications/unread',
      ]);
    });

    test(
      'rethrows documented mark-read failures without legacy fallback',
      () async {
        final apiClient = _FakeApiClient()..failPut = true;
        final repository = NotificationsRepository(apiClient: apiClient);

        expect(repository.markAsRead(12), throwsA(isA<Exception>()));

        expect(apiClient.calls, ['PUT notifications/12/read']);
      },
    );

    test('rethrows mark-all and hide failures', () async {
      final markAllClient = _FakeApiClient()..failPut = true;
      final markAllRepository = NotificationsRepository(
        apiClient: markAllClient,
      );

      expect(markAllRepository.markAllAsRead(), throwsA(isA<Exception>()));
      expect(markAllClient.calls, ['PUT notifications/read-all']);

      final hideClient = _FakeApiClient()..failDelete = true;
      final hideRepository = NotificationsRepository(apiClient: hideClient);

      expect(hideRepository.hideNotification(12), throwsA(isA<Exception>()));
      expect(hideClient.calls, ['DELETE notifications/12']);
    });

    test('device token failures are swallowed by repository', () async {
      final postClient = _FakeApiClient()..failPost = true;
      final postRepository = NotificationsRepository(apiClient: postClient);

      await postRepository.registerDeviceToken(
        token: 'abc token',
        deviceType: 'android',
      );
      expect(postClient.calls, ['POST notifications/device-tokens']);

      final deleteClient = _FakeApiClient()..failDelete = true;
      final deleteRepository = NotificationsRepository(apiClient: deleteClient);

      await deleteRepository.removeDeviceToken('abc token');
      expect(deleteClient.calls, [
        'DELETE notifications/device-tokens/abc%20token',
      ]);
    });
  });
}
