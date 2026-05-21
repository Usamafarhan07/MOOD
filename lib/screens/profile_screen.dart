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
  final TextEditingController _passwordController = TextEditingController();
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
    _passwordController.dispose();
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

      if (profile != null) {
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
        setState(() {
          _profile = profile;
          if (profile != null) {
            _nameController.text = profile.fullName;
            _phoneController.text = profile.phone;
            _addressController.text = profile.address;
            _emailController.text = profile.email;
            _passwordController.clear();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
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

  void _showEditProfileSheet(BuildContext context) {
    String? validationError;

    bool validateProfileForm() {
      if (_nameController.text.trim().isEmpty &&
          _phoneController.text.trim().isEmpty &&
          _addressController.text.trim().isEmpty &&
          _emailController.text.trim().isEmpty &&
          _passwordController.text.isEmpty) {
        validationError = 'At least one field must be provided';
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
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
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
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter new email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Leave empty to keep current',
                    border: OutlineInputBorder(
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
                            validationError ?? 'Please fill in all fields',
                          ),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                      return;
                    }

                    try {
                      // 1. Perform high-security Auth updates before persisting the profile email.
                      final user = FirebaseAuth.instance.currentUser;
                      bool authUpdated = true;
                      String? authErrorMessage;
                      String? savedEmail = _profile?.email;

                      if (user != null) {
                        final newEmail = _emailController.text.trim();
                        final newPassword = _passwordController.text;

                        try {
                          if (newEmail.isNotEmpty && newEmail != user.email) {
                            await user.verifyBeforeUpdateEmail(newEmail);
                            savedEmail = user.email ?? savedEmail;
                          } else {
                            savedEmail = user.email ?? savedEmail;
                          }
                          if (newPassword.isNotEmpty) {
                            await user.updatePassword(newPassword);
                          }
                        } on FirebaseAuthException catch (e) {
                          authUpdated = false;
                          if (e.code == 'requires-recent-login') {
                            authErrorMessage =
                                'For security, changing email or password requires logging in again. Please log out and back in first.';
                          } else {
                            authErrorMessage =
                                e.message ?? 'Failed to update credentials.';
                          }
                        } catch (e) {
                          authUpdated = false;
                          authErrorMessage = e.toString();
                        }
                      }

                      if (!authUpdated) {
                        throw FirebaseAuthException(
                          code: 'profile-auth-update-failed',
                          message: authErrorMessage,
                        );
                      }

                      // 2. Update Firestore after Auth succeeds so profile email stays consistent.
                      await _firestoreService.updateUserProfile(
                        fullName: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        address: _addressController.text.trim(),
                        email: savedEmail,
                      );

                      // Update local profile state
                      if (mounted) {
                        setState(() {
                          if (_profile != null) {
                            _profile = UserProfile(
                              uid: _profile!.uid,
                              fullName: _nameController.text.trim(),
                              email: savedEmail ?? _profile!.email,
                              phone: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                              profileImageBase64: _profile!.profileImageBase64,
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
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
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
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                              Icon(
                                Icons.credit_card,
                                color: colorScheme.onPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            '****  ****  ****  $last4',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary,
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
                                    color: colorScheme.onPrimary.withValues(
                                      alpha: 0.75,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'VALID THRU ${expiryMonth ?? 'MM'}/${expiryYear ?? 'YY'}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary.withValues(
                                    alpha: 0.75,
                                  ),
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
                        onTap: _pickImage,
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name & Email
                      Text(
                        _profile?.fullName ?? 'User Name',
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
