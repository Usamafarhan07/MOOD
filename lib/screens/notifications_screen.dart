import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood/services/firestore_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? status;
  final String time;
  final String? imageUrl;
  final IconData? icon;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.status,
    required this.time,
    this.imageUrl,
    this.icon,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Push Notifications Preferences
  bool _soundAlerts = true;
  bool _orderUpdates = true;
  bool _newDrops = true;

  // Selected Notification IDs
  final Set<String> _selectedIds = {};

  // List of active notifications in local state
  late List<NotificationItem> _notifications;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationItem(
        id: '1',
        imageUrl: '',
        title: 'Order #ATL-8829-0142 is being prepared with artisanal care',
        status: 'In Production',
        time: '2h ago',
      ),
      NotificationItem(
        id: '2',
        icon: Icons.auto_awesome,
        title: 'New Arrival: The Winter Silk Collection is now available',
        subtitle:
            'Discover fluidity in structure with our latest artisanal drop.',
        time: '5h ago',
      ),
      NotificationItem(
        id: '3',
        icon: Icons.favorite,
        title: 'Style Alert: Pieces you loved are back in stock',
        subtitle:
            'The L\'Artiste Trousers in Midnight Sand have returned to our atelier.',
        time: 'Yesterday',
      ),
      NotificationItem(
        id: '4',
        icon: Icons.mail_outlined,
        title: 'Your monthly style digest is here',
        time: '3 days ago',
        isRead: true, // Set to true to faded by default
      ),
    ];
    _loadNotificationImages();
  }

  Future<void> _loadNotificationImages() async {
    final url = await _firestoreService.getAppConfigUrl('notifications_order');
    if (mounted && url != null && url.isNotEmpty) {
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == '1');
        if (idx != -1) {
          _notifications[idx] = NotificationItem(
            id: _notifications[idx].id,
            imageUrl: url,
            title: _notifications[idx].title,
            status: _notifications[idx].status,
            time: _notifications[idx].time,
            isRead: _notifications[idx].isRead,
          );
        }
      });
    }
  }

  // Toggle selection of a notification
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // Delete selected notifications with Undo support
  void _deleteSelected() {
    if (_selectedIds.isEmpty) return;

    final selectedItems = _notifications
        .where((n) => _selectedIds.contains(n.id))
        .toList();
    final List<int> originalIndices = [];
    for (var item in selectedItems) {
      originalIndices.add(_notifications.indexOf(item));
    }

    setState(() {
      _notifications.removeWhere((n) => _selectedIds.contains(n.id));
      _selectedIds.clear();
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedItems.length} notifications deleted',
          style: GoogleFonts.manrope(
            color: isDark ? const Color(0xFF16100E) : const Color(0xFFFCF9F4),
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: isDark ? const Color(0xFFA04022) : const Color(0xFFFE8763),
          onPressed: () {
            setState(() {
              for (int i = 0; i < selectedItems.length; i++) {
                _notifications.insert(originalIndices[i], selectedItems[i]);
              }
            });
          },
        ),
      ),
    );
  }

  // Show push notification preferences bottom sheet
  void _showPreferencesSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF231B19)
                    : const Color(0xFFFCF9F4),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Bottom Sheet Handle
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NOTIFICATION SETTINGS',
                    style: GoogleFonts.notoSerif(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(indent: 28, endIndent: 28, height: 1),
                  const SizedBox(height: 12),

                  // Option 1: Sound Alerts
                  _buildSwitchTile(
                    title: 'Sound & Vibration',
                    subtitle: 'Play smooth alerts when new updates arrive',
                    value: _soundAlerts,
                    onChanged: (val) {
                      setSheetState(() => _soundAlerts = val);
                      setState(() => _soundAlerts = val);
                    },
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),

                  // Option 2: Order Updates
                  _buildSwitchTile(
                    title: 'Order Status updates',
                    subtitle:
                        'Get notified as your garments are created and prepared',
                    value: _orderUpdates,
                    onChanged: (val) {
                      setSheetState(() => _orderUpdates = val);
                      setState(() => _orderUpdates = val);
                    },
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),

                  // Option 3: New Drops
                  _buildSwitchTile(
                    title: 'New Collections',
                    subtitle:
                        'Be the first to discover structured artisanal drops',
                    value: _newDrops,
                    onChanged: (val) {
                      setSheetState(() => _newDrops = val);
                      setState(() => _newDrops = val);
                    },
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Switch Tile Helper
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.secondary.withValues(alpha: 0.3),
            inactiveThumbColor: colorScheme.primary.withValues(alpha: 0.4),
            inactiveTrackColor: colorScheme.surfaceContainerLow,
          ),
        ],
      ),
    );
  }

  // Clear all notifications
  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
      _selectedIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All notifications cleared',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelectionMode = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.7),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                isSelectionMode ? Icons.close : Icons.arrow_back,
                color: colorScheme.primary,
              ),
              onPressed: () {
                if (isSelectionMode) {
                  setState(() {
                    _selectedIds.clear();
                  });
                } else {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                }
              },
            ),
            title: Text(
              isSelectionMode
                  ? '${_selectedIds.length} Selected'
                  : 'Notifications',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
                color: colorScheme.primary,
              ),
            ),
            centerTitle: false,
            actions: [
              if (isSelectionMode)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE63946),
                  ),
                  onPressed: _deleteSelected,
                )
              else
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.primary),
                  onSelected: (value) {
                    if (value == 'read') {
                      setState(() {
                        for (var n in _notifications) {
                          n.isRead = true;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'All notifications marked as read',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    } else if (value == 'settings') {
                      _showPreferencesSheet();
                    } else if (value == 'clear') {
                      _clearAllNotifications();
                    }
                  },
                  offset: const Offset(0, 48),
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF231B19)
                      : const Color(0xFFFCF9F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'read',
                      child: Row(
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mark all read',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Settings',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_sweep_outlined,
                            size: 18,
                            color: Color(0xFFE63946),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Clear all',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: const Color(0xFFE63946),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.notoSerif(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Recent Activity Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      'RECENT ACTIVITY',
                      style: GoogleFonts.notoSerif(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 2.0,
                        color: colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Load notifications dynamically
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final isSelected = _selectedIds.contains(item.id);

                      if (item.imageUrl != null) {
                        return _buildOrderNotification(
                          context: context,
                          item: item,
                          isSelected: isSelected,
                          theme: theme,
                        );
                      } else {
                        return _buildIconNotification(
                          context: context,
                          item: item,
                          isSelected: isSelected,
                          theme: theme,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(48),
            topRight: Radius.circular(48),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 40,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(48),
            topRight: Radius.circular(48),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 40,
              left: 32,
              right: 32,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home_outlined, 'HOME', false, () {
                  context.go('/home');
                }, colorScheme),
                _buildNavItem(Icons.search, 'SEARCH', false, () {
                  context.go('/products');
                }, colorScheme),
                _buildNavItem(Icons.shopping_cart_outlined, 'CART', false, () {
                  context.go('/cart');
                }, colorScheme),
                _buildNavItem(Icons.person_outline, 'PROFILE', false, () {
                  context.go('/profile');
                }, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderNotification({
    required BuildContext context,
    required NotificationItem item,
    required bool isSelected,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _toggleSelection(item.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : (item.isRead
                      ? colorScheme.surfaceContainerLow.withValues(alpha: 0.5)
                      : colorScheme.surfaceContainerLow),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection indicator or Product Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 64,
                      height: 80,
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.saturation,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceContainer,
                          child: Icon(
                            Icons.image,
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF2F2421)
                              : const Color(0xFFFCF9F4),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.notoSerif(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        color: item.isRead
                            ? colorScheme.primary.withValues(alpha: 0.5)
                            : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          item.status!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4C3BE),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.time.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconNotification({
    required BuildContext context,
    required NotificationItem item,
    required bool isSelected,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine premium dynamic icon branding colors
    Color iconBgColor = colorScheme.primary;
    Color iconColor = colorScheme.surface;

    if (item.icon == Icons.favorite) {
      iconBgColor = colorScheme.secondary.withValues(alpha: 0.2);
      iconColor = colorScheme.secondary;
    } else if (item.icon == Icons.mail_outlined) {
      iconBgColor = colorScheme.surfaceContainer;
      iconColor = colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => _toggleSelection(item.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : (item.isRead
                      ? colorScheme.surfaceContainerLow.withValues(alpha: 0.5)
                      : colorScheme.surfaceContainerLow),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Circle or Check Indicator
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: iconColor, size: 22),
                  ),
                  if (isSelected)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: isDark
                              ? const Color(0xFF2F2421)
                              : const Color(0xFFFCF9F4),
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.notoSerif(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        color: item.isRead
                            ? colorScheme.primary.withValues(alpha: 0.5)
                            : colorScheme.primary,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                          height: 1.6,
                          color: item.isRead
                              ? colorScheme.primary.withValues(alpha: 0.3)
                              : colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      item.time.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.0,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
