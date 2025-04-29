import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String userId;
  final String itemName;
  final String description;
  final GeoPoint lastSeenLocation;
  final DateTime dateLost;
  final String? photoUrl;
  final String category;
  final double? reward;
  final String type; // 'lost' or 'found'
  final Timestamp createdAt;

  ItemModel({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.description,
    required this.lastSeenLocation,
    required this.dateLost,
    this.photoUrl,
    required this.category,
    this.reward,
    required this.type,
    required this.createdAt,
  });

  factory ItemModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ItemModel(
      id: documentId,
      userId: data['userId'],
      itemName: data['itemName'],
      description: data['description'],
      lastSeenLocation: data['lastSeenLocation'],
      dateLost: (data['dateLost'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      category: data['category'],
      reward: data['reward'] != null ? (data['reward'] as num).toDouble() : null,
      type: data['type'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemName': itemName,
      'description': description,
      'lastSeenLocation': lastSeenLocation,
      'dateLost': Timestamp.fromDate(dateLost),
      'photoUrl': photoUrl,
      'category': category,
      'reward': reward,
      'type': type,
      'createdAt': createdAt,
    };
  }
}
