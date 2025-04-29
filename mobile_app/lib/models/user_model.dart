class UserModel {
  final String uid;
  final String name;
  final String? photoUrl;
  final String city;
  final String email;

  UserModel({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.city,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      city: data['city'],
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'city': city,
      'email': email,
    };
  }
}
