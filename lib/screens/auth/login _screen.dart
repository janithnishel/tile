import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/routes/company_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════
  // 📐 RESPONSIVE BREAKPOINTS
  // ═══════════════════════════════════════
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to home/dashboard based on user role
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          _showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (isDesktop(context)) {
                  return _buildDesktopLayout(isLoading: state is AuthLoading);
                } else if (isTablet(context)) {
                  return _buildTabletLayout(isLoading: state is AuthLoading);
                } else {
                  return _buildMobileLayout(isLoading: state is AuthLoading);
                }
              },
            ),
          ),
        );
      },
    );
  }



  // ═══════════════════════════════════════
  // 🖥️ DESKTOP LAYOUT - Split Screen
  // ═══════════════════════════════════════
  Widget _buildDesktopLayout({required bool isLoading}) {
    return Row(
      children: [
        // ════════════════════════════════════
        // 🎨 LEFT SIDE - Branding Panel
        // ════════════════════════════════════
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade800,
                  const Color(0xFF1A1A2E),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BackgroundPatternPainter(),
                  ),
                ),

                // Content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(60),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.store_rounded,
                                    size: 60,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Title
                              const Text(
                                'TileWork Pro',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Subtitle
                              Text(
                                'Manage your tile business with ease.\nInvoices, inventory, and customers in one place.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.6,
                                ),
                              ),

                              const SizedBox(height: 50),

                              // Features
                              _buildFeatureList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Version at bottom
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Version 1.0.0 • © 2024 Your Company',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ════════════════════════════════════
        // 📝 RIGHT SIDE - Login Form
        // ════════════════════════════════════
        Expanded(
          flex: 4,
          child: Container(
            color: const Color(0xFFF8F9FC),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 450,
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to continue to your dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Login Card
                          _buildLoginForm(isDesktop: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // 📱 TABLET LAYOUT - Centered Card
  // ═══════════════════════════════════════
  Widget _buildTabletLayout({required bool isLoading}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
            const Color(0xFF1A1A2E),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeader(isLarge: true),
                  ),

                  const SizedBox(height: 50),

                  // Login Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoginCard(isLarge: true),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFooter(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 📱 MOBILE LAYOUT - Full Screen
  // ═══════════════════════════════════════
  Widget _buildMobileLayout({required bool isLoading}) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
            const Color(0xFF1A1A2E),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeader(isLarge: false),
                  ),

                  const SizedBox(height: 40),

                  // Login Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLoginCard(isLarge: false),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFooter(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🎨 HEADER WIDGET
  // ═══════════════════════════════════════
  Widget _buildHeader({required bool isLarge}) {
    return Column(
      children: [
        // Logo Container
        Container(
          width: isLarge ? 110 : 90,
          height: isLarge ? 110 : 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isLarge ? 30 : 24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.store_rounded,
              size: isLarge ? 55 : 45,
              color: Colors.blue.shade600,
            ),
          ),
        ),

        SizedBox(height: isLarge ? 32 : 24),

        // Title
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: isLarge ? 34 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),

        SizedBox(height: isLarge ? 12 : 8),

        // Subtitle
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: isLarge ? 18 : 16,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // 📝 LOGIN CARD WIDGET
  // ═══════════════════════════════════════
  Widget _buildLoginCard({required bool isLarge}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 36 : 28),
        child: _buildLoginForm(isDesktop: false),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 📝 LOGIN FORM (Shared)
  // ═══════════════════════════════════════
  Widget _buildLoginForm({required bool isDesktop}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          _buildEmailField(isDesktop: isDesktop),

          SizedBox(height: isDesktop ? 24 : 20),

          // Password Field
          _buildPasswordField(isDesktop: isDesktop),

          SizedBox(height: isDesktop ? 20 : 16),

          // Remember Me & Forgot Password
          _buildOptionsRow(isDesktop: isDesktop),

          SizedBox(height: isDesktop ? 32 : 28),

          // Login Button
          _buildLoginButton(isDesktop: isDesktop),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 📧 EMAIL FIELD
  // ═══════════════════════════════════════
  Widget _buildEmailField({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: isDesktop ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 15,
              fontWeight: FontWeight.w500,
            ),
            enableInteractiveSelection: true,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isDesktop ? 20 : 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // 🔒 PASSWORD FIELD
  // ═══════════════════════════════════════
  Widget _buildPasswordField({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: isDesktop ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 12 : 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 15,
              fontWeight: FontWeight.w500,
            ),
            enableInteractiveSelection: true,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isDesktop ? 20 : 18,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // ⚙️ OPTIONS ROW
  // ═══════════════════════════════════════
  Widget _buildOptionsRow({required bool isDesktop}) {
    return Row(
      children: [
        // Remember Me
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isDesktop ? 24 : 22,
                  height: isDesktop ? 24 : 22,
                  decoration: BoxDecoration(
                    color:
                        _rememberMe ? Colors.blue.shade600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _rememberMe
                          ? Colors.blue.shade600
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: _rememberMe
                      ? Icon(
                          Icons.check,
                          size: isDesktop ? 18 : 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Forgot Password
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _showForgotPasswordDialog,
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: isDesktop ? 15 : 14,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // 🔵 LOGIN BUTTON
  // ═══════════════════════════════════════
  Widget _buildLoginButton({required bool isDesktop}) {
    // Get the current loading state from Bloc
    final isLoading = context.watch<AuthCubit>().state is AuthLoading;

    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 60 : 56,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade500,
                  Colors.blue.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: isLoading
                  ? SizedBox(
                      width: isDesktop ? 28 : 26,
                      height: isDesktop ? 28 : 26,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🌟 FEATURE LIST (Desktop Only)
  // ═══════════════════════════════════════
  Widget _buildFeatureList() {
    final features = [
      {'icon': Icons.receipt_long_rounded, 'text': 'Easy Invoice Management'},
      {'icon': Icons.inventory_2_rounded, 'text': 'Stock & Inventory Tracking'},
      {'icon': Icons.people_rounded, 'text': 'Customer Relationship Management'},
      {'icon': Icons.analytics_rounded, 'text': 'Business Analytics & Reports'},
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      feature['text'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ═══════════════════════════════════════
  // 📞 FOOTER WIDGET
  // ═══════════════════════════════════════
  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Version 1.0.0',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '© 2024 Your Company',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // 🔐 LOGIN HANDLER
  // ═══════════════════════════════════════
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Debug: Show login attempt
      debugPrint('🔐 Attempting login with email: $email');

      // Use AuthCubit for login
      context.read<AuthCubit>().login(email, password);
    }
  }

  // ═══════════════════════════════════════
  // 🔄 FORGOT PASSWORD DIALOG
  // ═══════════════════════════════════════
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: Colors.orange.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar('Reset link sent to your email!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Send Link',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ✅ SUCCESS SNACKBAR
  // ═══════════════════════════════════════
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ═══════════════════════════════════════
  // ❌ ERROR SNACKBAR
  // ═══════════════════════════════════════
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ═══════════════════════════════════════
// 🎨 BACKGROUND PATTERN PAINTER
// ═══════════════════════════════════════
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.1 * i, size.height * 0.2 * i),
        100 + (i * 30),
        paint,
      );
    }

    // Draw more circles
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width - (100 * i), size.height * 0.3 * i),
        80 + (i * 40),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
