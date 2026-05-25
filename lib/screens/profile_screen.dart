import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:mood/services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isUploading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _cardholderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      var profile = await _firestoreService.getUserProfile();
      
      final currentProfile = profile;
      if (mounted && currentProfile != null) {
        setState(() {
          _profile = currentProfile;
          _isLoading = false;
          _nameController.text = currentProfile.fullName;
          _phoneController.text = currentProfile.phone;
          _addressController.text = currentProfile.address;
          _emailController.text = currentProfile.email;
        });
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      final authEmail = currentUser?.email ?? '';
      final authDisplayName = currentUser?.displayName?.trim() ?? '';
      final fallbackName = _nameFromAuth(
        displayName: authDisplayName,
        email: authEmail,
      );

      if (profile == null && currentUser != null) {
        await _firestoreService.createUserProfile(
          uid: currentUser.uid,
          fullName: fallbackName,
          email: authEmail,
        );
        profile = await _firestoreService.getUserProfile();
      }

      if (profile != null) {
        final repairedName = profile.fullName.trim().isEmpty
            ? fallbackName
            : profile.fullName.trim();
        final repairedEmail =
            profile.email.trim().isEmpty && authEmail.isNotEmpty
            ? authEmail
            : profile.email.trim();

        if (repairedName != profile.fullName ||
            repairedEmail != profile.email) {
          await _firestoreService.updateUserProfile(
            fullName: repairedName,
            phone: profile.phone,
            address: profile.address,
            email: repairedEmail,
          );
          profile = UserProfile(
            uid: profile.uid,
            fullName: repairedName,
            email: repairedEmail,
            phone: profile.phone,
            address: profile.address,
            profileImageBase64: profile.profileImageBase64,
            paymentMethod: profile.paymentMethod,
            createdAt: profile.createdAt,
            ordersCount: profile.ordersCount,
            points: profile.points,
          );
        }

        // MIGRATION: Dynamically compute actual orders and points
        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: profile.uid)
            .get();

        int actualOrders = ordersSnapshot.size;
        int totalSpent = 0;
        for (var doc in ordersSnapshot.docs) {
          totalSpent += (doc.data()['totalPrice'] as num?)?.toInt() ?? 0;
        }
        int actualPoints = totalSpent ~/ 100; // 1 point per 100 LKR spent

        if (profile.ordersCount != actualOrders ||
            profile.points != actualPoints) {
          profile = UserProfile(
            uid: profile.uid,
            fullName: profile.fullName,
            email: profile.email,
            phone: profile.phone,
            address: profile.address,
            profileImageBase64: profile.profileImageBase64,
            paymentMethod: profile.paymentMethod,
            createdAt: profile.createdAt,
            ordersCount: actualOrders,
            points: actualPoints,
          );
        }
      }

      if (mounted) {
        if (profile != null &&
            authEmail.isNotEmpty &&
            profile.email != authEmail) {
          await _firestoreService.updateUserProfile(
            fullName: profile.fullName,
            phone: profile.phone,
            address: profile.address,
            email: authEmail,
          );
          profile = UserProfile(
            uid: profile.uid,
            fullName: profile.fullName,
            email: authEmail,
            phone: profile.phone,
            address: profile.address,
            profileImageBase64: profile.profileImageBase64,
            paymentMethod: profile.paymentMethod,
            createdAt: profile.createdAt,
            ordersCount: profile.ordersCount,
            points: profile.points,
          );
        }

        setState(() {
          _profile = profile;
          if (profile != null) {
            _nameController.text = profile.fullName;
            _phoneController.text = profile.phone;
            _addressController.text = profile.address;
            _emailController.text = profile.email;
            _currentPasswordController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
          }
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: ${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _nameFromAuth({required String displayName, required String email}) {
    if (displayName.trim().isNotEmpty) return displayName.trim();
    if (email.trim().isEmpty) return 'User Name';
    final emailName = email.split('@').first.trim();
    if (emailName.isEmpty) return 'User Name';
    return emailName
        .split(RegExp(r'[._\-\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  String get _profileDisplayName {
    final profileName = _profile?.fullName.trim() ?? '';
    if (profileName.isNotEmpty) return profileName;
    final user = FirebaseAuth.instance.currentUser;
    return _nameFromAuth(
      displayName: user?.displayName?.trim() ?? '',
      email: user?.email ?? _profile?.email ?? '',
    );
  }

  void _showProfilePhotoOptions() {
    final hasPhoto =
        _profile?.profileImageBase64 != null &&
        _profile!.profileImageBase64!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Profile Photo',
                  style: GoogleFonts.notoSerif(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPhotoAction(
                  icon: Icons.photo_camera_outlined,
                  label: 'Take Photo',
                  theme: theme,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                _buildPhotoAction(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from Gallery',
                  theme: theme,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (hasPhoto) ...[
                  const SizedBox(height: 10),
                  _buildPhotoAction(
                    icon: Icons.delete_outline,
                    label: 'Remove Photo',
                    theme: theme,
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfilePhoto();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final fileSize = await pickedFile.length();
      const maxSize = 1024 * 1024; // 1MB

      if (fileSize > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image size must be less than 1MB for database storage',
              ),
            ),
          );
        }
        return;
      }

      setState(() => _isUploading = true);
      final bytes = await pickedFile.readAsBytes();
      final base64String = await _firestoreService.uploadProfileImageBase64(
        bytes,
      );

      if (mounted) {
        setState(() {
          _profile = UserProfile(
            uid: _profile!.uid,
            fullName: _profile!.fullName,
            email: _profile!.email,
            phone: _profile!.phone,
            address: _profile!.address,
            profileImageBase64: base64String,
            paymentMethod: _profile!.paymentMethod,
            createdAt: _profile!.createdAt,
            ordersCount: _profile!.ordersCount,
            points: _profile!.points,
          );
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    if (_profile == null) return;

    try {
      setState(() => _isUploading = true);
      await _firestoreService.removeProfileImage();

      if (!mounted) return;
      setState(() {
        _profile = UserProfile(
          uid: _profile!.uid,
          fullName: _profile!.fullName,
          email: _profile!.email,
          phone: _profile!.phone,
          address: _profile!.address,
          paymentMethod: _profile!.paymentMethod,
          createdAt: _profile!.createdAt,
          ordersCount: _profile!.ordersCount,
          points: _profile!.points,
        );
        _isUploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo removed')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove photo: ${e.toString()}')),
      );
    }
  }

  void _showEditProfileSheet(BuildContext context) {
    _currentPasswordController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    String? validationError;
    final parentContext = context;

    bool validateProfileForm() {
      validationError = null;
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        validationError = 'Full name cannot be empty';
        return false;
      }

      return true;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, refreshSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.notoSerif(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        hintText: 'Enter your phone number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter your delivery address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _showAccountSecuritySheet(parentContext);
                          }
                        });
                      },
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('CHANGE EMAIL & PASSWORD'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (!validateProfileForm()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                validationError ?? 'Please check the form',
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                          return;
                        }

                        try {
                          await _firestoreService.updateUserProfile(
                            fullName: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                            address: _addressController.text.trim(),
                          );

                          if (mounted) {
                            setState(() {
                              if (_profile != null) {
                                _profile = UserProfile(
                                  uid: _profile!.uid,
                                  fullName: _nameController.text.trim(),
                                  email: _profile!.email,
                                  phone: _phoneController.text.trim(),
                                  address: _addressController.text.trim(),
                                  profileImageBase64:
                                      _profile!.profileImageBase64,
                                  paymentMethod: _profile!.paymentMethod,
                                  createdAt: _profile!.createdAt,
                                  ordersCount: _profile!.ordersCount,
                                  points: _profile!.points,
                                );
                              }
                            });
                          }

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.message ?? 'Failed to update profile.',
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to update profile: ${e.toString()}',
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('SAVE CHANGES'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAccountSecuritySheet(BuildContext context) {
    final parentContext = context;
    final currentEmail =
        FirebaseAuth.instance.currentUser?.email ?? _profile?.email ?? '';
    _emailController.text = currentEmail;
    _currentPasswordController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    String? emailError;
    String? currentPasswordError;
    String? newPasswordError;
    String? confirmPasswordError;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    bool validateSecurityForm() {
      emailError = null;
      currentPasswordError = null;
      newPasswordError = null;
      confirmPasswordError = null;
      final email = _emailController.text.trim();
      final currentPassword = _currentPasswordController.text;
      final newPassword = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final isEmailChanging = email.isNotEmpty && email != currentEmail;
      final isPasswordChanging = newPassword.isNotEmpty;

      if (email.isEmpty) {
        emailError = 'Email cannot be empty';
        return false;
      }
      if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
        emailError = 'Please enter a valid email address';
        return false;
      }
      if (!isEmailChanging && !isPasswordChanging) {
        newPasswordError = 'Change your email or enter a new password';
        return false;
      }
      if (currentPassword.isEmpty) {
        currentPasswordError = 'Current password is required';
        return false;
      }
      if (isPasswordChanging && newPassword.length < 8) {
        newPasswordError = 'New password must be at least 8 characters';
        return false;
      }
      if (isPasswordChanging &&
          (!RegExp(r'[A-Za-z]').hasMatch(newPassword) ||
              !RegExp(r'\d').hasMatch(newPassword))) {
        newPasswordError = 'Use letters and numbers';
        return false;
      }
      if (isPasswordChanging && confirmPassword.isEmpty) {
        confirmPasswordError = 'Please confirm your new password';
        return false;
      }
      if (isPasswordChanging && confirmPassword != newPassword) {
        confirmPasswordError = 'New passwords do not match';
        return false;
      }
      return true;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, refreshSheet) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _showEditProfileSheet(parentContext);
                              }
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Change Email & Password',
                            style: GoogleFonts.notoSerif(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter new email',
                        errorText: emailError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => refreshSheet(() {
                        emailError = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        errorText: currentPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrentPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => refreshSheet(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          }),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => refreshSheet(() {
                        currentPasswordError = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        errorText: newPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => refreshSheet(() {
                            obscureNewPassword = !obscureNewPassword;
                          }),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => refreshSheet(() {
                        newPasswordError = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        errorText: confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => refreshSheet(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          }),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => refreshSheet(() {
                        confirmPasswordError = null;
                      }),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (!validateSecurityForm()) {
                          refreshSheet(() {});
                          return;
                        }

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null || user.email == null) {
                            throw FirebaseAuthException(
                              code: 'no-current-user',
                              message: 'Please log in again.',
                            );
                          }

                          final newEmail = _emailController.text.trim();
                          final newPassword = _passwordController.text;
                          final previousEmail = user.email!;
                          final isEmailChanging = newEmail != previousEmail;
                          final isPasswordChanging = newPassword.isNotEmpty;
                          var statusMessage = 'Account security updated';

                          final credential = EmailAuthProvider.credential(
                            email: previousEmail,
                            password: _currentPasswordController.text,
                          );
                          await user.reauthenticateWithCredential(credential);

                          if (isPasswordChanging) {
                            await user.updatePassword(newPassword);
                          }
                          if (isEmailChanging) {
                            await user.verifyBeforeUpdateEmail(newEmail);
                            statusMessage =
                                'Password saved. Verify the email we sent to $newEmail before logging in with it.';
                          }

                          await _firestoreService.updateUserProfile(
                            fullName: _profile?.fullName ?? '',
                            phone: _profile?.phone ?? '',
                            address: _profile?.address ?? '',
                            email: previousEmail,
                          );

                          if (mounted) {
                            setState(() {
                              if (_profile != null) {
                                _profile = UserProfile(
                                  uid: _profile!.uid,
                                  fullName: _profile!.fullName,
                                  email: previousEmail,
                                  phone: _profile!.phone,
                                  address: _profile!.address,
                                  profileImageBase64:
                                      _profile!.profileImageBase64,
                                  paymentMethod: _profile!.paymentMethod,
                                  createdAt: _profile!.createdAt,
                                  ordersCount: _profile!.ordersCount,
                                  points: _profile!.points,
                                );
                              }
                              _currentPasswordController.clear();
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            });
                          }

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(statusMessage)),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (!context.mounted) return;
                          refreshSheet(() {
                            switch (e.code) {
                              case 'wrong-password':
                              case 'invalid-credential':
                                currentPasswordError =
                                    'Current password is incorrect';
                              case 'email-already-in-use':
                                emailError =
                                    'This email is already used by another account';
                              case 'invalid-email':
                                emailError = 'Please enter a valid email';
                              case 'weak-password':
                                newPasswordError =
                                    'Use at least 8 characters with letters and numbers';
                              case 'requires-recent-login':
                                currentPasswordError =
                                    'Please enter your current password again';
                              case 'too-many-requests':
                                currentPasswordError =
                                    'Too many attempts. Try again later';
                              case 'operation-not-allowed':
                                emailError =
                                    'Verify the new email before logging in with it';
                              default:
                                final message = e.message ?? '';
                                if (message.toLowerCase().contains('email')) {
                                  emailError = message;
                                } else {
                                  currentPasswordError = message.isEmpty
                                      ? 'Failed to update email or password'
                                      : message;
                                }
                            }
                          });
                        } catch (e) {
                          if (!context.mounted) return;
                          refreshSheet(() {
                            currentPasswordError =
                                'Failed to update account. Please try again';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('SAVE EMAIL & PASSWORD'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentMethodSheet(BuildContext context) {
    final paymentMethod = _profile?.paymentMethod;
    _cardholderController.text =
        paymentMethod?['cardholderName']?.toString() ??
        _profile?.fullName ??
        '';
    _cardNumberController.clear();
    _expiryMonthController.text =
        paymentMethod?['expiryMonth']?.toString() ?? '';
    _expiryYearController.text = paymentMethod?['expiryYear']?.toString() ?? '';
    _cvcController.clear();

    String? validationError;

    bool validateCardForm() {
      validationError = null;
      final digitsOnly = _cardNumberController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final month = _expiryMonthController.text.trim().padLeft(2, '0');
      final year = _expiryYearController.text.trim();
      final cvc = _cvcController.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (_cardholderController.text.trim().isEmpty) {
        validationError = 'Please enter the cardholder name';
        return false;
      }
      if (digitsOnly.isEmpty && paymentMethod == null) {
        validationError = 'Please enter your card number';
        return false;
      }
      if (digitsOnly.isNotEmpty &&
          (digitsOnly.length < 4 || digitsOnly.length > 19)) {
        validationError = 'Please enter a valid card number';
        return false;
      }
      if (!RegExp(r'^(0[1-9]|1[0-2])$').hasMatch(month)) {
        validationError = 'Expiry month must be between 01 and 12';
        return false;
      }
      if (!RegExp(r'^\d{2}$').hasMatch(year)) {
        validationError = 'Expiry year must be two digits';
        return false;
      }
      if (!RegExp(r'^\d{3,4}$').hasMatch(cvc)) {
        validationError = 'Please enter the CVC';
        return false;
      }
      return true;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return StatefulBuilder(
          builder: (context, refreshSheet) {
            final paymentMethod = _profile?.paymentMethod;
            final hasSavedCard = paymentMethod?['last4'] != null;
            final enteredDigits = _cardNumberController.text.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            final enteredLast4 = enteredDigits.length >= 4
                ? enteredDigits.substring(enteredDigits.length - 4)
                : null;
            final last4 =
                enteredLast4 ?? (paymentMethod?['last4'])?.toString() ?? '0000';
            final expiryMonth = _expiryMonthController.text.trim().isEmpty
                ? (paymentMethod?['expiryMonth'])?.toString()
                : _expiryMonthController.text.trim().padLeft(2, '0');
            final expiryYear = _expiryYearController.text.trim().isEmpty
                ? (paymentMethod?['expiryYear'])?.toString()
                : _expiryYearController.text.trim();
            final previewName = _cardholderController.text.trim().isEmpty
                ? 'CARDHOLDER NAME'
                : _cardholderController.text.trim().toUpperCase();

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Payment Method',
                      style: GoogleFonts.notoSerif(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0B57D0),
                            Color(0xFF1434CB),
                            Color(0xFF071D73),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1434CB,
                            ).withValues(alpha: 0.28),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'VISA',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Icon(
                                  Icons.credit_card,
                                  color: Color(0xFF1434CB),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            '****  ****  ****  $last4',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  previewName,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'VALID THRU ${expiryMonth ?? 'MM'}/${expiryYear ?? 'YY'}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _cardholderController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => refreshSheet(() {}),
                      decoration: InputDecoration(
                        labelText: 'Cardholder Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      onChanged: (_) => refreshSheet(() {}),
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Card Number',
                        hintText: !hasSavedCard
                            ? '4111 1111 1111 1111'
                            : 'Leave empty to keep **** $last4',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryMonthController,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            onChanged: (_) => refreshSheet(() {}),
                            decoration: InputDecoration(
                              counterText: '',
                              labelText: 'MM',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _expiryYearController,
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            onChanged: (_) => refreshSheet(() {}),
                            decoration: InputDecoration(
                              counterText: '',
                              labelText: 'YY',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'CVC',
                        hintText: '3 digits',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CVC and full card number are used only for verification and are not saved.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (!validateCardForm()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                validationError ?? 'Check card details',
                              ),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                          return;
                        }

                        final digitsOnly = _cardNumberController.text
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        final existingLast4 = _profile?.paymentMethod?['last4']
                            ?.toString();
                        final last4 = digitsOnly.isEmpty
                            ? existingLast4 ?? ''
                            : digitsOnly.substring(digitsOnly.length - 4);

                        try {
                          await _firestoreService.updatePaymentMethod(
                            cardholderName: _cardholderController.text.trim(),
                            last4: last4,
                            expiryMonth: _expiryMonthController.text
                                .trim()
                                .padLeft(2, '0'),
                            expiryYear: _expiryYearController.text.trim(),
                          );
                          if (!mounted) return;
                          setState(() {
                            _profile = UserProfile(
                              uid: _profile!.uid,
                              fullName: _profile!.fullName,
                              email: _profile!.email,
                              phone: _profile!.phone,
                              address: _profile!.address,
                              profileImageBase64: _profile!.profileImageBase64,
                              paymentMethod: {
                                'brand': 'Visa',
                                'cardholderName': _cardholderController.text
                                    .trim(),
                                'last4': last4,
                                'expiryMonth': _expiryMonthController.text
                                    .trim()
                                    .padLeft(2, '0'),
                                'expiryYear': _expiryYearController.text.trim(),
                              },
                              createdAt: _profile!.createdAt,
                              ordersCount: _profile!.ordersCount,
                              points: _profile!.points,
                            );
                          });
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Card saved')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save card: $e'),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('SAVE CARD'),
                    ),
                    if (hasSavedCard) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          try {
                            await _firestoreService.removePaymentMethod();
                            if (!mounted) return;
                            setState(() {
                              _profile = UserProfile(
                                uid: _profile!.uid,
                                fullName: _profile!.fullName,
                                email: _profile!.email,
                                phone: _profile!.phone,
                                address: _profile!.address,
                                profileImageBase64:
                                    _profile!.profileImageBase64,
                                createdAt: _profile!.createdAt,
                                ordersCount: _profile!.ordersCount,
                                points: _profile!.points,
                              );
                            });
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Visa card removed'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to remove card: $e'),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'REMOVE CARD',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ],
                  ],
                ),
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
              title: Text(
                'MOOD',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  color: colorScheme.primary,
                ),
              ),
              centerTitle: true,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: colorScheme.primary,
                      ),
                      onPressed: () {
                        context.push('/notifications');
                      },
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 120,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                children: [
                  // Profile Identity
                  Column(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: _isUploading ? null : _showProfilePhotoOptions,
                        child: Container(
                          width: 128,
                          height: 128,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFFD4C3BE,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipOval(
                                child:
                                    _profile?.profileImageBase64 != null &&
                                        _profile!.profileImageBase64!.isNotEmpty
                                    ? Image.memory(
                                        base64Decode(
                                          _profile!.profileImageBase64!,
                                        ),
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        gaplessPlayback: true,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                      )
                                    : Container(
                                        width: 120,
                                        height: 120,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              if (_isUploading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isUploading
                                      ? null
                                      : () => _pickImage(ImageSource.camera),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name & Email
                      Text(
                        _profileDisplayName,
                        style: GoogleFonts.notoSerif(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile?.email ?? 'email@example.com',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF827470),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Summary Bento Grid
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'ORDERS',
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 2.0,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _profile?.ordersCount.toString() ?? '0',
                                style: GoogleFonts.notoSerif(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'POINTS',
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 2.0,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _profile?.points.toString() ?? '0',
                                style: GoogleFonts.notoSerif(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Navigation Menu
                  Column(
                    children: [
                      _buildMenuCard(
                        icon: Icons.person_outline,
                        label: 'Edit Profile',
                        onTap: () => _showEditProfileSheet(context),
                        theme: theme,
                      ),
                      const SizedBox(height: 10),
                      _buildMenuCard(
                        icon: Icons.shopping_bag_outlined,
                        label: 'My Orders',
                        onTap: () {
                          context.push('/order_history');
                        },
                        theme: theme,
                      ),
                      const SizedBox(height: 10),
                      _buildMenuCard(
                        icon: Icons.favorite_outline,
                        label: 'My Wishlist',
                        onTap: () {
                          context.push('/wishlist');
                        },
                        theme: theme,
                      ),
                      const SizedBox(height: 10),
                      _buildMenuCard(
                        icon: Icons.payment_outlined,
                        label: 'Payment Methods',
                        onTap: () => _showPaymentMethodSheet(context),
                        theme: theme,
                      ),
                      const SizedBox(height: 10),
                      _buildMenuCard(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => context.push('/settings'),
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  GestureDetector(
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (_) {}
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: const Color(0xFFC0392B),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFC0392B),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // MOOD Club Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'The MOOD Club',
                          style: GoogleFonts.notoSerif(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'EXCLUSIVE EARLY ACCESS & INVITATIONS',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 2.0,
                            color: colorScheme.onPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.onPrimary,
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'VIEW PRIVILEGES',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 32,
                left: 32,
                right: 32,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 'HOME', false, () {
                    context.go('/home');
                  }, colorScheme),
                  _buildNavItem(Icons.search, 'SEARCH', false, () {
                    context.go('/products');
                  }, colorScheme),
                  _buildNavItem(
                    Icons.shopping_cart_outlined,
                    'CART',
                    false,
                    () {
                      context.go('/cart');
                    },
                    colorScheme,
                  ),
                  _buildNavItem(
                    Icons.person,
                    'PROFILE',
                    true,
                    () {},
                    colorScheme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: colorScheme.primary.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: colorScheme.primary.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAction({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = theme.colorScheme;
    final actionColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: actionColor.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: actionColor),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: actionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? colorScheme.primary
                : colorScheme.primary.withValues(alpha: 0.4),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
