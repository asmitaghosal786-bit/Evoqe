import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_service.dart';
import 'home_screen.dart';
import 'selfie_capture.dart';
import 'welcome_screen.dart';

enum AuthMode { signUp, logIn }

class SecondScreen extends StatefulWidget {
  final AuthMode initialMode;

  const SecondScreen({
    super.key,
    this.initialMode = AuthMode.signUp,
  });

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  late AuthMode _mode;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hasAttemptedSubmit = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateLiveIfNeeded() {
    if (!_hasAttemptedSubmit) return;
    setState(() {
      _validateInputs();
    });
  }

  bool _validateInputs() {
    bool isValid = true;
    _nameError = null;
    _emailError = null;
    _passwordError = null;

    if (_mode == AuthMode.signUp) {
      final name = _nameController.text.trim();
      if (name.length < 2) {
        _nameError = 'Please enter your name (at least 2 characters)';
        isValid = false;
      }
    }

    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email address';
      isValid = false;
    }

    final password = _passwordController.text;
    if (_mode == AuthMode.signUp) {
      if (password.length < 8 || !password.contains(RegExp(r'\d'))) {
        _passwordError =
            'Password must be at least 8 characters and include a number';
        isValid = false;
      }
    } else {
      if (password.isEmpty) {
        _passwordError = 'Please enter your password';
        isValid = false;
      }
    }

    return isValid;
  }

  void _routeAfterAuth() {
    if (!mounted) return;
    final session = context.read<SessionService>();
    if (session.hasCompletedOnboarding) {
      // TODO(nav): existing user with completed onboarding goes to home.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const EighthScreen(),
        ),
        (route) => false,
      );
    } else {
      // TODO(nav): new users continue the onboarding flow.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ThirdScreen(),
        ),
      );
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _hasAttemptedSubmit = true;
    });

    if (!_validateInputs()) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final session = context.read<SessionService>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    String? error;
    if (_mode == AuthMode.signUp) {
      error = await session.signUp(
        name: name,
        email: email,
        password: password,
      );
    } else {
      error = await session.logIn(
        email: email,
        password: password,
      );
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3E3129),
        ),
      );
    } else {
      _routeAfterAuth();
    }
  }

  Future<void> _openForgotPasswordSheet() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F3EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ForgotPasswordSheet(
        initialEmail: _emailController.text,
      ),
    );

    if (result == true && mounted) {
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated. Log in with your new password.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF3E3129),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // TODO(auth): replace with google_sign_in / sign_in_with_apple.
    if (_isLoading) return;

    final account = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F3EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _GoogleAccountSheet(),
    );

    if (account == null || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    final session = context.read<SessionService>();
    final error = await session.signInWithProvider(
      provider: SocialProvider.google,
      name: account['name']!,
      email: account['email']!,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3E3129),
        ),
      );
    } else {
      _routeAfterAuth();
    }
  }

  Future<void> _handleAppleSignIn() async {
    // TODO(auth): replace with google_sign_in / sign_in_with_apple.
    if (_isLoading) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F3EC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _AppleSignInSheet(),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    final session = context.read<SessionService>();
    final error = await session.signInWithProvider(
      provider: SocialProvider.apple,
      name: 'Ananya Sharma',
      email: 'ananya.sharma@icloud.com',
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3E3129),
        ),
      );
    } else {
      _routeAfterAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3EC),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Top App Bar Row: Back Arrow | EVOQE Logo | Shopping Bag Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF201D19),
                          size: 25,
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const EvoqeHeaderLogo(),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF201D19),
                          size: 22,
                        ),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Eyebrow Text
                  const Text(
                    'YOUR PRIVATE ATELIER',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: Color(0xFF888077),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Main Headline
                  Text(
                    _mode == AuthMode.signUp ? 'Make it yours.' : 'Welcome back.',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF201D19),
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    _mode == AuthMode.signUp
                        ? 'Create an account to keep your preferences, inspiration and saved looks in one place.'
                        : 'Log in to return to your saved looks and style profile.',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6E6760),
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Full Name Field (Sign up ONLY)
                  if (_mode == AuthMode.signUp) ...[
                    const Text(
                      'Full name',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6E6760),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _validateLiveIfNeeded(),
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF201D19),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle: const TextStyle(
                          color: Color(0xFF888077),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEFECE4),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        errorText: _nameError,
                        errorStyle: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFA33A3A),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFCDC6BA),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF3E3129),
                            width: 1.2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA33A3A),
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA33A3A),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Email Field
                  const Text(
                    'Email address',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6E6760),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _validateLiveIfNeeded(),
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF201D19),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your email',
                      hintStyle: const TextStyle(
                        color: Color(0xFF888077),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEFECE4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      errorText: _emailError,
                      errorStyle: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFA33A3A),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFCDC6BA),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFF3E3129),
                          width: 1.2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFA33A3A),
                          width: 1.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFA33A3A),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Password Field
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6E6760),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => _validateLiveIfNeeded(),
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF201D19),
                    ),
                    decoration: InputDecoration(
                      hintText: _mode == AuthMode.signUp
                          ? 'Create a password'
                          : 'Your password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF888077),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEFECE4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF201D19),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      errorText: _passwordError,
                      errorStyle: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFA33A3A),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFCDC6BA),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFF3E3129),
                          width: 1.2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFA33A3A),
                          width: 1.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: const BorderSide(
                          color: Color(0xFFA33A3A),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Forgot Password Link (Log in ONLY)
                  if (_mode == AuthMode.logIn) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _openForgotPasswordSheet,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E3129),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Password Helper Text (Sign up ONLY)
                  if (_mode == AuthMode.signUp) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Use at least 8 characters, including a number.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF888077),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E3129),
                        foregroundColor: const Color(0xFFF5F3EC),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Color(0xFFF5F3EC),
                                strokeWidth: 2.0,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _mode == AuthMode.signUp
                                      ? 'Create Account'
                                      : 'Log In',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider ("OR")
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0xFFD6CFC4),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF888077),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0xFFD6CFC4),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Social Login Buttons
                  _SocialButton(
                    label: 'Continue with Google',
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    label: 'Continue with Apple',
                    onPressed: _isLoading ? null : _handleAppleSignIn,
                  ),

                  // Terms and Privacy Note (Sign up ONLY)
                  if (_mode == AuthMode.signUp) ...[
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7C746C),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Security Note with Lock Icon
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 16,
                        color: Color(0xFF322E2B),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Your images stay private. You choose what to share.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A544D),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Footer Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _mode = _mode == AuthMode.signUp
                              ? AuthMode.logIn
                              : AuthMode.signUp;
                          _nameError = null;
                          _emailError = null;
                          _passwordError = null;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF201D19),
                            fontFamily: 'serif',
                          ),
                          children: [
                            TextSpan(
                              text: _mode == AuthMode.signUp
                                  ? 'Already part of EVOQE? '
                                  : 'New to EVOQE? ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                            ),
                            TextSpan(
                              text: _mode == AuthMode.signUp
                                  ? 'Log In'
                                  : 'Sign Up',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFEFECE4),
          foregroundColor: const Color(0xFF201D19),
          side: const BorderSide(
            color: Color(0xFFCDC6BA),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF201D19),
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _GoogleAccountSheet extends StatelessWidget {
  const _GoogleAccountSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCDC6BA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose an account',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF201D19),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Demo accounts',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: Color(0xFF888077),
            ),
          ),
          const SizedBox(height: 16),
          _buildAccountTile(
            context,
            name: 'Ananya Sharma',
            email: 'ananya.sharma@gmail.com',
            initial: 'A',
          ),
          const SizedBox(height: 8),
          _buildAccountTile(
            context,
            name: 'Rohan Mehta',
            email: 'rohan.mehta@gmail.com',
            initial: 'R',
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required String name,
    required String email,
    required String initial,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, {'name': name, 'email': email});
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFECE4),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFFCDC6BA), width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF3E3129),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFFF5F3EC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF201D19),
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888077),
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
}

