import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'error_screen.dart';
import 'forgot_password_screen.dart';
import 'task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isSignUp = false;
  String? _inlineError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSignUp) {
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
      if (email.isEmpty || !emailRegex.hasMatch(email)) {
        setState(() {
          _inlineError = 'Enter a valid email';
        });
        return;
      }

      if (password.length < 6) {
        setState(() {
          _inlineError = 'Password must be at least 6 characters';
        });
        return;
      }
    } else {
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _inlineError = 'Invalid credentials';
        });
        return;
      }
    }

    setState(() {
      _inlineError = null;
    });

    // Check internet connectivity
    bool hasInternet = true;
    try {
      final lookup = await InternetAddress.lookup('google.com');
      if (lookup.isEmpty || lookup[0].rawAddress.isEmpty) {
        hasInternet = false;
      }
    } on SocketException catch (_) {
      hasInternet = false;
    } catch (_) {
      // In case lookup is unsupported or fails
    }

    if (!hasInternet) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ErrorScreen(
            title: 'No Internet Connection',
            message:
                'Please check your internet connection and try again to continue.',
            onRetry: _handleSubmit,
          ),
        ),
      );
      return;
    }

    bool success;
    if (_isSignUp) {
      success = await authProvider.signUpWithEmail(email, password);
    } else {
      success = await authProvider.signInWithEmail(email, password);
    }

    if (!mounted) return;

    if (success) {
      if (_isSignUp) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Account Created',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'Your account has been created successfully. Welcome to FireTask!',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskListScreen()),
                  );
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TaskListScreen()),
        );
      }
    } else {
      if (_isSignUp) {
        final code = authProvider.errorCode;
        final msg = authProvider.errorMessage ?? '';
        if (code == 'email-already-in-use' ||
            msg.toLowerCase().contains('already in use')) {
          setState(() {
            _inlineError = 'Looks like you already have an account';
          });
        } else if (code == 'invalid-email' ||
            msg.toLowerCase().contains('invalid email')) {
          setState(() {
            _inlineError = 'Enter a valid email';
          });
        } else if (code == 'weak-password') {
          setState(() {
            _inlineError = 'Password must be at least 6 characters';
          });
        } else if (code == 'network-request-failed' || code == 'unknown') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ErrorScreen(
                title: 'Sign Up Error',
                message: msg.isNotEmpty
                    ? msg
                    : 'We couldn’t create your account right now. Please check your internet connection.',
                onRetry: _handleSubmit,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ErrorScreen(
                title: 'Sign Up Failed',
                message: msg.isNotEmpty
                    ? msg
                    : 'An unexpected error occurred during account creation.',
                onRetry: _handleSubmit,
              ),
            ),
          );
        }
      } else {
        final code = authProvider.errorCode;
        if (code == 'network-request-failed') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ErrorScreen(
                title: 'Connection Error',
                message:
                    'Unable to reach the server. Please check your internet connection and try again.',
                onRetry: _handleSubmit,
              ),
            ),
          );
        } else {
          setState(() {
            _inlineError = 'Invalid credentials';
          });
        }
      }
    }
  }

  void _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TaskListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimaryOf(context),
          ),
          onPressed: () {
            if (_isSignUp) {
              setState(() {
                _isSignUp = false;
                _inlineError = null;
              });
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Lottie Animation: register.json for SignUp, send user.json for SignIn
                Center(
                  child: _isSignUp
                      ? Lottie.asset(
                          'assets/register.json',
                          width: 200,
                          height: 165,
                          fit: BoxFit.contain,
                        )
                      : SizedBox(
                          width: 200,
                          height: 165,
                          child: Transform.translate(
                            offset: const Offset(0, 16),
                            child: Transform.scale(
                              scale: 1.45,
                              child: Lottie.asset(
                                'assets/send user.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 4),

                // Welcome Back Header
                Center(
                  child: Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _isSignUp
                        ? 'Sign up to organize your tasks with FireTask'
                        : 'Sign in to your FireTask Manager',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMutedOf(context),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Email Field with label and placeholder inside
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {
                    if (_inlineError != null) setState(() => _inlineError = null);
                  },
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryOf(context),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      size: 20,
                      color: AppColors.textMutedOf(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field with label and placeholder inside
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) {
                    if (_inlineError != null) setState(() => _inlineError = null);
                  },
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryOf(context),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: AppColors.textMutedOf(context),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textMutedOf(context),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                if (!_isSignUp) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordScreen(
                              initialEmail: _emailController.text.trim(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],

                // Inline Error Card (Duplicate Email / Invalid Email / Validation)
                if (_inlineError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2B1315)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF7F1D1D)
                            : const Color(0xFFFCA5A5),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _inlineError!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFFECACA)
                                      : const Color(0xFF991B1B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_inlineError == 'Looks like you already have an account') ...[
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSignUp = false;
                                _inlineError = null;
                              });
                            },
                            child: Text(
                              'Login instead →',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Login / Sign Up Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: authProvider.isLoading ? null : _handleSubmit,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUp ? 'Sign Up' : 'Login',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider: "or continue with"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.borderOf(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'or continue with',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMutedOf(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.borderOf(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Sign In Button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.borderOf(context),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                  ),
                  onPressed: _handleGoogleSignIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/google.svg',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Switch Between Sign In / Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _inlineError = null;
                        });
                      },
                      child: Text(
                        _isSignUp ? 'Login' : 'Sign Up',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer
              ],
            ),
          ),
        ),
      ),
    );
  }
}
