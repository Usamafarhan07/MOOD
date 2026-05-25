import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood/widgets/firestore_image.dart';

int parsePriceValue(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(
        value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '',
      ) ??
      0;
}

class CartItem {
  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  final int price;
  final int quantity;
  final DateTime addedAt;
  final String? subtitle;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.addedAt,
    this.subtitle,
  });

  factory CartItem.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return CartItem(
      id: snapshot.id,
      productId: data['productId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      price: parsePriceValue(data['price']),
      quantity: (data['quantity'] as int?) ?? 1,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subtitle: data['subtitle'] as String?,
    );
  }

  String get formattedPrice {
    return 'LKR ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}

class WishlistItem {
  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  final int price;
  final DateTime addedAt;
  final String? subtitle;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.addedAt,
    this.subtitle,
  });

  factory WishlistItem.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return WishlistItem(
      id: snapshot.id,
      productId: data['productId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      price: parsePriceValue(data['price']),
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subtitle: data['subtitle'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'subtitle': subtitle,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}

class UserNotification {
  final String id;
  final String title;
  final String? subtitle;
  final String? status;
  final String? imageUrl;
  final String? icon;
  final String time;
  final bool isRead;
  final DateTime createdAt;

  UserNotification({
    required this.id,
    required this.title,
    this.subtitle,
    this.status,
    this.imageUrl,
    this.icon,
    required this.time,
    required this.isRead,
    required this.createdAt,
  });

  factory UserNotification.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final createdAt = _dateFromValue(data['createdAt']);

    return UserNotification(
      id: snapshot.id,
      title: data['title']?.toString() ?? '',
      subtitle: _nullableString(data['subtitle']),
      status: _nullableString(data['status']),
      imageUrl: _nullableString(data['imageUrl']),
      icon: _nullableString(data['icon']),
      time: _nullableString(data['time']) ?? _formatRelativeTime(createdAt),
      isRead: data['isRead'] == true,
      createdAt: createdAt,
    );
  }

  static DateTime _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays} days ago';
  }
}

class OrderItem {
  final String productId;
  final String title;
  final String imageUrl;
  final int quantity;
  final int unitPrice;

  OrderItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unitPrice'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

class Order {
  final String orderId;
  final String userId;
  final String userEmail;
  final List<OrderItem> items;
  final int totalPrice;
  final int subtotal;
  final int shippingFee;
  final int taxFee;
  final String orderStatus;
  final DateTime createdAt;
  final String paymentMethod;
  final Map<String, dynamic> shippingAddress;

  Order({
    required this.orderId,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalPrice,
    required this.subtotal,
    required this.shippingFee,
    required this.taxFee,
    required this.orderStatus,
    required this.createdAt,
    required this.paymentMethod,
    required this.shippingAddress,
  });

  factory Order.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Order(
      orderId: snapshot.id,
      userId: data['userId'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (data['totalPrice'] as num?)?.toInt() ?? 0,
      subtotal: (data['subtotal'] as num?)?.toInt() ?? 0,
      shippingFee: (data['shippingFee'] as num?)?.toInt() ?? 0,
      taxFee: (data['taxFee'] as num?)?.toInt() ?? 0,
      orderStatus: data['orderStatus'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: data['paymentMethod'] as String? ?? '',
      shippingAddress: data['shippingAddress'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'taxFee': taxFee,
      'orderStatus': orderStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
    };
  }
}

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String? profileImageBase64;
  final String? profileImageUrl;
  final Map<String, dynamic>? paymentMethod;
  final DateTime createdAt;
  final int ordersCount;
  final int points;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    this.profileImageBase64,
    this.profileImageUrl,
    this.paymentMethod,
    required this.createdAt,
    this.ordersCount = 0,
    this.points = 0,
  });

  factory UserProfile.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return UserProfile(
      uid: snapshot.id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      profileImageBase64: data['profileImageBase64'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      paymentMethod: data['paymentMethod'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ordersCount: (data['ordersCount'] as num?)?.toInt() ?? 0,
      points: (data['points'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImageBase64': profileImageBase64,
      'profileImageUrl': profileImageUrl,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'ordersCount': ordersCount,
      'points': points,
    };
  }
}

class FirestoreService {
  static const String _usersCollection = 'users';
  static const String _productsCollection = 'products';
  static const String _homeBannersCollection = 'home_banners';
  static const String _cartSubcollection = 'cart';
  static const String _wishlistSubcollection = 'wishlist';
  static const String _notificationsSubcollection = 'notifications';
  static const String _ordersCollection = 'orders';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService();

  User get _currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'User must be signed in to access Firestore data.',
      );
    }
    return user;
  }

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection(_usersCollection);

  CollectionReference<Map<String, dynamic>> get products =>
      _firestore.collection(_productsCollection);

  CollectionReference<Map<String, dynamic>> get homeBanners =>
      _firestore.collection(_homeBannersCollection);

  Stream<QuerySnapshot<Map<String, dynamic>>> getHomeBanners() {
    try {
      return homeBanners.snapshots();
    } catch (e) {
      throw Exception('Failed to fetch home banners: $e');
    }
  }

