enum PostStatus { active, archived, draft }

class Post {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String? imageUrl;
  final PostStatus status;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data that may be loaded with joins
  final String? authorName;
  final List<String>? categories;
  final bool? isLikedByCurrentUser;

  Post({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.status,
    required this.isFeatured,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.categories,
    this.isLikedByCurrentUser,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      status: _parseStatus(json['status'] as String?),
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: json['author_name'] as String?,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      isLikedByCurrentUser: json['is_liked_by_current_user'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'status': status.name,
      'is_featured': isFeatured,
      'view_count': viewCount,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static PostStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'active':
        return PostStatus.active;
      case 'archived':
        return PostStatus.archived;
      case 'draft':
        return PostStatus.draft;
      default:
        return PostStatus.active;
    }
  }

  Post copyWith({
    String? id,
    String? authorId,
    String? title,
    String? content,
    String? imageUrl,
    PostStatus? status,
    bool? isFeatured,
    int? viewCount,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    List<String>? categories,
    bool? isLikedByCurrentUser,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      categories: categories ?? this.categories,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
