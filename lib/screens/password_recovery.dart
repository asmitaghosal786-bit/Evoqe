import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/session_state.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.length < 8 || !password.contains(RegExp(r'\d'))) {
      setState(() {
        _error = 'Use at least 8 characters and include a number.';
      });
      return;
    }
    if (password != _confirmController.text) {
      setState(() {
        _error = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    final error = await context.read<SessionState>().completePasswordReset(
      password,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choose a new password',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Use at least 8 characters and include a number.',
                  style: TextStyle(color: Color(0xFF6E6760)),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFA33A3A)),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E3129),
                    foregroundColor: const Color(0xFFF5F3EC),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
