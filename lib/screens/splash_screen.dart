import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Firebase is already initialized in main.dart before runApp().
    // Initialize notifications here (requires widget binding to be ready).
    await NotificationService().initialize();

    // Extended delay (3.2s) so the Lottie tick animation can play through completely
    await Future.delayed(const Duration(milliseconds: 3200));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TaskListScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Tick animation Lottie
            Lottie.asset(
              'assets/Tick animation - success feedback.json',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
              repeat: false,
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'FireTask',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryOf(context),
                  ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Smart & seamless task management',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMutedOf(context),
                      height: 1.4,
                    ),
              ),
            ),
            const Spacer(flex: 3),
            // Loading indicator & text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16, width: 10),
                Text(
                  'Initializing app...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMutedOf(context),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
