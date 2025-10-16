import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  String id;
  String title;
  String description;
  String userId;
  String userName;
  String? photoUrl;
  double latitude;
  double longitude;
  DateTime createdAt;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.userName,
    this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory RequestModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      photoUrl: data['photoUrl'],
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