  CollectionReference<Map<String, dynamic>> get _cartCollection => _firestore
      .collection(_usersCollection)
      .doc(_currentUser.uid)
      .collection(_cartSubcollection);

  CollectionReference<Map<String, dynamic>> get _wishlistCollection =>
      _firestore
          .collection(_usersCollection)
          .doc(_currentUser.uid)
          .collection(_wishlistSubcollection);

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      _firestore
          .collection(_usersCollection)
          .doc(_currentUser.uid)
          .collection(_notificationsSubcollection);

  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts({
    String? label,
    String? category,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query = products
          .withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? {},
            toFirestore: (data, _) => data,
          );
      if (label != null && label != 'All Items') {
        query = query.where('label', isEqualTo: label);
      }
      if (category != null && category != 'All Items') {
        if (category == 'Accessories') {
          query = query.where('label', isEqualTo: 'Accessories');
        } else {
          query = query.where('category', isEqualTo: category);
        }
      }
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }
      return query.snapshots();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProductById(
    String productId,
  ) async {
    try {
      return await products.doc(productId).get();
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCartStream() {
    try {
      return _cartCollection
          .orderBy('addedAt', descending: true)
          .limit(100)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getWishlistStream() {
    try {
      return _wishlistCollection
          .orderBy('addedAt', descending: true)
          .limit(100)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAppConfigStream(
    String key,
  ) {
    try {
      return _firestore.collection('config').doc(key).snapshots();
    } catch (e) {
      throw Exception('Failed to fetch app config: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream() {
    try {
      return _notificationsCollection
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      final docs = await _notificationsCollection.limit(100).get();
      if (docs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in docs.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  Future<void> deleteNotifications(Iterable<String> notificationIds) async {
    final ids = notificationIds.where((id) => id.trim().isNotEmpty).toList();
    if (ids.isEmpty) return;

    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_notificationsCollection.doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete notifications: $e');
    }
  }

  Future<void> addOrUpdateCartItem({
    required String productId,
    required String title,
    required String imageUrl,
    required int price,
    int quantity = 1,
    String? subtitle,
  }) async {
    if (quantity <= 0) throw ArgumentError('Quantity must be positive');
    if (productId.isEmpty) throw ArgumentError('Product ID cannot be empty');

    try {
      final existingQuery = await _cartCollection
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final doc = existingQuery.docs.first;
        final existingQuantity = (doc.data()['quantity'] as int?) ?? 1;
        await doc.reference.update({
          'quantity': existingQuantity + quantity,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _cartCollection.add({
          'productId': productId,
          'title': title,
          'imageUrl': imageUrl,
          'price': price,
          'quantity': quantity,
          'subtitle': subtitle,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add cart item: $e');
    }
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (cartItemId.isEmpty) throw ArgumentError('Cart item ID cannot be empty');

    try {
      if (quantity <= 0) {
        return removeCartItem(cartItemId);
      }
      await _cartCollection.doc(cartItemId).update({'quantity': quantity});
    } catch (e) {
      throw Exception('Failed to update cart quantity: $e');
    }
  }

  Future<void> removeCartItem(String cartItemId) async {
    if (cartItemId.isEmpty) throw ArgumentError('Cart item ID cannot be empty');

    try {
      await _cartCollection.doc(cartItemId).delete();
    } catch (e) {
      throw Exception('Failed to remove cart item: $e');
    }
  }

  Future<void> addWishlistItem({
    required String productId,
    required String title,
    required String imageUrl,
    required int price,
    String? subtitle,
  }) async {
    if (productId.isEmpty) throw ArgumentError('Product ID cannot be empty');

    try {
      final existingQuery = await _wishlistCollection
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existingQuery.docs.isEmpty) {
        await _wishlistCollection.add({
          'productId': productId,
          'title': title,
          'imageUrl': imageUrl,
          'price': price,
          'subtitle': subtitle,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await existingQuery.docs.first.reference.update({
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add wishlist item: $e');
    }
  }

  Future<void> removeWishlistItem(String productId) async {
    if (productId.isEmpty) throw ArgumentError('Product ID cannot be empty');

    try {
      final existingQuery = await _wishlistCollection
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        await existingQuery.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to remove wishlist item: $e');
    }
  }

  Future<void> removeWishlistById(String wishlistItemId) async {
    if (wishlistItemId.isEmpty) {
      throw ArgumentError('Wishlist item ID cannot be empty');
    }

    try {
      await _wishlistCollection.doc(wishlistItemId).delete();
    } catch (e) {
      throw Exception('Failed to remove wishlist item: $e');
    }
  }

  Future<String> createOrder(Order order) async {
    if (order.items.isEmpty) {
      throw ArgumentError('Order must have at least one item');
    }
    if (order.totalPrice <= 0) {
      throw ArgumentError('Order total must be positive');
    }
    if (order.totalPrice != order.subtotal + order.shippingFee + order.taxFee) {
      throw ArgumentError('Order total does not match its cost breakdown');
    }

    try {
      final docRef = await _firestore
          .collection(_ordersCollection)
          .add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<String> createOrderAndClearCart(Order order) async {
    if (order.items.isEmpty) {
      throw ArgumentError('Order must have at least one item');
    }
    if (order.totalPrice <= 0) {
      throw ArgumentError('Order total must be positive');
    }
    if (order.totalPrice != order.subtotal + order.shippingFee + order.taxFee) {
      throw ArgumentError('Order total does not match its cost breakdown');
    }

    try {
      final orderRef = _firestore.collection(_ordersCollection).doc();
      final cartDocs = await _cartCollection.get();
      final userRef = _firestore.collection(_usersCollection).doc(_currentUser.uid);
      final batch = _firestore.batch();

      batch.set(orderRef, order.toMap());
      for (final doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }

      final addedPoints = order.totalPrice ~/ 100;
      batch.update(userRef, {
        'ordersCount': FieldValue.increment(1),
        'points': FieldValue.increment(addedPoints),
      });

      await batch.commit();
      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to create order and clear cart: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserOrdersStream() {
    try {
      return _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: _currentUser.uid)
          .limit(100)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  Future<Order?> getOrder(String orderId) async {
    if (orderId.isEmpty) throw ArgumentError('Order ID cannot be empty');

    try {
      final doc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();
      if (doc.exists) {
        return Order.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (orderId.isEmpty) throw ArgumentError('Order ID cannot be empty');
    if (status.isEmpty) throw ArgumentError('Status cannot be empty');

    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final cartDocs = await _cartCollection.get();
      if (cartDocs.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // --- USER PROFILE METHODS ---

  static UserProfile? _cachedUserProfile;

  Future<UserProfile?> getUserProfile({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedUserProfile != null) {
        return _cachedUserProfile;
      }
      final doc = await usersCollection.doc(_currentUser.uid).get();
      if (doc.exists) {
        _cachedUserProfile = UserProfile.fromSnapshot(doc);
        return _cachedUserProfile;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
  }) async {
    if (uid.isEmpty) throw ArgumentError('UID cannot be empty');
    if (fullName.isEmpty) throw ArgumentError('Full name cannot be empty');
    if (email.isEmpty) throw ArgumentError('Email cannot be empty');

    try {
      final profile = UserProfile(
        uid: uid,
        fullName: fullName,
        email: email,
        phone: '',
        address: '',
        createdAt: DateTime.now(),
      );
      await usersCollection.doc(uid).set(profile.toMap());
      _cachedUserProfile = profile;
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    required String address,
    String? email,
  }) async {
    try {
      final updates = <String, dynamic>{
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (email != null && email.isNotEmpty) {
        updates['email'] = email;
      }

      await usersCollection
          .doc(_currentUser.uid)
          .set(updates, SetOptions(merge: true));
      _cachedUserProfile = null; // Invalidate cache so it fetches fresh next time
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<String> uploadProfileImageBase64(String base64String) async {
    try {
      // Firestore document size limit is 1MB (~1,048,576 bytes)
      // We check if the base64 string is too large to fit.
      if (base64String.length > 1000000) {
        throw ArgumentError('Image is too large to store in Firestore. Please select a smaller image.');
      }

      await usersCollection.doc(_currentUser.uid).set({
        'profileImageBase64': base64String,
        'profileImageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _cachedUserProfile = null;

      return base64String;
    } catch (e) {
      throw Exception('Failed to upload profile image as Base64: $e');
    }
  }

  Future<void> removeProfileImage() async {
    try {
      await usersCollection.doc(_currentUser.uid).set({
        'profileImageBase64': FieldValue.delete(),
        'profileImageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      _cachedUserProfile = null;
    } catch (e) {
      throw Exception('Failed to remove profile image: $e');
    }
  }

  Future<void> updatePaymentMethod({
    required String cardholderName,
    required String last4,
    required String expiryMonth,
    required String expiryYear,
  }) async {
    if (cardholderName.trim().isEmpty) {
      throw ArgumentError('Cardholder name cannot be empty');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(last4)) {
      throw ArgumentError('Card number must include at least 4 digits');
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])$').hasMatch(expiryMonth)) {
      throw ArgumentError('Expiry month must be 01-12');
    }
    if (!RegExp(r'^\d{2}$').hasMatch(expiryYear)) {
      throw ArgumentError('Expiry year must use two digits');
    }

    try {
      await usersCollection.doc(_currentUser.uid).set({
        'paymentMethod': {
          'brand': 'Visa',
          'cardholderName': cardholderName.trim(),
          'last4': last4,
          'expiryMonth': expiryMonth,
          'expiryYear': expiryYear,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  Future<void> removePaymentMethod() async {
    try {
      await usersCollection.doc(_currentUser.uid).set({
        'paymentMethod': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to remove payment method: $e');
    }
  }

  Future<String?> getAppConfigUrl(String key) async {
    try {
      final doc = await _firestore.collection('config').doc(key).get();
      if (doc.exists) {
        return firstFirestoreImageUrl(
          doc.data() ?? <String, dynamic>{},
          sourcePath: 'config/$key',
        );
      }
    } catch (_) {}
    return null;
  }
}
