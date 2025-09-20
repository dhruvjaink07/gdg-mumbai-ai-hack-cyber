import '../models/alert_model.dart';
import '../models/alert_filter.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  Future<List<AlertModel>> fetchAlerts({AlertFilter? filter}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final allAlerts = [
      AlertModel(
        id: '1',
        title: 'Suspicious Login Attempt',
        description: 'Multiple failed login attempts detected from IP 192.168.1.100',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        category: 'Authentication',
        sourceIp: '192.168.1.100',
        affectedUser: 'john.doe@company.com',
        status: AlertStatus.open,
        riskScore: 85,
      ),
      AlertModel(
        id: '2',
        title: 'Malware Detection',
        description: 'Trojan.Win32.Generic detected on workstation WS-001',
        severity: AlertSeverity.critical,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        category: 'Malware',
        sourceIp: '10.0.0.45',
        affectedUser: 'system',
        status: AlertStatus.investigating,
        riskScore: 95,
      ),
      AlertModel(
        id: '3',
        title: 'Unusual Network Traffic',
        description: 'Abnormal data transfer patterns detected in network segment 192.168.2.0/24',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        category: 'Network',
        sourceIp: '192.168.2.25',
        affectedUser: 'network-scanner',
        status: AlertStatus.resolved,
        riskScore: 65,
      ),
      AlertModel(
        id: '4',
        title: 'Privilege Escalation Attempt',
        description: 'Unauthorized attempt to gain admin privileges detected',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'Access Control',
        sourceIp: '10.0.1.78',
        affectedUser: 'temp.user@company.com',
        status: AlertStatus.open,
        riskScore: 78,
      ),
      AlertModel(
        id: '5',
        title: 'Data Exfiltration Warning',
        description: 'Large file transfers to external servers detected',
        severity: AlertSeverity.critical,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        category: 'Data Loss Prevention',
        sourceIp: '172.16.0.12',
        affectedUser: 'marketing@company.com',
        status: AlertStatus.escalated,
        riskScore: 92,
      ),
      AlertModel(
        id: '6',
        title: 'Phishing Email Detected',
        description: 'Suspicious email with malicious links sent to multiple users',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        category: 'Email Security',
        sourceIp: '203.0.113.15',
        affectedUser: 'hr@company.com',
        status: AlertStatus.open,
        riskScore: 72,
      ),
      AlertModel(
        id: '7',
        title: 'USB Device Insertion',
        description: 'Unknown USB device connected to secure workstation',
        severity: AlertSeverity.low,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        category: 'Device Control',
        sourceIp: '192.168.1.55',
        affectedUser: 'finance.user@company.com',
        status: AlertStatus.resolved,
        riskScore: 35,
      ),
    ];

    if (filter != null) {
      return allAlerts.where((alert) => filter.matches(alert)).toList();
    }

    return allAlerts;
  }

  List<String> getAvailableCategories() {
    return [
      'Authentication',
      'Malware',
      'Network',
      'Access Control',
      'Data Loss Prevention',
      'Email Security',
      'Device Control',
    ];
  }
}