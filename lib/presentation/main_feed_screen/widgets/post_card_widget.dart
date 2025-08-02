import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/post.dart';
import '../../../services/posts_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_image_widget.dart';
import '../../../widgets/app_snackbar.dart';

class PostCardWidget extends StatefulWidget {
  final Post post;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onLikeChanged;

  const PostCardWidget({
    Key? key,
    required this.post,
    this.onTap,
    this.onLikeChanged,
  }) : super(key: key);

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  bool _isLiking = false;
  late int _likeCount;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _isLiked = widget.post.isLikedByCurrentUser ?? false;
  }

  Future<void> _toggleLike() async {
    if (_isLiking || !AuthService.instance.isAuthenticated) return;

    setState(() {
      _isLiking = true;
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await PostsService.instance.toggleLike(widget.post.id);
      widget.onLikeChanged?.call(_isLiked);
    } catch (error) {
      // Revert changes on error
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });

      if (mounted) {
        showAppSnackBar(context, 'Error al actualizar el like: $error',
            error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ]),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with author and timestamp
                          Row(children: [
                            CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                    (widget.post.authorName ?? 'A')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))),
                            SizedBox(width: 3.w),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(widget.post.authorName ?? 'Anonymous',
                                      style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87)),
                                  Text(widget.post.timeAgo,
                                      style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          color: Colors.grey[600])),
                                ])),
                            if (widget.post.isFeatured)
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star,
                                            size: 12.sp,
                                            color: Colors.amber[800]),
                                        SizedBox(width: 1.w),
                                        Text('Featured',
                                            style: GoogleFonts.inter(
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.amber[800])),
                                      ])),
                          ]),

                          SizedBox(height: 2.h),

                          // Title
                          Text(widget.post.title,
                              style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),

                          SizedBox(height: 1.h),

                          // Content
                          Text(widget.post.content,
                              style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: Colors.black54,
                                  height: 1.4),
                              maxLines: widget.post.isFeatured ? null : 3,
                              overflow: widget.post.isFeatured
                                  ? null
                                  : TextOverflow.ellipsis),

                          // Image if available
                          if (widget.post.imageUrl != null) ...[
                            SizedBox(height: 2.h),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomImageWidget(
                                    imageUrl: widget.post.imageUrl!,
                                    height: 25.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover)),
                          ],

                          SizedBox(height: 2.h),

                          // Actions row
                          Row(children: [
                            // Like button
                            InkWell(
                                onTap: _toggleLike,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 1.h),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _isLiking
                                              ? SizedBox(
                                                  width: 16.sp,
                                                  height: 16.sp,
                                                  child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              _isLiked
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .grey)))
                                              : Icon(
                                                  _isLiked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: _isLiked
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  size: 16.sp),
                                          SizedBox(width: 1.w),
                                          Text(_likeCount.toString(),
                                              style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  color: _isLiked
                                                      ? Colors.red
                                                      : Colors.grey,
                                                  fontWeight: FontWeight.w500)),
                                        ]))),

                            SizedBox(width: 2.w),

                            // Views count
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3.w, vertical: 1.h),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility_outlined,
                                          color: Colors.grey, size: 16.sp),
                                      SizedBox(width: 1.w),
                                      Text(widget.post.viewCount.toString(),
                                          style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500)),
                                    ])),

                            const Spacer(),

                            // Share button
                            InkWell(
                                onTap: () {
                                  // TODO: Implement share functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Share functionality coming soon!')));
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 1.h),
                                    child: Icon(Icons.share_outlined,
                                        color: Colors.grey, size: 16.sp))),
                          ]),
                        ])))));
  }
}
