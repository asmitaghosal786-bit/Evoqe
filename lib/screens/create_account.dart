import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/session_state.dart';
import 'home_screen.dart';
import 'selfie_capture.dart';
import 'welcome_screen.dart';

enum AuthMode { signUp, logIn }

class SecondScreen extends StatefulWidget {
  final AuthMode initialMode;

  const SecondScreen({super.key, this.initialMode = AuthMode.signUp});

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
  bool _hasRouted = false;

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
    if (!mounted || _hasRouted) return;
    _hasRouted = true;
    final session = context.read<SessionState>();
    if (session.shouldSkipToHome) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const EighthScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ThirdScreen()),
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

    final session = context.read<SessionState>();
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
      error = await session.logIn(email: email, password: password);
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
      if (_mode == AuthMode.signUp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created. You are now signed in.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF3E3129),
          ),
        );
      }
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
      builder: (context) =>
          _ForgotPasswordSheet(initialEmail: _emailController.text),
    );

    if (result == true && mounted) {
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If that email is registered, a password reset link is on its way.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF3E3129),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    if (session.isLoggedIn && !_hasRouted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _routeAfterAuth();
      });
    }

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
                    _mode == AuthMode.signUp
                        ? 'Make it yours.'
                        : 'Welcome back.',
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: _mode == AuthMode.signUp
                                  ? 'Log In'
                                  : 'Sign Up',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
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

class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;

  const _ForgotPasswordSheet({required this.initialEmail});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final int _step = 1;
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

    setState(() {
      _emailError = null;
      _isLoading = true;
    });
    final error = await context.read<SessionState>().resetPassword(
      email: email,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isLoading = false;
        _emailError = error;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  Future<void> _handleStep2() => _handleStep1();

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
            'Reset your password',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Color(0xFF201D19),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'We will email you a secure password reset link.',
            style: TextStyle(fontSize: 12, color: Color(0xFF888077)),
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
              style: const TextStyle(fontSize: 14.5, color: Color(0xFF201D19)),
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
                onPressed: _isLoading ? null : _handleStep1,
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
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Send reset link'),
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
              style: const TextStyle(fontSize: 14.5, color: Color(0xFF201D19)),
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
              style: const TextStyle(fontSize: 14.5, color: Color(0xFF201D19)),
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
