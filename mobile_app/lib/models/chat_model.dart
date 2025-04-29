import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, bool> approved; // userId -> bool indicating if chat approved
  final Timestamp createdAt;

  ChatModel({
    required this.id,
    required this.participants,
    required this.approved,
    required this.createdAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatModel(
      id: documentId,
      participants: List<String>.from(data['participants']),
      approved: Map<String, bool>.from(data['approved']),
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'approved': approved,
      'createdAt': createdAt,
    };
  }
}
