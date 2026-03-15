import 'package:cloud_firestore/cloud_firestore.dart';

class ToolTransaction {
  String? id;
  String userId;
  String toolId;
  DateTime timestamp;
  String action;

  ToolTransaction({
    this.id,
    required this.userId,
    required this.toolId,
    DateTime? timestamp,
    required this.action,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ToolTransaction.fromJson(Map<String, dynamic> json) {
    return ToolTransaction(
      id: json['id'],
      userId: json['userId'],
      toolId: json['toolId'],
      action: json['action'],
      timestamp:
          json['timestamp'] != null
              ? (json['timestamp'] is Timestamp
                  ? (json['timestamp'] as Timestamp).toDate()
                  : DateTime.parse(json['timestamp'] as String))
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'toolId': toolId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
