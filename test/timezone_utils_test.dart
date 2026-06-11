import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/utils/timezone_utils.dart';

void main() {
  group('TimezoneUtils', () {
    test('formats timezone offsets as signed hours and minutes', () {
      expect(TimezoneUtils.formatOffset(const Duration(hours: 3)), '+03:00');
      expect(
        TimezoneUtils.formatOffset(const Duration(hours: -5, minutes: -30)),
        '-05:30',
      );
    });

    test('builds request headers from the current timezone data', () {
      final headers = TimezoneUtils.requestHeaders(
        now: DateTime(2026, 6, 2, 12),
      );

      expect(headers['Time-Zone'], isNotEmpty);
      expect(headers['X-Timezone-Offset'], matches(RegExp(r'^[+-]\d{2}:\d{2}$')));
    });

    test('parses utc timestamps with and without explicit timezone markers', () {
      final withMarker = TimezoneUtils.tryParseUtcToLocal(
        '2026-06-02T16:30:00Z',
      );
      final withoutMarker = TimezoneUtils.tryParseUtcToLocal(
        '2026-06-02T16:30:00',
      );

      expect(withMarker?.toUtc(), DateTime.utc(2026, 6, 2, 16, 30));
      expect(withoutMarker?.toUtc(), DateTime.utc(2026, 6, 2, 16, 30));
    });
  });
}
