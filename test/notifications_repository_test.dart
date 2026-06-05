import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/repository/notifications_repository.dart';
import 'package:gowork/utils/api_storage.dart';

class _FakeApiClient extends ApiClient {
  final List<String> calls = [];
  Map<String, dynamic> nextGetResponse = {};
  Map<String, dynamic>? lastPostBody;
  bool failPut = false;

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    calls.add('GET $endpoint');
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
    return {
      'success': true,
      'data': {'message': 'ok'},
    };
  }
}

void main() {
  group('NotificationsRepository', () {
    test('fetches paginated notifications from new endpoint', () async {
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

    test('uses documented mutation endpoints', () async {
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
      expect(apiClient.lastPostBody, {
        'token': 'abc token',
        'deviceType': 'android',
      });
    });

    test('falls back to legacy mark-read endpoint when PUT fails', () async {
      final apiClient = _FakeApiClient()..failPut = true;
      final repository = NotificationsRepository(apiClient: apiClient);

      await repository.markAsRead(12);

      expect(apiClient.calls, [
        'PUT notifications/12/read',
        'POST Notifications/mark-read/12',
      ]);
    });
  });
}
