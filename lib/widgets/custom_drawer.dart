import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:mood/theme/app_theme.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final FirestoreService _firestoreService = FirestoreService();
  UserProfile? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _firestoreService.getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    int rating = 5;
    final textController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                title: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.rate_review_outlined,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MOOD Experience',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We highly value your styling feedback.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isSelected = starValue <= rating;
                        return IconButton(
                          icon: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isSelected
                                ? const Color(0xFFD4AF37)
                                : colorScheme.primary.withValues(alpha: 0.25),
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              rating = starValue;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                        ),
                      ),
                      child: TextField(
                        controller: textController,
                        maxLines: 4,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Share your thoughts, suggestions, or brand feedback...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
                actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setDialogState(() {
                                    isSubmitting = true;
                                  });

                                  // Simulate premium sending animation
                                  await Future.delayed(
                                    const Duration(milliseconds: 1200),
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: colorScheme.primary,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Feedback submitted! Thank you.',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Submit',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.94),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          border: Border(
            right: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
        ),
        child: Column(
          children: [
            // Drawer Header
            _buildHeader(theme, colorScheme),

            // Navigation Items List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.home_outlined,
                      label: 'Home',
                      route: '/home',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      context: context,
                      icon: Icons.shopping_bag_outlined,
                      label: 'Garments & Collections',
                      route: '/products',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      context: context,
                      icon: Icons.history_outlined,
                      label: 'Order History',
                      route: '/order_history',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      context: context,
                      icon: Icons.favorite_outline_rounded,
                      label: 'Wishlist & Curations',
                      route: '/wishlist',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      context: context,
                      icon: Icons.settings_outlined,
                      label: 'Account Settings',
                      route: '/settings',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 16),
                    Divider(color: colorScheme.primary.withValues(alpha: 0.08)),
                    const SizedBox(height: 16),

                    // Brand Feature: Feedback Action
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _showFeedbackDialog(context);
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.rate_review_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Feedback & Support',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Premium MOOD Club card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.08),
                            colorScheme.primary.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: Color(0xFFD4AF37),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'MOOD CLUB MEMBER',
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Earn exclusive points on premium orders and gain early access to drop selections.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Theme Mode switcher & Log out bottom block
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Theme Mode Row
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: AppTheme.themeModeNotifier,
                    builder: (context, currentThemeMode, child) {
                      final isDark = currentThemeMode == ThemeMode.dark;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: colorScheme.primary.withValues(
                                  alpha: 0.6,
                                ),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isDark ? 'Dark Mode' : 'Light Mode',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (value) {
                              AppTheme.themeModeNotifier.value = value
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            },
                            activeThumbColor: colorScheme.primary,
                            activeTrackColor: colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            inactiveThumbColor: colorScheme.primary.withValues(
                              alpha: 0.4,
                            ),
                            inactiveTrackColor:
                                colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sign out button
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: colorScheme.error.withValues(alpha: 0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Logout Account',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Profile image avatar
          _isLoadingProfile
              ? const SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _buildAvatar(colorScheme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingProfile
                      ? 'Loading...'
                      : (_profile?.fullName ?? 'MOOD Guest'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoadingProfile
                      ? 'Please wait'
                      : (_profile?.email ?? 'Join MOOD Club'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    if (_profile != null &&
        _profile!.profileImageBase64 != null &&
        _profile!.profileImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_profile!.profileImageBase64!);
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: ClipOval(child: Image.memory(bytes, fit: BoxFit.cover)),
        );
      } catch (_) {
        // Fallback to initials on decoding failure
      }
    }

    // Initials Avatar
    final nameParts = _profile?.fullName.split(' ') ?? [];
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : nameParts.isNotEmpty && nameParts[0].isNotEmpty
        ? nameParts[0][0].toUpperCase()
        : 'M';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final bool isActive = currentLocation == route;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.pop(context); // Close drawer first
          if (!isActive) {
            context.push(route);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isActive
              ? colorScheme.primary
              : colorScheme.primary.withValues(alpha: 0.5),
          size: 22,
        ),
        title: Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive
                ? colorScheme.primary
                : colorScheme.primary.withValues(alpha: 0.75),
          ),
        ),
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
