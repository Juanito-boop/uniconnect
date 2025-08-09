import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:uniconnect/presentation/events/events_tab_widget.dart';
import '../../l10n/app_localizations.dart';

import '../../models/post.dart';
import '../../models/post_category.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/posts_service.dart';
import './widgets/empty_feed_widget.dart';
import './widgets/feed_header_widget.dart';
import './widgets/feed_tab_bar_widget.dart';
import './widgets/post_card_widget.dart';
import './widgets/profile_tab_widget.dart';
import './widgets/search_tab_widget.dart';
import './widgets/feed_category_chips_widget.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({Key? key}) : super(key: key);

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  List<Post> _featuredPosts = [];
  List<PostCategory> _categories = [];
  bool _isLoading = true;
  String _error = '';
  bool _isAuthenticated = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _restoreSessionAndInit();
    _loadEvents();
  }

  Future<void> _restoreSessionAndInit() async {
    await AuthService.instance.restoreSession();
    _checkAuthState();
    _loadData();
  }

  // Nuevo método para cargar eventos
  Future<void> _loadEvents() async {
    try {
      // Se cargará en el EventsTab directamente
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAuthState() {
    setState(() {
      _isAuthenticated = AuthService.instance.isAuthenticated;
    });

    // Listen to auth state changes
    AuthService.instance.authStateChanges.listen((state) {
      if (mounted) {
        setState(() {
          _isAuthenticated = state.session != null;
        });
      }
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final results = await Future.wait([
        PostsService.instance.getAllPosts(),
        PostsService.instance.getFeaturedPosts(),
        PostsService.instance.getCategories(),
      ]);

      if (mounted) {
        final allPosts = results[0] as List<Post>;
        // Depuración: imprimir las categorías de cada post
        for (final post in allPosts) {
          print(
              'Post: \\n  id: \\${post.id} \\n  title: \\${post.title} \\n  categories: \\${post.categories}');
        }
        setState(() {
          _allPosts = allPosts;
          _filteredPosts = allPosts;
          _featuredPosts = results[1] as List<Post>;
          _categories = results[2] as List<PostCategory>;
          _isLoading = false;
          _selectedCategoryId = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId == null) {
        _filteredPosts = _allPosts;
      } else {
        _filteredPosts = _allPosts
            .where((p) => (p.categories ?? []).contains(categoryId))
            .toList();
      }
    });
  }

  void _onPostLikeChanged(String postId, bool isLiked) {
    setState(() {
      // Actualiza en _allPosts
      final idxAll = _allPosts.indexWhere((p) => p.id == postId);
      if (idxAll != -1) {
        final post = _allPosts[idxAll];
        _allPosts[idxAll] = post.copyWith(
          isLikedByCurrentUser: isLiked,
          likeCount: (post.likeCount + (isLiked ? 1 : -1)).clamp(0, 1 << 30),
        );
      }
      // Actualiza en _filteredPosts
      final idxFiltered = _filteredPosts.indexWhere((p) => p.id == postId);
      if (idxFiltered != -1) {
        final post = _filteredPosts[idxFiltered];
        _filteredPosts[idxFiltered] = post.copyWith(
          isLikedByCurrentUser: isLiked,
          likeCount: (post.likeCount + (isLiked ? 1 : -1)).clamp(0, 1 << 30),
        );
      }
      // También actualiza en featured si aplica
      final fidx = _featuredPosts.indexWhere((p) => p.id == postId);
      if (fidx != -1) {
        final post = _featuredPosts[fidx];
        _featuredPosts[fidx] = post.copyWith(
          isLikedByCurrentUser: isLiked,
          likeCount: (post.likeCount + (isLiked ? 1 : -1)).clamp(0, 1 << 30),
        );
      }
    });
  }

  Widget _buildFeedTab() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
        SizedBox(height: 2.h),
        Text(l10n.t('errorGeneric'),
            style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        SizedBox(height: 1.h),
        Text(_error,
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center),
        SizedBox(height: 2.h),
        ElevatedButton(onPressed: _loadData, child: Text(l10n.t('retry'))),
      ]));
    }
    if (_filteredPosts.isEmpty) {
      return const EmptyFeedWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(slivers: [
        // Categories filter
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: FeedCategoryChipsWidget(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: _onCategorySelected,
            ),
          ),
        ),

        // Featured posts section (only show when "All Posts" is selected)
        if (_selectedCategoryId == null && _featuredPosts.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(l10n.t('featuredPosts'),
                      style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
                ..._featuredPosts
                    .map((post) => PostCardWidget(
                          post: post,
                          onLikeChanged: (isLiked) =>
                              _onPostLikeChanged(post.id, isLiked),
                        ))
                    .toList(),
                Divider(height: 24, thickness: 1.5, color: Colors.grey[200]),
              ],
            ),
          ),

        // All posts section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
                _selectedCategoryId == null
                    ? l10n.t('allPosts')
                    : l10n.t('posts'),
                style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
        ),
        // Posts list
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = _filteredPosts[index];
            return PostCardWidget(
                post: post,
                onLikeChanged: (isLiked) =>
                    _onPostLikeChanged(post.id, isLiked));
          }, childCount: _filteredPosts.length),
        ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: 80)),
      ]),
    );
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
          child: Column(children: [
        // Header
        FeedHeaderWidget(onNotificationTap: () {
          Navigator.pushNamed(context, AppRoutes.notifications);
        }),

        // Tab bar
        FeedTabBarWidget(
          tabController: _tabController,
          tabs: [
            l10n.t('homeTab'),
            l10n.t('eventsTab'),
            l10n.t('searchTab'),
            l10n.t('profileTab'),
          ],
        ),

        // Tab content
        Expanded(
            child: TabBarView(controller: _tabController, children: [
          // Feed tab
          _buildFeedTab(),

          _buildEventsTab(),
          // Search tab
          SearchTabWidget(onPostLikeChanged: _onPostLikeChanged),

          // Profile tab
          ProfileTabWidget(
              isAuthenticated: _isAuthenticated,
              onAuthRequired: () {
                Navigator.pushNamed(context, AppRoutes.login);
              }),
        ])),
      ])),

      // Floating action button for creating posts (admin only)
      floatingActionButton: _isAuthenticated
          ? FutureBuilder<bool>(
              future: AuthService.instance.isCurrentUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return FloatingActionButton(
                    onPressed: () {
                      // Detectar en qué tab estamos
                      if (_tabController.index == 1) {
                        // Estamos en Events tab
                        Navigator.pushNamed(context, AppRoutes.createEvent);
                      } else {
                        // Estamos en Feed tab
                        Navigator.pushNamed(context, AppRoutes.createPost);
                      }
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.add, color: Colors.white),
                  );
                }
                return const SizedBox.shrink();
              })
          : null,
    );
  }

  Widget _buildEventsTab() {
    return EventsTabWidget(
      onEventTap: (event) {
        Navigator.pushNamed(
          context,
          AppRoutes.eventDetail,
          arguments: event,
        );
      },
    );
  }
}
