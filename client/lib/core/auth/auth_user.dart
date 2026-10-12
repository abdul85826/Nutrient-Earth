import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;
  final DateTime createdAt;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isGuest = false,
    required this.createdAt,
  });

  factory AuthUser.guest() {
    return AuthUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Guest Explorer',
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }

  factory AuthUser.fromSupabase(Map<String, dynamic> userMap) {
    final meta = userMap['user_metadata'] as Map<String, dynamic>? ?? {};
    return AuthUser(
      id: userMap['id'] as String? ?? '',
      email: userMap['email'] as String?,
      displayName: (meta['full_name'] ?? meta['name'] ?? userMap['email']?.toString().split('@').first) as String?,
      photoUrl: (meta['avatar_url'] ?? meta['picture']) as String?,
      isGuest: false,
      createdAt: DateTime.tryParse(userMap['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isGuest': isGuest,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String?,
    displayName: json['displayName'] as String?,
    photoUrl: json['photoUrl'] as String?,
    isGuest: json['isGuest'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          isGuest == other.isGuest;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ isGuest.hashCode;
}
