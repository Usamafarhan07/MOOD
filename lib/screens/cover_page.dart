import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood/widgets/firestore_image.dart';

class CoverPage extends StatelessWidget {
  const CoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirestoreService().getAppConfigStream('cover_page'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: colorScheme.surface,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }
              final imageUrl = firstFirestoreImageUrl(
                snapshot.data?.data() ?? <String, dynamic>{},
                sourcePath: 'config/cover_page',
              );
              if (imageUrl.isEmpty) {
                return Container(
                  color: const Color(0xFF1E1A18),
                );
              }
              return FirestoreImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                backgroundColor: const Color(0xFF1E1A18),
              );
            },
          ),

          // Subtle overlay for depth
          Container(
            color: colorScheme.surface.withValues(alpha: 0.30),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                child: Center(
                  child: Text(
                    'MOOD',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.0,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content Overlay
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),


                  // Tagline
                  Text(
                    'THE CURATED COLLECTION',
                    style: textTheme.labelMedium?.copyWith(
                      fontSize: 10,
                      letterSpacing: 5.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Headline
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Modern\n',
                          style: GoogleFonts.notoSerif(
                            fontSize: 56,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.02 * 56,
                            color: colorScheme.primary,
                          ),
                        ),
                        TextSpan(
                          text: 'Elegance',
                          style: GoogleFonts.notoSerif(
                            fontSize: 56,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.02 * 56,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Refined by Design',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Body text
                  SizedBox(
                    width: 320,
                    child: Text(
                      'Experience a minimalist approach to luxury. A sanctuary of style defined by simplicity and impeccable craftsmanship.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // CTA Button
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 56,
                          vertical: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'ENTER MOOD',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
