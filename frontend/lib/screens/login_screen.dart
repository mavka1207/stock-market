import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import 'nav_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoginMode = true; // true = login, false = signup

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ------ Basic validation ------
    if (email.isEmpty || password.isEmpty || (!_isLoginMode && confirmPassword.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!_isLoginMode && password != confirmPassword) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // ------ Access AuthProvider and call login or signup ------
    final auth = context.read<AuthProvider>();

    String? errorMessage;

    if (_isLoginMode) {
      // LOGIN
      debugPrint('🟣 UI: calling AuthProvider.login');
      errorMessage = await auth.login(email: email, password: password);
    } else {
      // SIGNUP
      debugPrint('🟣 UI: calling AuthProvider.signup');
      errorMessage = await auth.signup(email: email, password: password);
    }

    // ----- If there was an error, show ERROR snackbar --------
    if (errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;  
    }

    // ------ SUCCESS SIGNED UP / LOGGED IN  --------
    if (!mounted) return;

    debugPrint('🟣 UI: Login/Signup successful');

    if (!_isLoginMode) {
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      debugPrint('🟣 UI: New user signed up with email: $email');
    }

    // ------ Load wallet BEFORE navigating --------
    final userId = auth.currentUserId;
    if (userId != null) {
      await context.read<WalletProvider>().loadWallet(userId);
    }

    // ------ Navigate to NavScreen --------
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, NavScreen.routeName);  
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  @override
Widget build(BuildContext context) {
  final titleText = _isLoginMode
      ? 'Stock Market | Login'
      : 'Stock Market | Signup';

  final mainTitleText = _isLoginMode
      ? 'Login to your account'
      : 'Create a new account';

  final mainButtonText = _isLoginMode ? 'Login' : 'Sign Up';
  final toggleText = _isLoginMode
      ? "Don't have an account? Sign up"
      : "Already have an account? Login";

  return Scaffold(
    appBar: AppBar(
      title: Text(titleText),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            mainTitleText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
            const SizedBox(height: 24),

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm password (only in signup mode)
            if (!_isLoginMode)
              Column(
                children: [
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Main button (Login or Sign Up)
            ElevatedButton(
              onPressed: _submit,
              child: Text(mainButtonText),
            ),
            const SizedBox(height: 8),

            // Toggle between Login and Signup
            TextButton(
              onPressed: _toggleMode,
              child: Text(toggleText),
            ),
          ],
        ),
      ),
    );
  }
}