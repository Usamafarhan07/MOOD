import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

String normalizeFirestoreImageUrl(String value) {
  final source = value.trim();
  if (source.isEmpty) return '';
  if (source.startsWith('http://') ||
      source.startsWith('https://') ||
      source.startsWith('assets/') ||
      source.startsWith('gs://')) {
    return source;
  }
  if (source.startsWith('www.')) {
    return 'https://$source';
  }
  return source;
}

String firstFirestoreImageUrl(
  Map<String, dynamic> data, {
  String sourcePath = 'unknown',
}) {
  const stringKeys = <String>[
    'imageurl',
    'imageUrl',
    'image_url',
    'imageURL',
    'image',
    'thumbnail',
    'photoUrl',
    'photoURL',
  ];

  for (final key in stringKeys) {
    final normalized = normalizeFirestoreImageUrl(data[key]?.toString() ?? '');
    if (normalized.isNotEmpty) {
      _logImageSelection(data, sourcePath, key, normalized);
      return normalized;
    }
  }

  const listKeys = <String>['images', 'imageUrls', 'image_urls', 'photos'];
  for (final key in listKeys) {
    final value = data[key];
    if (value is List) {
      for (final item in value) {
        final normalized = normalizeFirestoreImageUrl(item?.toString() ?? '');
        if (normalized.isNotEmpty) {
          _logImageSelection(data, sourcePath, key, normalized);
          return normalized;
        }
      }
    }
  }

  _logImageSelection(data, sourcePath, 'none', '');
  return '';
}

final Set<String> _loggedImageSelections = <String>{};

void _logImageSelection(
  Map<String, dynamic> data,
  String sourcePath,
  String selectedField,
  String selectedUrl,
) {
  if (!kDebugMode) return;
  final imageUrl = data['imageUrl']?.toString() ?? '';
  final imageurl = data['imageurl']?.toString() ?? '';
  final imageUrlSnake = data['image_url']?.toString() ?? '';
  final hasConflict =
      [imageUrl, imageurl, imageUrlSnake].where((value) => value.trim().isNotEmpty).length > 1;
  final key = '$sourcePath|$selectedField|$selectedUrl|$imageUrl|$imageurl|$imageUrlSnake';
  if (!hasConflict && _loggedImageSelections.contains(key)) return;
  _loggedImageSelections.add(key);

  // debugPrint(
  //   'MOOD image source: $sourcePath | selected=$selectedField | '
  //   'imageUrl=${_shorten(imageUrl)} | imageurl=${_shorten(imageurl)} | '
  //   'image_url=${_shorten(imageUrlSnake)} | final=${_shorten(selectedUrl)}',
  // );
}

String _shorten(String value) {
  final trimmed = value.trim();
  if (trimmed.length <= 90) return trimmed;
  return '${trimmed.substring(0, 45)}...${trimmed.substring(trimmed.length - 30)}';
}

class FirestoreImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? fallback;
  final Color? backgroundColor;

  const FirestoreImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.fallback,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final source = normalizeFirestoreImageUrl(imageUrl);
    if (source.isEmpty) return _fallback(context);

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallback(context),
      );
    }

    if (source.startsWith('gs://')) {
      return FutureBuilder<String>(
        future: FirebaseStorage.instance.refFromURL(source).getDownloadURL(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loading(context);
          }
          final downloadUrl = snapshot.data;
          if (downloadUrl == null || downloadUrl.isEmpty) {
            return _fallback(context);
          }
          return _network(downloadUrl);
        },
      );
    }

    if (!source.startsWith('http://') && !source.startsWith('https://')) {
      return _fallback(context);
    }

    return _network(source);
  }

  Widget _network(String source) {
    return Image.network(
      source,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _loading(context);
      },
      errorBuilder: (context, error, stackTrace) => _fallback(context),
    );
  }

  Widget _loading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: backgroundColor ?? colorScheme.surfaceContainerLow,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    if (fallback != null) return fallback!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: backgroundColor ?? colorScheme.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.primary.withValues(alpha: 0.38),
          size: 30,
        ),
      ),
    );
  }
}
