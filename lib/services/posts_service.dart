import '../models/post.dart';
import '../models/post_category.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class PostsService {
  // Buscar posts por texto en título o contenido
  Future<List<Post>> searchPosts(String query, {int limit = 50}) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      final response = await _client
          .from('posts')
          .select('*, user_profiles!author_id(full_name)')
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      Set<String> likedPostIds = {};
      if (userId != null) {
        final likesResponse = await _client
            .from('post_likes')
            .select('post_id')
            .eq('user_id', userId);
        likedPostIds = (likesResponse as List)
            .map((like) => like['post_id'] as String)
            .toSet();
      }

      return (response as List).map<Post>((json) {
        final post = Post.fromJson(json);
        final authorName = json['user_profiles']?['full_name'] as String?;
        return post.copyWith(
          authorName: authorName,
          isLikedByCurrentUser: likedPostIds.contains(post.id),
        );
      }).toList();
    } catch (error) {
      throw Exception('Failed to search posts: $error');
    }
  }

  static PostsService? _instance;
  static PostsService get instance => _instance ??= PostsService._();

  PostsService._();

  dynamic get _client => SupabaseService.instance.client;

  // Get all active posts with author information
  Future<List<Post>> getAllPosts({int limit = 50, int offset = 0}) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      final response = await _client
          .from('posts')
          .select('*, user_profiles!author_id(full_name)')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      Set<String> likedPostIds = {};
      if (userId != null) {
        final likesResponse = await _client
            .from('post_likes')
            .select('post_id')
            .eq('user_id', userId);
        likedPostIds = (likesResponse as List)
            .map((like) => like['post_id'] as String)
            .toSet();
      }

      return (response as List).map<Post>((json) {
        final post = Post.fromJson(json);
        final authorName = json['user_profiles']?['full_name'] as String?;
        return post.copyWith(
          authorName: authorName,
          isLikedByCurrentUser: likedPostIds.contains(post.id),
        );
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch posts: $error');
    }
  }

  Future<List<Post>> getFeaturedPosts({int limit = 10}) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      final response = await _client
          .from('posts')
          .select('*, user_profiles!author_id(full_name)')
          .eq('status', 'active')
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(limit);

      Set<String> likedPostIds = {};
      if (userId != null) {
        final likesResponse = await _client
            .from('post_likes')
            .select('post_id')
            .eq('user_id', userId);
        likedPostIds = (likesResponse as List)
            .map((like) => like['post_id'] as String)
            .toSet();
      }

      return (response as List).map<Post>((json) {
        final post = Post.fromJson(json);
        final authorName = json['user_profiles']?['full_name'] as String?;
        return post.copyWith(
          authorName: authorName,
          isLikedByCurrentUser: likedPostIds.contains(post.id),
        );
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch featured posts: $error');
    }
  }

  Future<List<Post>> getPostsByCategory(String categoryId,
      {int limit = 50}) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      final response = await _client
          .from('posts')
          .select(
              '*, user_profiles!author_id(full_name), post_category_assignments!inner(category_id)')
          .eq('status', 'active')
          .eq('post_category_assignments.category_id', categoryId)
          .order('created_at', ascending: false)
          .limit(limit);

      Set<String> likedPostIds = {};
      if (userId != null) {
        final likesResponse = await _client
            .from('post_likes')
            .select('post_id')
            .eq('user_id', userId);
        likedPostIds = (likesResponse as List)
            .map((like) => like['post_id'] as String)
            .toSet();
      }

      return (response as List).map<Post>((json) {
        final post = Post.fromJson(json);
        final authorName = json['user_profiles']?['full_name'] as String?;
        return post.copyWith(
          authorName: authorName,
          isLikedByCurrentUser: likedPostIds.contains(post.id),
        );
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch posts by category: $error');
    }
  }

  // Create new post (admin only)
  Future<Post> createPost({
    required String title,
    required String content,
    String? imageUrl,
    bool isFeatured = false,
    List<String>? categoryIds,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if user is admin
      final isAdmin = await AuthService.instance.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Only administrators can create posts');
      }

      final postData = {
        'author_id': currentUser.id,
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'is_featured': isFeatured,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _client.from('posts').insert(postData).select().single();

      final post = Post.fromJson(response);

      // Add category associations if provided
      if (categoryIds != null && categoryIds.isNotEmpty) {
        await _assignCategoriesToPost(post.id, categoryIds);
      }

      return post;
    } catch (error) {
      throw Exception('Failed to create post: $error');
    }
  }

  // Update post (admin only)
  Future<Post> updatePost(
    String postId, {
    String? title,
    String? content,
    String? imageUrl,
    bool? isFeatured,
    PostStatus? status,
    List<String>? categoryIds,
  }) async {
    try {
      // Check if user is admin
      final isAdmin = await AuthService.instance.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Only administrators can update posts');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (isFeatured != null) updateData['is_featured'] = isFeatured;
      if (status != null) updateData['status'] = status.name;

      final response = await _client
          .from('posts')
          .update(updateData)
          .eq('id', postId)
          .select()
          .single();

      // Update category associations if provided
      if (categoryIds != null) {
        await _updatePostCategories(postId, categoryIds);
      }

      return Post.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update post: $error');
    }
  }

  // Delete post (admin only)
  Future<void> deletePost(String postId) async {
    try {
      // Check if user is admin
      final isAdmin = await AuthService.instance.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Only administrators can delete posts');
      }

      await _client.from('posts').delete().eq('id', postId);
    } catch (error) {
      throw Exception('Failed to delete post: $error');
    }
  }

  // Like/unlike post
  Future<void> toggleLike(String postId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if already liked
      final existingLike = await _client
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUser.id);
      } else {
        // Like
        await _client.from('post_likes').insert({
          'post_id': postId,
          'user_id': currentUser.id,
        });
      }
    } catch (error) {
      throw Exception('Failed to toggle like: $error');
    }
  }

  // Get categories
  Future<List<PostCategory>> getCategories() async {
    try {
      final response = await _client
          .from('post_categories')
          .select()
          .order('is_system_category', ascending: false)
          .order('name', ascending: true);

      return response
          .map<PostCategory>((json) => PostCategory.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  // Private helper methods
  Future<void> _assignCategoriesToPost(
      String postId, List<String> categoryIds) async {
    final assignments = categoryIds
        .map((categoryId) => {
              'post_id': postId,
              'category_id': categoryId,
            })
        .toList();

    await _client.from('post_category_assignments').insert(assignments);
  }

  Future<void> _updatePostCategories(
      String postId, List<String> categoryIds) async {
    // Delete existing assignments
    await _client
        .from('post_category_assignments')
        .delete()
        .eq('post_id', postId);

    // Add new assignments
    if (categoryIds.isNotEmpty) {
      await _assignCategoriesToPost(postId, categoryIds);
    }
  }

  // Real-time subscription for posts
  dynamic subscribeToPostChanges({
    required Function(List<Post>) onPostsChanged,
  }) {
    return _client
        .channel('posts_changes')
        .onPostgresChanges(
          event: 'all',
          schema: 'public',
          table: 'posts',
          callback: (payload) async {
            // Refresh posts when changes occur
            try {
              final posts = await getAllPosts();
              onPostsChanged(posts);
            } catch (error) {
              print('Error refreshing posts: $error');
            }
          },
        )
        .subscribe();
  }
}
