# Technical Report

## 1. Current App Architecture

- `lib/main.dart`
  - Initializes Firebase with `Firebase.initializeApp(...)` using `firebase_options.dart`.
  - Creates and runs `MyApp` with `MaterialApp.router`.
  - Uses `createAppRouter()` from `lib/router/app_router.dart`.

- Routing
  - `GoRouter` handles app navigation.
  - Routes:
    - `/` → `CoverPage`
    - `/login` → `LoginScreen`
    - `/register` → `RegistrationScreen`
    - `/home` → `HomeScreen`
    - `/products` → `ProductListingScreen`
    - `/product_details` → `ProductDetailsScreen`
    - `/cart` → `ShoppingCartScreen`
    - `/checkout` → `CheckoutScreen`
    - `/order_confirmation` → `OrderConfirmationScreen`
    - `/order_details` → `OrderDetailsScreen`
    - `/wishlist` → `WishlistScreen`
    - `/profile` → `ProfileScreen`
    - `/notifications` → `NotificationsScreen`

## 2. Firebase Authentication

- `LoginScreen`:
  - Validates email format and password length.
  - Uses `FirebaseAuth.instance.signInWithEmailAndPassword`.
  - Shows contextual Snackbar messages for common Firebase errors.

- `RegistrationScreen`:
  - Validates full name, email, password, confirm password, and terms acceptance.
  - Uses `FirebaseAuth.instance.createUserWithEmailAndPassword`.
  - Updates the Firebase user display name after registration.
  - Redirects to `/home` on success.

- Auth routing guard:
  - `AuthChangeNotifier` listens to `FirebaseAuth.instance.authStateChanges()`.
  - Redirect logic:
    - Authenticated users are forwarded from auth pages (`/`, `/login`, `/register`) to `/home`.
    - Unauthenticated users trying to access protected pages are redirected to `/login`.

## 3. Firestore Product Integration

- `lib/services/firestore_service.dart`
  - Provides `FirestoreService.getProducts()`.
  - Streams `FirebaseFirestore.instance.collection('products').snapshots()`.

- `HomeScreen`
  - Uses `StreamBuilder<QuerySnapshot>` to load featured product cards from Firestore.
  - Applies text search on `title`.
  - Displays a responsive two-column product grid.

- `ProductListingScreen`
  - Uses the same Firestore stream to render the full product catalogue.
  - Supports:
    - Search by title
    - Category filter via labels (`All Items`, `Outerwear`, `Knitwear`, `Accessories`, `Footwear`)
  - Converts each Firestore document to a `Map<String, dynamic>` including `id`.

- `ProductDetailsScreen`
  - Receives selected product metadata through `GoRouter` `state.extra`.
  - Renders product detail using fields such as `title`, `price`, `label`, and `imageUrl`.
  - Falls back to default placeholder values if `productData` is missing.

## 4. Product & Cart Flow

- Wishlist
  - `HomeScreen`, `ProductListingScreen`, and `ProductDetailsScreen` all support saving/removing favorites.
  - Wishlist is stored in-memory in `globalWishlistItems`.
  - `WishlistScreen` reads from that shared list and supports navigation back to products.

- Cart
  - `ShoppingCartScreen` and `WishlistScreen` use an in-memory global list `globalCartItems`.
  - `CartItem` is a simple data class with:
    - `id`
    - `imageUrl`
    - `title`
    - `subtitle`
    - `unitPrice`
    - `quantity`
  - Cart UI supports increment/decrement, removal, undo removal, and summary totals.
  - `CheckoutScreen` routes to `/order_confirmation` but does not persist orders to Firestore.

## 5. State Management

- App state is currently managed via:
  - `FirebaseAuth` for auth state
  - `StreamBuilder` for Firestore product data
  - Global in-memory lists for cart and wishlist state
- No additional state management framework (Redux/MobX/Provider/Bloc) is present.

## 6. Theming

- `lib/theme/app_theme.dart`
  - Defines a custom Material 3 `ThemeData`.
  - Brand palette:
    - `primary`: `#442A22`
    - `secondary`: `#A04022`
    - `surface`: `#FCF9F4`
    - `surfaceContainerLow`: `#F6F3EE`
    - `surfaceContainerHigh`: `#EBE8E3`
  - Uses Google Fonts:
    - `Noto Serif` for display/headlines
    - `Manrope` for body/UI text

## 7. Cleanup Summary

- Legacy migration code was removed safely.
- There is no `product_migration.dart` or similar dead migration helper present in the workspace.
- Current Firebase integration is focused on:
  - Auth flows
  - Firestore read-only product queries
- No UI redesign was introduced.
- The app retains its original styled layout and navigation flow.

## 8. Known Implementation Notes

- Firestore product data is read-only. The app does not currently write product, order, or user-specific wishlist/cart data to Firestore.
- Cart and wishlist are not persisted across app restarts.
- Product details rely on `state.extra`; if navigation occurs without passing product data, defaults are used.

## 9. Key Files

- `lib/main.dart`
- `lib/router/app_router.dart`
- `lib/services/firestore_service.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/registration_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/product_listing_screen.dart`
- `lib/screens/product_details_screen.dart`
- `lib/screens/wishlist_screen.dart`
- `lib/screens/shopping_cart_screen.dart`
- `lib/theme/app_theme.dart`

If you want, I can also produce a short "what changed" summary for the code cleanup specifically.
