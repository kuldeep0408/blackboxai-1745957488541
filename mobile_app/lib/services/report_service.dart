import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new report
  Future<String> createReport(String postId, String reporterId, String reason) async {
    DocumentReference docRef = await _firestore.collection('reports').add({
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'resolved': false,
    });
    return docRef.id;
  }

  // Fetch reports for admin review
  Stream<QuerySnapshot> getReports() {
    return _firestore.collection('reports').orderBy('createdAt', descending: true).snapshots();
  }

  // Mark report as resolved
  Future<void> resolveReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({'resolved': true});
  }
}
