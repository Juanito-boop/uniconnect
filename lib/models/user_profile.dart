enum UserRole { student, admin }

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? universityId;
  final String? department;
  final String? studentId;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.universityId,
    this.department,
    this.studentId,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: _parseRole(json['role'] as String?),
      universityId: json['university_id'] as String?,
      department: json['department'] as String?,
      studentId: json['student_id'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'university_id': universityId,
      'department': department,
      'student_id': studentId,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr) {
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? universityId,
    String? department,
    String? studentId,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      universityId: universityId ?? this.universityId,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
