class UserProfileLocal {
  final String uid;
  final String? email;
  final String name;
  final String address;
  final int updatedAtMillis;

  const UserProfileLocal({
    required this.uid,
    required this.email,
    required this.name,
    required this.address,
    required this.updatedAtMillis,
  });

  UserProfileLocal copyWith({String? name, String? address, int? updatedAtMillis}) => UserProfileLocal(
        uid: uid,
        email: email,
        name: name ?? this.name,
        address: address ?? this.address,
        updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      );

  Map<String, Object?> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'address': address,
        'updated_at': updatedAtMillis,
      };

  static UserProfileLocal fromMap(Map<String, Object?> m) => UserProfileLocal(
        uid: m['uid'] as String,
        email: m['email'] as String?,
        name: (m['name'] as String?) ?? '',
        address: (m['address'] as String?) ?? '',
        updatedAtMillis: (m['updated_at'] as int?) ?? 0,
      );
}
