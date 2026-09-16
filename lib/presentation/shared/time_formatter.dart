import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Helper for formatting message/call timestamps into relative labels.
class TimeFormatter {
  TimeFormatter._();

  static String relative(DateTime time, DateTime now, AppLocalizations loc) {
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return loc.justNow;
    if (diff.inMinutes < 60) {
      return loc.minutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24 && now.day == time.day) {
      return loc.hoursAgo(diff.inHours);
    }
    if (diff.inDays < 7) {
      return loc.daysAgo(diff.inDays);
    }
    return DateFormat('d MMM').format(time);
  }

  static String clock(DateTime time) => DateFormat('HH:mm').format(time);

  static String full(DateTime time) =>
      DateFormat('d MMM yyyy, HH:mm').format(time.toLocal());

  static String callDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  static String dayLabel(DateTime time, DateTime now, AppLocalizations loc) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final dayDiff = today.difference(day).inDays;
    if (dayDiff == 0) return loc.today;
    if (dayDiff == 1) return loc.yesterday;
    return DateFormat('d MMMM yyyy').format(time);
  }
}
