import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(String dateString) {
    try {
      // Try parsing different date formats
      DateTime? dateTime;
      if (dateString.contains('/')) {
        // Already formatted - try to parse and reformat to dd/MM/yyyy
        try {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            // Check if it's yyyy/MM/dd format
            if (parts[0].length == 4) {
              dateTime = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            } else {
              // Already dd/MM/yyyy
              return dateString;
            }
          }
        } catch (_) {
          return dateString;
        }
      } else if (dateString.contains('-')) {
        // Parse YYYY-MM-DD format
        dateTime = DateTime.parse(dateString);
      } else {
        // Try other formats
        dateTime = DateTime.tryParse(dateString);
      }

      if (dateTime != null) {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
      return dateString; // Return original if parsing fails
    } catch (e) {
      return dateString;
    }
  }

  static String formatTime(String timeString) {
    try {
      // Try parsing different time formats
      DateTime? dateTime;
      if (timeString.contains(':')) {
        // Parse time like "14:30" or "14:30:00"
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          dateTime = DateTime(2024, 1, 1, hour, minute);
        }
      }

      if (dateTime != null) {
        return DateFormat('hh:mma').format(dateTime).toLowerCase();
      }
      return timeString; // Return original if parsing fails
    } catch (e) {
      return timeString;
    }
  }

  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.tryParse(dateTimeString);
      if (dateTime != null) {
        final date = DateFormat('dd/MM/yyyy').format(dateTime);
        final time = DateFormat('hh:mma').format(dateTime).toLowerCase();
        return '$date $time';
      }
      return dateTimeString;
    } catch (e) {
      return dateTimeString;
    }
  }
}