import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String postId;
  final String reporterId;
  final String reason;
  final Timestamp createdAt;
  final bool resolved;

  ReportModel({
    required this.id,
    required this.postId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
    this.resolved = false,
  });

  factory ReportModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ReportModel(
      id: documentId,
      postId: data['postId'],
      reporterId: data['reporterId'],
      reason: data['reason'],
      createdAt: data['createdAt'],
      resolved: data['resolved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': createdAt,
      'resolved': resolved,
    };
  }
}
