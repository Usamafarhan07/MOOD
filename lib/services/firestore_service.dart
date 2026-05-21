import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'dart:convert';

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
      price:
          (data['price'] as int?) ??
          int.tryParse(data['price']?.toString() ?? '') ??
          0,
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
      price:
          (data['price'] as int?) ??
          int.tryParse(data['price']?.toString() ?? '') ??
          0,
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
  static const String _cartSubcollection = 'cart';
  static const String _wishlistSubcollection = 'wishlist';
  static const String _ordersCollection = 'orders';
  static const int _cacheSize = 10 * 1024 * 1024; // 10MB

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService() {
    _firestore.settings = Settings(
      cacheSizeBytes: _cacheSize,
      persistenceEnabled: true,
    );
  }

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

  CollectionReference<Map<String, dynamic>> get _cartCollection => _firestore
      .collection(_usersCollection)
      .doc(_currentUser.uid)
      .collection(_cartSubcollection);

  CollectionReference<Map<String, dynamic>> get _wishlistCollection =>
      _firestore
          .collection(_usersCollection)
          .doc(_currentUser.uid)
          .collection(_wishlistSubcollection);

  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts({
    String? label,
    String? category,
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

    try {
      final docRef = await _firestore
          .collection(_ordersCollection)
          .add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
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

  Future<UserProfile?> getUserProfile() async {
    try {
      final doc = await usersCollection.doc(_currentUser.uid).get();
      if (doc.exists) {
        return UserProfile.fromSnapshot(doc);
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
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<String> uploadProfileImageBase64(Uint8List imageBytes) async {
    try {
      final fileSize = imageBytes.length;
      // Even compressed, base64 inflates by ~33%. Allow 1MB limit for safety in Firestore
      const maxSize = 1024 * 1024; // 1MB
      if (fileSize > maxSize) {
        throw ArgumentError(
          'Image size exceeds 1MB limit for Firestore Base64',
        );
      }

      final base64String = base64Encode(imageBytes);

      await usersCollection.doc(_currentUser.uid).set({
        'profileImageBase64': base64String,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return base64String;
    } catch (e) {
      throw Exception('Failed to upload profile image as Base64: $e');
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

  Future<void> migrateProductDetails() async {
    try {
      final querySnapshot = await products.get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final updates = <String, dynamic>{};

        // If composition is missing, set a premium default
        if (!data.containsKey('composition')) {
          updates['composition'] = [
            '80% Organic Wool',
            '20% Recycled Cashmere',
          ];
        }

        // If careInstructions is missing, set a premium default
        if (!data.containsKey('careInstructions')) {
          updates['careInstructions'] = [
            'Dry clean only. Do not wash. Do not bleach. Cool iron if needed.',
          ];
        }

        // If shippingDetails is missing, set a premium default
        if (!data.containsKey('shippingDetails')) {
          updates['shippingDetails'] = [
            'Standard Delivery: 3-5 business days. Free on all orders.',
          ];
        }

        // If sustainability is missing, set a premium default
        if (!data.containsKey('sustainability')) {
          updates['sustainability'] = [
            'Ethically crafted in our certified carbon-neutral facility.',
            'Shipped in 100% biodegradable and zero-plastic packaging.',
          ];
        }

        if (updates.isNotEmpty) {
          batch.update(doc.reference, updates);
        }
      }

      await batch.commit();
      debugPrint('Firestore product migration complete successfully!');

      // Auto seed/update premium category-wise products
      await seedPremiumProducts();
    } catch (e) {
      debugPrint('Error during Firestore product migration: $e');
    }
  }

  Future<void> seedPremiumProducts() async {
    try {
      final batch = _firestore.batch();
      final premiumProducts = [
        {
          'id': 'piece_1',
          'title': 'Double-Breasted Wool Trench',
          'category': 'Women',
          'label': 'Outerwear',
          'price': 'LKR 32,000',
          'subtitle': 'Outerwear • Beige',
          'imageUrl':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuANAwip_SplPsYu1rJwkTzQhd_dzGfh7uwXF0FI3F-lHpKmm5fpStr79od52os4NJR4zKgA6YLcksH08K2xjqwFQ_t1UtmjWQ1dHnpN_mwWn62EzDGyfWzFZEtCXUH14YWQn1CZS7i3FWARs0HcMcn_lCmVj1ETrrheRRAmjb8BUn4ZMZdBRJWc645GfXKUxY_Pzln4Cwihl3FeCLSR7D_OIzUzKHgS4gZonctdAlCElek4Ccedqtuc8Yna01YsiQB3fB40mQN1EKs',
          'composition': ['85% Virgin Wool', '15% Silk Lining'],
          'careInstructions': ['Professional dry clean only', 'Do not iron'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': [
            'Crafted from certified animal-friendly organic wool.',
          ],
        },
        {
          'id': 'piece_2',
          'title': 'Oversized Cashmere Knitwear',
          'category': 'Women',
          'label': 'Knitwear',
          'price': 'LKR 24,000',
          'subtitle': 'Knitwear • Cream',
          'imageUrl':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCW6NAFE9Gwty6Xcs4XZyOa4mIeb_jNiN__C94O1OjjjbJATRlpiV5SFL80Jf4aCQMpmI-GJyKwPEeeWLzEEkUQF3V1ajISaydZ_SskVyJocbaQ24klUXlwL-ED0piMrMX9GwbF0kgmRjkNorp9dQFtEPNMWO1x1xF52_xh3qbfsEBQamzSnFbCgSCkdf56ZukXh3wyWi4oI5ifk5HrTFcjxJVdSZXlu8dFriUE7NPoCtjPth2XjP9_EtNG4QIzy4mpkEmRpOMhwCM',
          'composition': ['100% Mongolian Cashmere'],
          'careInstructions': ['Hand wash cold', 'Lay flat to dry'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Sourced from sustainable cashmere farms.'],
        },
        {
          'id': 'piece_3',
          'title': 'Structured Tailored Blazer',
          'category': 'Men',
          'label': 'Outerwear',
          'price': 'LKR 28,500',
          'subtitle': 'Outerwear • Charcoal',
          'imageUrl':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDalJJRcFLKp8me8gCX4iZwv9MZbOr8c8djfIs7ucQtqRtzkWp7u2QIFuq2vmnw6qPkZfsUYPloKl3caYqisyw__lXUNmS41iD1NcoS8zHPcr4AIXpxUjE6dC5FrTZbGHrgSUX9plEgJejQxR1QZ1uxjxmZRTzxgaw5hDWv6tiMBsGwxB1P9WpKvJpoi4xP_AfE9Akq42xRlbqu1PRV6mC3RaVQR9VbMtipWNQ7KmFphHGG_SAA2kRsEoUE8KI3GeepBGFugirO42A',
          'composition': ['90% Organic Cotton', '10% Elastane'],
          'careInstructions': ['Dry clean only'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Crafted with GOTS-certified organic cotton.'],
        },
        {
          'id': 'piece_4',
          'title': 'Merino Wool Crewneck',
          'category': 'Men',
          'label': 'Knitwear',
          'price': 'LKR 19,000',
          'subtitle': 'Knitwear • Olive Green',
          'imageUrl':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCtOnOOXGA2BDQydlnHCriYfQhXOuDXPi0asqNWUtsOsiqzq04udrkH3ks1A1LnMBCgNkcjN0LwOnDyMHeA4uVRbGMffd3N59C_ix6Gdp2nwjQHUYb03VoEX9AaR_Ci_ev0xmR2CsipxnX6I9PXOD0FNzXl6KyQkjeZCroPE6RDVI-1bZRLrhRupZx-u6feWiBpPJHrAHhDrUoaHYkXsYBufQae32TE-rg-hReKolFDH9xPRVcGh9IcYTGdC5ZUXyqk6k_8I3CLpeQ',
          'composition': ['100% Merino Wool'],
          'careInstructions': ['Hand wash cold', 'Do not tumble dry'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Ethically sourced non-mulesed wool.'],
        },
        {
          'id': 'piece_5',
          'title': 'Minimalist Chelsea Boots',
          'category': 'Men',
          'label': 'Footwear',
          'price': 'LKR 35,000',
          'subtitle': 'Footwear • Black Leather',
          'imageUrl':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAr920s20Va1_M_FurAXZbIyZOoWP1ykudNH5htiRYaRRcf3quveFwAprJEET9RkH8Oiwcj30MV9o3kOVdMIpXlLPWve5pjndW_0DO15tkA5gVFO9FYl29uoAwt9KHQD7qq8PT9gvIE0nOQo1DTcqjwdGn_d-rNbyhNXf6ILyvwctY_a-WnC6H9M3ilObVlvO4hG4vbIkFIWJ9M5FwOmJmZCaVaCzKDQcwSjES6QWSONjhYAki6rXwtQB8qBRqjsTfrhctAoRk64l0',
          'composition': ['100% Full-Grain Calf Leather', 'Rubber Lug Sole'],
          'careInstructions': [
            'Clean with damp cloth',
            'Apply leather conditioner',
          ],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Gold-certified Italian tannery leather.'],
        },
        {
          'id': 'piece_6',
          'title': 'Classic Leather Shoulder Bag',
          'category': 'Women',
          'label': 'Accessories',
          'price': 'LKR 18,500',
          'subtitle': 'Accessories • Tan Leather',
          'imageUrl':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAIn5WZW2ZDB4zjyxPNbGauGMQV6b6n02Qq9FcFCDNzo1Scyan92LXmaEin6R9HRVc4pxfy0RQNtnNRKFCP1V5AnWLBloZe7XXj2JLStM4N873D6Kh4nEG_vmuBstdQWQ_4XguzhcStP47IyZxlqsdTud45WPWsW0m-RQRIioOL457ip_xSRRrUHhVj4F1garOElFHdmRW_h7Kl7M7xOTzHra-nIWs3Z2QN2oPxebOXRLE5Du1iiUkzMvSIVKKxRsygM-3ErwqV8zE',
          'composition': ['100% Full-Grain Leather'],
          'careInstructions': ['Avoid water contact', 'Use leather cleaner'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Vegetable-tanned chemical-free leather.'],
        },
        {
          'id': 'piece_7',
          'title': 'Wool Felt Wide-Brim Hat',
          'category': 'Women',
          'label': 'Accessories',
          'price': 'LKR 9,500',
          'subtitle': 'Accessories • Beige',
          'imageUrl':
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDmARXl_xj3ePXQapUG07ZDS75Y4eJoXZlQ3IS3bCLzBpgSTLMwUdhLPAzBvJv6_OPgl_PpPmYR78WPuk33Bx8wSzFanfsc6kE3zgkrQqy-WriyN4pBsVMEuyybk6lT4iTakt6bWMYY_Usn6uGN8ukopQTIK6rd-BswB-8qKnUJleUWKk-_lEm6NR0zg-1j-7C44pULX3msduzlOZBu7rjI_5GPvskCFAXC3eP4Wk_-DUOtLK4CdjWTJKV-cuCat2pJUgc0PigIVYY',
          'composition': ['100% Premium Wool Felt'],
          'careInstructions': ['Lint roll to clean', 'Store in hat box'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Biodegradable and naturally sourced wool.'],
        },
        {
          'id': 'piece_8',
          'title': 'Organic Cotton Kids Trench',
          'category': 'Kids',
          'label': 'Outerwear',
          'price': 'LKR 15,000',
          'subtitle': 'Outerwear • Beige',
          'imageUrl':
              'https://images.unsplash.com/photo-1622290319146-7b63df48a635?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['100% Organic Cotton'],
          'careInstructions': ['Machine wash warm', 'Tumble dry low'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['GOTS-certified toxic-free baby cotton.'],
        },
        {
          'id': 'piece_9',
          'title': 'Chunky Knit Kids Cardigan',
          'category': 'Kids',
          'label': 'Knitwear',
          'price': 'LKR 12,500',
          'subtitle': 'Knitwear • Mustard',
          'imageUrl':
              'https://images.unsplash.com/photo-1519457431-44ccd64a579b?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['80% Organic Cotton', '20% Wool'],
          'careInstructions': ['Machine wash cold', 'Dry flat'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Naturally dyed organic fibers.'],
        },
        {
          'id': 'piece_10',
          'title': 'Minimalist Suede Loafers',
          'category': 'Women',
          'label': 'Footwear',
          'price': 'LKR 22,000',
          'subtitle': 'Footwear • Beige Suede',
          'imageUrl':
              'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['100% Genuine Suede', 'Leather Sole'],
          'careInstructions': [
            'Brush gently with suede brush',
            'Apply suede protector',
          ],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': [
            'Handmade by artisans using certified eco-leather.',
          ],
        },
        {
          'id': 'piece_11',
          'title': 'Premium Kids Woolen Set',
          'category': 'Kids',
          'label': 'Knitwear',
          'price': 'LKR 17,500',
          'subtitle': 'Knitwear • Neutral Gray',
          'imageUrl':
              'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['90% Organic Cotton', '10% Cashmere'],
          'careInstructions': ['Machine wash gentle cold', 'Lay flat to dry'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': [
            'Naturally sourced and dyed fibers, zero plastic.',
          ],
        },
        {
          'id': 'piece_12',
          'title': 'Classic Minimalist Overcoat',
          'category': 'Men',
          'label': 'Outerwear',
          'price': 'LKR 31,000',
          'subtitle': 'Outerwear • Charcoal Gray',
          'imageUrl':
              'https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['90% Cashmere Wool', '10% Mulberry Silk'],
          'careInstructions': ['Professional dry clean only', 'Do not iron'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Crafted from certified organic wool.'],
        },
        {
          'id': 'piece_13',
          'title': 'Structured Linen Overshirt',
          'category': 'Men',
          'label': 'Outerwear',
          'price': 'LKR 16,500',
          'subtitle': 'Shirts • Sand Beige',
          'imageUrl':
              'https://images.unsplash.com/photo-1617137968427-85924c800a22?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['100% Premium Belgian Linen'],
          'careInstructions': ['Machine wash cold gentle', 'Hang to dry'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Naturally derived eco-friendly linen fibers.'],
        },
        {
          'id': 'piece_14',
          'title': 'Modern Leather Derby',
          'category': 'Men',
          'label': 'Footwear',
          'price': 'LKR 26,000',
          'subtitle': 'Footwear • Onyx Black',
          'imageUrl':
              'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['100% Full Grain Leather', 'Durable Rubber Sole'],
          'careInstructions': [
            'Clean with damp cloth',
            'Use leather conditioner',
          ],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': [
            'Handmade by artisans using certified eco-leather.',
          ],
        },
        {
          'id': 'piece_15',
          'title': 'Premium Silk-Blend Bomber',
          'category': 'Men',
          'label': 'Outerwear',
          'price': 'LKR 29,500',
          'subtitle': 'Outerwear • Midnight Blue',
          'imageUrl':
              'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=600&h=800&q=80',
          'composition': ['60% Mulberry Silk', '40% Organic Cotton'],
          'careInstructions': ['Dry clean only', 'Cool iron if needed'],
          'shippingDetails': ['Free standard delivery on all orders.'],
          'sustainability': ['Made with ethically sourced silk fibers.'],
        },
      ];

      for (final p in premiumProducts) {
        final docRef = products.doc(p['id'] as String);
        batch.set(docRef, p);
      }
      await batch.commit();
      debugPrint('Seeded Premium Products successfully!');
    } catch (e) {
      debugPrint('Error seeding premium products: $e');
    }
  }
}
