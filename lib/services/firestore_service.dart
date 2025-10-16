import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<RequestModel>> streamRequests() {
    return _db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => RequestModel.fromDoc(d)).toList());
  }

  Future<String> createRequest(Map<String, dynamic> data) async {
    final doc = await _db.collection('requests').add(data);
    return doc.id;
  }

  Future<void> updateRequest(String id, Map<String, dynamic> data) async {
    await _db.collection('requests').doc(id).update(data);
  }

  Future<void> deleteRequest(String id) async {
    // delete subcollection comments
    final comments = await _db.collection('requests').doc(id).collection('comments').get();
    for (var c in comments.docs) {
      await c.reference.delete();
    }
    await _db.collection('requests').doc(id).delete();
  }

  Stream<List<CommentModel>> streamComments(String requestId) {
    return _db
        .collection('requests')
        .doc(requestId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CommentModel.fromDoc(d)).toList());
  }

  Future<void> addComment(String requestId, Map<String, dynamic> commentData) async {
    await _db.collection('requests').doc(requestId).collection('comments').add(commentData);
  }
}
