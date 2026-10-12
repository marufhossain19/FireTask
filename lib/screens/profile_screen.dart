import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fcm_token_bottom_sheet.dart';
import '../widgets/feedback_bottom_sheet.dart';
import '../widgets/set_password_bottom_sheet.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final email = authProvider.userEmail;
    final displayName = email.contains('@') ? email.split('@').first : 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final total = taskProvider.totalCount;
    final completed = taskProvider.completedCount;
    final pending = taskProvider.pendingCount;
    final completionRate = total > 0 ? ((completed / total) * 100).toInt() : 0;

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar with online status
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Display Name
                    Text(
                      displayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryOf(context),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMutedOf(context),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Badge: Sync Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: taskProvider.isOffline
                            ? (isDark
                                ? const Color(0xFF450A0A).withValues(alpha: 0.5)
                                : const Color(0xFFFEE2E2))
                            : (isDark
                                ? const Color(0xFF451A03).withValues(alpha: 0.5)
                                : const Color(0xFFFEF3C7)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: taskProvider.isOffline
                              ? (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5))
                              : (isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            taskProvider.isOffline
                                ? Icons.cloud_off_rounded
                                : Icons.local_fire_department_rounded,
                            size: 14,
                            color: taskProvider.isOffline
                                ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                                : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            taskProvider.isOffline
                                ? 'Offline Mode'
                                : 'Firebase Cloud Synced',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: taskProvider.isOffline
                                  ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                                  : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Task Statistics Section
              Text(
                'TASK STATISTICS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMutedOf(context),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // 2x2 Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      isDark: isDark,
                      title: 'Total Tasks',
                      value: '$total',
                      icon: Icons.list_alt_rounded,
                      iconColor: AppColors.primary,
                      iconBg: const Color(0xFFEEF2FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      isDark: isDark,
                      title: 'Completed',
                      value: '$completed',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      iconBg: const Color(0xFFECFDF5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      isDark: isDark,
                      title: 'Pending',
                      value: '$pending',
                      icon: Icons.pending_actions_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      iconBg: const Color(0xFFFEF3C7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      isDark: isDark,
                      title: 'Completion Rate',
                      value: '$completionRate%',
                      icon: Icons.donut_large_rounded,
                      iconColor: const Color(0xFF6366F1),
                      iconBg: const Color(0xFFF5F3FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Settings & Info
              Text(
                'ACCOUNT & SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMutedOf(context),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    // Dark Mode Toggle Tile
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 20,
                          color: isDark ? const Color(0xFFA5B4FC) : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Deep black OLED appearance',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeTrackColor: AppColors.darkPrimary,
                        onChanged: (val) => themeProvider.toggleTheme(val),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    _buildSettingsTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.notifications_active_rounded,
                      title: 'FCM Device Token',
                      subtitle: 'Tap to view & copy token for push alerts',
                      onTap: () => FCMTokenBottomSheet.show(context),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    _buildSettingsTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.lock_outline_rounded,
                      title: 'Set Account Password',
                      subtitle: authProvider.hasPasswordProvider
                          ? 'Change or update your account password'
                          : 'Set a password for email & password login',
                      onTap: () => SetPasswordBottomSheet.show(context),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    _buildSettingsTile(
                      context: context,
                      isDark: isDark,
                      icon: Icons.rate_review_outlined,
                      title: 'Share your feedback',
                      subtitle: 'Send suggestions or thoughts to developer',
                      onTap: () => FeedbackBottomSheet.show(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign Out Button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5),
                      width: 1.2,
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF1F1212)
                        : const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Sign Out',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to sign out of your account?',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await authProvider.signOut();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStatCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.16) : iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSettingsTile({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E212B) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        ),
      ),
      onTap: onTap,
    );
  }
}
