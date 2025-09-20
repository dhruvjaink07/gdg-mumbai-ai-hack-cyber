import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class AlertHelpers {
  // Severity helpers
  static String getSeverityName(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  static Color getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red.shade800;
    }
  }

  static IconData getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Icons.info_outline;
      case AlertSeverity.medium:
        return Icons.warning_amber;
      case AlertSeverity.high:
        return Icons.error_outline;
      case AlertSeverity.critical:
        return Icons.dangerous;
    }
  }

  // Status helpers
  static String getStatusName(AlertStatus status) {
    switch (status) {
      case AlertStatus.open:
        return 'Open';
      case AlertStatus.investigating:
        return 'Investigating';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.escalated:
        return 'Escalated';
    }
  }

  static Color getStatusColor(AlertStatus status) {
    switch (status) {
      case AlertStatus.open:
        return Colors.orange;
      case AlertStatus.investigating:
        return Colors.blue;
      case AlertStatus.resolved:
        return Colors.green;
      case AlertStatus.escalated:
        return Colors.red;
    }
  }

  static IconData getStatusIcon(AlertStatus status) {
    switch (status) {
      case AlertStatus.open:
        return Icons.radio_button_unchecked;
      case AlertStatus.investigating:
        return Icons.search;
      case AlertStatus.resolved:
        return Icons.check_circle_outline;
      case AlertStatus.escalated:
        return Icons.priority_high;
    }
  }

  // Category helpers
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Authentication':
        return Icons.lock_outline;
      case 'Malware':
        return Icons.bug_report;
      case 'Network':
        return Icons.network_check;
      case 'Access Control':
        return Icons.security;
      case 'Data Loss Prevention':
        return Icons.shield;
      case 'Email Security':
        return Icons.email;
      case 'Device Control':
        return Icons.devices;
      default:
        return Icons.category;
    }
  }
}