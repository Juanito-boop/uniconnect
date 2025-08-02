import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitializing = true;
  String _statusMessage = 'Inicializando UniConnect...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _statusMessage = 'Inicializando servicios...';
      });
      // Inicializar Supabase
      await SupabaseService.initialize();

      setState(() {
        _statusMessage = 'Verificando autenticación...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _statusMessage = 'Cargando preferencias...';
      });
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() {
        _statusMessage = 'Configurando universidad...';
      });
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() {
        _statusMessage = 'Preparando contenido...';
      });
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _isInitializing = false;
        _statusMessage = '¡Listo!';
      });

      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // Navegar según autenticación
      await _navigateToNextScreen();
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _statusMessage = 'Error de conexión';
      });
      await Future.delayed(const Duration(seconds: 2));
      _showRetryOption();
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate authentication check
    final bool isAuthenticated = await _checkAuthenticationStatus();
    final bool isFirstTime = await _checkFirstTimeUser();

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/main-feed-screen');
    } else if (isFirstTime) {
      // For now, navigate to login as onboarding is not implemented
      Navigator.pushReplacementNamed(context, '/login-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    // Simulate checking stored authentication token
    await Future.delayed(const Duration(milliseconds: 200));
    // Return false for demo - in real app, check stored credentials
    return false;
  }

  Future<bool> _checkFirstTimeUser() async {
    // Simulate checking if user has opened app before
    await Future.delayed(const Duration(milliseconds: 100));
    // Return true for demo - in real app, check stored preferences
    return true;
  }

  void _showRetryOption() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Error de Conexión',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'No se pudo conectar con el servidor. Verifica tu conexión a internet e inténtalo de nuevo.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login-screen');
              },
              child: Text(
                'Continuar sin conexión',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isInitializing = true;
                  _statusMessage = 'Reintentando...';
                });
                _initializeApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for branded experience
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
              AppTheme.lightTheme.colorScheme.tertiary.withOpacity(0.6),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),

              // Animated Logo Section
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 35.w,
                        height: 35.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20.0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'school',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 15.w,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'UniConnect',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),

              // App Title and Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'UniConnect',
                      style:
                          AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Tu comunidad universitaria conectada',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Loading Section
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Loading Indicator
                        _isInitializing
                            ? SizedBox(
                                width: 8.w,
                                height: 8.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              )
                            : CustomIconWidget(
                                iconName: 'check_circle',
                                color: Colors.white,
                                size: 8.w,
                              ),

                        SizedBox(height: 2.h),

                        // Status Message
                        Container(
                          constraints: BoxConstraints(maxWidth: 80.w),
                          child: Text(
                            _statusMessage,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12.sp,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 6.h),

              // University Branding
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'verified',
                        color: Colors.white.withOpacity(0.7),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          'Plataforma oficial universitaria',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10.sp,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
