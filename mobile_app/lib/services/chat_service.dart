import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new chat request between two users
  Future<String> createChatRequest(String userId1, String userId2) async {
    DocumentReference docRef = await _firestore.collection('chats').add({
      'participants': [userId1, userId2],
      'approved': {userId1: true, userId2: false},
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Approve chat request for a user
  Future<void> approveChat(String chatId, String userId) async {
    DocumentReference docRef = _firestore.collection('chats').doc(chatId);
    await docRef.update({
      'approved.$userId': true,
    });
  }

  // Send a message in a chat
  Future<void> sendMessage(String chatId, String senderId, String message) async {
    CollectionReference messagesRef = _firestore.collection('chats').doc(chatId).collection('messages');
    await messagesRef.add({
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream chat messages
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Stream chat requests for a user
  Stream<QuerySnapshot> getChatRequests(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .where('approved.$userId', isEqualTo: false)
        .snapshots();
  }

  // Stream approved chats for a user
  Stream<QuerySnapshot> getApprovedChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .where('approved.$userId', isEqualTo: true)
        .snapshots();
  }
}