class _AppleSignInSheet extends StatelessWidget {
  const _AppleSignInSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCDC6BA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in with Apple',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF201D19),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Demo mode',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: Color(0xFF888077),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE4),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFFCDC6BA), width: 1),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF201D19),
                  child: Icon(
                    Icons.apple,
                    color: Color(0xFFF5F3EC),
                    size: 20,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ananya Sharma',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF201D19),
                        ),
                      ),
                      Text(
                        'ananya.sharma@icloud.com',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888077),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E3129),
                foregroundColor: const Color(0xFFF5F3EC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordSheet({required this.initialEmail});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  int _step = 1;
  late final TextEditingController _emailController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleStep1() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    final session = context.read<SessionService>();
    if (!session.accountExists(email)) {
      setState(() {
        _emailError = 'No account found for this email';
      });
      return;
    }

    setState(() {
      _emailError = null;
      _step = 2;
    });
  }

  Future<void> _handleStep2() async {
    FocusScope.of(context).unfocus();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool isValid = true;
    String? passErr;
    String? confErr;

    if (newPassword.length < 8 || !newPassword.contains(RegExp(r'\d'))) {
      passErr = 'Password must be at least 8 characters and include a number';
      isValid = false;
    }

    if (confirmPassword != newPassword) {
      confErr = 'Passwords do not match';
      isValid = false;
    }

    if (!isValid) {
      setState(() {
        _passwordError = passErr;
        _confirmError = confErr;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
      _confirmError = null;
    });

    final session = context.read<SessionService>();
    final error = await session.resetPassword(
      email: _emailController.text.trim(),
      newPassword: newPassword,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _passwordError = error;
      });
    } else {
      // TODO(auth): replace with an emailed reset link/code once a backend exists.
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCDC6BA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _step == 1 ? 'Reset your password' : 'Create a new password',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF201D19),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Demo mode: no email is sent.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888077),
            ),
          ),
          const SizedBox(height: 20),
          if (_step == 1) ...[
            const Text(
              'Email address',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6760),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF201D19),
              ),
              decoration: InputDecoration(
                hintText: 'Your email',
                hintStyle: const TextStyle(
                  color: Color(0xFF888077),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFEFECE4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                errorText: _emailError,
                errorStyle: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFA33A3A),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFCDC6BA),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF3E3129),
                    width: 1.2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFA33A3A),
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFA33A3A),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleStep1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E3129),
                  foregroundColor: const Color(0xFFF5F3EC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text(
              'New Password',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6760),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF201D19),
              ),
              decoration: InputDecoration(
                hintText: 'New password',
                hintStyle: const TextStyle(
                  color: Color(0xFF888077),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFEFECE4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF201D19),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
                errorText: _passwordError,
                errorStyle: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFA33A3A),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFCDC6BA),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF3E3129),
                    width: 1.2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFA33A3A),
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFA33A3A),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6760),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF201D19),
              ),
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                hintStyle: const TextStyle(
                  color: Color(0xFF888077),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFEFECE4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF201D19),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                errorText: _confirmError,
                errorStyle: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFA33A3A),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFCDC6BA),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF3E3129),
                    width: 1.2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFA33A3A),
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFA33A3A),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E3129),
                  foregroundColor: const Color(0xFFF5F3EC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFFF5F3EC),
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text(
                        'Update password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
