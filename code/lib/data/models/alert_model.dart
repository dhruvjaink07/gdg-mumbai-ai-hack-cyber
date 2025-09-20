class AlertModel {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String category;
  final String sourceIp;
  final String affectedUser;
  final AlertStatus status;
  final int riskScore;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.category,
    required this.sourceIp,
    required this.affectedUser,
    required this.status,
    required this.riskScore,
  });

  AlertModel copyWith({
    String? id,
    String? title,
    String? description,
    AlertSeverity? severity,
    DateTime? timestamp,
    String? category,
    String? sourceIp,
    String? affectedUser,
    AlertStatus? status,
    int? riskScore,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      sourceIp: sourceIp ?? this.sourceIp,
      affectedUser: affectedUser ?? this.affectedUser,
      status: status ?? this.status,
      riskScore: riskScore ?? this.riskScore,
    );
  }
}

enum AlertSeverity { low, medium, high, critical }

enum AlertStatus { open, investigating, resolved, escalated }