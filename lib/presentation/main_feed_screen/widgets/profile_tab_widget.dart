import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../models/user_profile.dart';
import '../../../services/auth_service.dart';

class ProfileTabWidget extends StatefulWidget {
  final bool isAuthenticated;
  final VoidCallback onAuthRequired;

  const ProfileTabWidget({
    Key? key,
    required this.isAuthenticated,
    required this.onAuthRequired,
  }) : super(key: key);

  @override
  State<ProfileTabWidget> createState() => _ProfileTabWidgetState();
}

class _ProfileTabWidgetState extends State<ProfileTabWidget> {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      _loadUserProfile();
    }
  }

  @override
  void didUpdateWidget(ProfileTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAuthenticated != oldWidget.isAuthenticated) {
      if (widget.isAuthenticated) {
        _loadUserProfile();
      } else {
        setState(() {
          _userProfile = null;
          _error = '';
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final profile = await AuthService.instance.getCurrentUserProfile();

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
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

  Future<void> _signOut() async {
    try {
      await AuthService.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 3.h),
          Text(
            'Welcome to UniConnect',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Sign in to view your profile and interact with posts',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: widget.onAuthRequired,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sign In',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'Error loading profile',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _error,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'Profile not found',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: _userProfile!.profileImageUrl != null
                      ? NetworkImage(_userProfile!.profileImageUrl!)
                      : null,
                  child: _userProfile!.profileImageUrl == null
                      ? Text(
                          _userProfile!.fullName.isNotEmpty
                              ? _userProfile!.fullName
                                  .substring(0, 1)
                                  .toUpperCase()
                              : 'U',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                SizedBox(height: 2.h),

                // Name and role
                Text(
                  _userProfile!.fullName,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _userProfile!.isAdmin
                        ? Colors.red[100]
                        : Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _userProfile!.isAdmin ? 'Administrator' : 'Student',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _userProfile!.isAdmin
                          ? Colors.red[800]
                          : Colors.blue[800],
                    ),
                  ),
                ),

                if (_userProfile!.department != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    _userProfile!.department!,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Profile details
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Details',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildDetailRow('Email', _userProfile!.email),
                if (_userProfile!.studentId != null)
                  _buildDetailRow('Student ID', _userProfile!.studentId!),
                if (_userProfile!.universityId != null)
                  _buildDetailRow('University', _userProfile!.universityId!),
                _buildDetailRow('Member since',
                    '${_userProfile!.createdAt.day}/${_userProfile!.createdAt.month}/${_userProfile!.createdAt.year}'),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Sign out button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isAuthenticated
        ? _buildProfileView()
        : _buildUnauthenticatedView();
  }
}
