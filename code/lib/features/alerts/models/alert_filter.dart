import 'alert_model.dart';

class AlertFilter {
  final List<AlertSeverity> severities;
  final List<AlertStatus> statuses;
  final List<String> categories;
  final String? searchQuery;
  final DateRange? dateRange;

  const AlertFilter({
    this.severities = const [],
    this.statuses = const [],
    this.categories = const [],
    this.searchQuery,
    this.dateRange,
  });

  AlertFilter copyWith({
    List<AlertSeverity>? severities,
    List<AlertStatus>? statuses,
    List<String>? categories,
    String? searchQuery,
    DateRange? dateRange,
  }) {
    return AlertFilter(
      severities: severities ?? this.severities,
      statuses: statuses ?? this.statuses,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  bool matches(AlertModel alert) {
    // Check severity filter
    if (severities.isNotEmpty && !severities.contains(alert.severity)) {
      return false;
    }

    // Check status filter
    if (statuses.isNotEmpty && !statuses.contains(alert.status)) {
      return false;
    }

    // Check category filter
    if (categories.isNotEmpty && !categories.contains(alert.category)) {
      return false;
    }

    // Check search query
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!alert.title.toLowerCase().contains(query) &&
          !alert.description.toLowerCase().contains(query) &&
          !alert.sourceIp.toLowerCase().contains(query) &&
          !alert.affectedUser.toLowerCase().contains(query)) {
        return false;
      }
    }

    // Check date range
    if (dateRange != null) {
      if (alert.timestamp.isBefore(dateRange!.start) ||
          alert.timestamp.isAfter(dateRange!.end)) {
        return false;
      }
    }

    return true;
  }

  bool get hasActiveFilters {
    return severities.isNotEmpty ||
           statuses.isNotEmpty ||
           categories.isNotEmpty ||
           (searchQuery != null && searchQuery!.isNotEmpty) ||
           dateRange != null;
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});
}