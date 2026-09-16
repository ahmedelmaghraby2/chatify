import 'dart:ui';

import 'package:chatify/l10n/app_localizations.dart';
import 'package:chatify/presentation/shared/time_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeFormatter', () {
    late AppLocalizations loc;

    setUpAll(() async {
      loc = await AppLocalizations.delegate.load(const Locale('en'));
    });

    final now = DateTime(2026, 9, 15, 12, 0, 0);

    test('relative less than a minute', () {
      final t = now.subtract(const Duration(seconds: 30));
      expect(TimeFormatter.relative(t, now, loc), loc.justNow);
    });

    test('relative minutes ago', () {
      final t = now.subtract(const Duration(minutes: 5));
      expect(TimeFormatter.relative(t, now, loc), loc.minutesAgo(5));
    });

    test('relative hours ago', () {
      final t = now.subtract(const Duration(hours: 3));
      expect(TimeFormatter.relative(t, now, loc), loc.hoursAgo(3));
    });

    test('clock formats HH:mm', () {
      expect(TimeFormatter.clock(DateTime(2026, 9, 15, 8, 5)), '08:05');
    });

    test('dayLabel today/yesterday/other', () {
      expect(TimeFormatter.dayLabel(now, now, loc), loc.today);
      expect(
        TimeFormatter.dayLabel(
          now.subtract(const Duration(days: 1)),
          now,
          loc,
        ),
        loc.yesterday,
      );
    });

    test('callDuration formats', () {
      expect(TimeFormatter.callDuration(const Duration(seconds: 5)), '00:05');
      expect(
        TimeFormatter.callDuration(const Duration(minutes: 1, seconds: 23)),
        '01:23',
      );
      expect(
        TimeFormatter.callDuration(
          const Duration(hours: 1, minutes: 2, seconds: 3),
        ),
        '01:02:03',
      );
    });
  });
}