import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../../routes/app_routes.dart';
import '../../models/user_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign Up Controllers
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpFullNameController = TextEditingController();
  final _signUpDepartmentController = TextEditingController();
  final _signUpStudentIdController = TextEditingController();

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  bool _isSignInLoading = false;
  bool _isSignUpLoading = false;
  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;
  UserRole _selectedRole = UserRole.student;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpFullNameController.dispose();
    _signUpDepartmentController.dispose();
    _signUpStudentIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() {
      _isSignInLoading = true;
    });

    try {
      await AuthService.instance.signIn(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.mainFeed);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${_cleanError(error)}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSignInLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() {
      _isSignUpLoading = true;
    });

    try {
      await AuthService.instance.signUp(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text,
        fullName: _signUpFullNameController.text.trim(),
        role: _selectedRole,
        department: _signUpDepartmentController.text.trim().isEmpty
            ? null
            : _signUpDepartmentController.text.trim(),
        studentId: _signUpStudentIdController.text.trim().isEmpty
            ? null
            : _signUpStudentIdController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Cuenta creada con éxito. Ahora puedes iniciar sesión.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Switch to sign in tab
        _tabController.animateTo(0);

        // Clear sign up form
        _signUpEmailController.clear();
        _signUpPasswordController.clear();
        _signUpFullNameController.clear();
        _signUpDepartmentController.clear();
        _signUpStudentIdController.clear();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrarse: ${_cleanError(error)}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSignUpLoading = false;
        });
      }
    }
  }

  Widget _buildSignInTab() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),

            Text(
              l10n.t('welcomeBack'),
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              l10n.t('signInSubtitle'),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 4.h),

            // Email field
            TextFormField(
              controller: _signInEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.t('email'),
                hintText: l10n.t('enterEmail'),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.t('emailRequired');
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return l10n.t('emailInvalid');
                }
                return null;
              },
            ),

            SizedBox(height: 2.h),

            // Password field
            TextFormField(
              controller: _signInPasswordController,
              obscureText: _obscureSignInPassword,
              decoration: InputDecoration(
                labelText: l10n.t('password'),
                hintText: l10n.t('enterPassword'),
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSignInPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureSignInPassword = !_obscureSignInPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.t('passwordRequired');
                }
                return null;
              },
            ),

            SizedBox(height: 3.h),

            // Sign In button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSignInLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSignInLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.t('signInBtn'),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 2.h),

            // Demo credentials info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('demoCreds'),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Administrador: admin@university.edu / admin123',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    'Estudiante: john.doe@student.edu / student123',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpTab() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            Text(
              l10n.t('createAccount'),
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              l10n.t('joinCommunity'),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 3.h),

            // Full Name field
            TextFormField(
              controller: _signUpFullNameController,
              decoration: InputDecoration(
                labelText: l10n.t('fullName'),
                hintText: l10n.t('enterFullName'),
                prefixIcon: const Icon(Icons.person_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.t('fullNameRequired');
                }
                return null;
              },
            ),

            SizedBox(height: 2.h),

            // Email field
            TextFormField(
              controller: _signUpEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.t('email'),
                hintText: l10n.t('enterEmail'),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.t('emailRequired');
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return l10n.t('emailInvalid');
                }
                return null;
              },
            ),

            SizedBox(height: 2.h),

            // Password field
            TextFormField(
              controller: _signUpPasswordController,
              obscureText: _obscureSignUpPassword,
              decoration: InputDecoration(
                labelText: l10n.t('password'),
                hintText: l10n.t('enterPassword'),
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSignUpPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureSignUpPassword = !_obscureSignUpPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.t('passwordRequired');
                }
                if (value.length < 6) {
                  return l10n.t('passwordMin');
                }
                return null;
              },
            ),

            SizedBox(height: 2.h),

            // Role selection
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('role'),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // Lista vertical (orden: Administrador luego Estudiante) para evitar saltos de línea
                  Column(
                    children: [
                      RadioListTile<UserRole>(
                        title: Text(
                          l10n.t('admin'),
                          style: GoogleFonts.inter(fontSize: 12.sp),
                        ),
                        value: UserRole.admin,
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                      RadioListTile<UserRole>(
                        title: Text(
                          l10n.t('student'),
                          style: GoogleFonts.inter(fontSize: 12.sp),
                        ),
                        value: UserRole.student,
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Department field (optional)
            TextFormField(
              controller: _signUpDepartmentController,
              decoration: InputDecoration(
                labelText: l10n.t('departmentOpt'),
                hintText: l10n.t('departmentHint'),
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Student ID field (optional)
            if (_selectedRole == UserRole.student)
              TextFormField(
                controller: _signUpStudentIdController,
                decoration: InputDecoration(
                  labelText: l10n.t('studentIdOpt'),
                  hintText: l10n.t('studentIdHint'),
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            SizedBox(height: 3.h),

            // Sign Up button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSignUpLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSignUpLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.t('createAccountBtn'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Se elimina el botón de retroceso para esta pantalla
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'UniConnect',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: AppLocalizations.of(context).t('signIn')),
            Tab(text: AppLocalizations.of(context).t('signUp')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSignInTab(),
          _buildSignUpTab(),
        ],
      ),
    );
  }

  // Helper para limpiar mensajes de error
  String _cleanError(Object error) {
    final text = error.toString();
    return text.replaceFirst('Exception: ', '');
  }
}
