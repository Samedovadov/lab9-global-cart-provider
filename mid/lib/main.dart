
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CatalogScreen(),
      ),
    ),
  );
}

// ==========================================
// 1. PRODUCT MODEL
// ==========================================

class Product {
  final int id;
  final String name;
  final double price;
  final IconData icon;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
  });
}

// ==========================================
// 2. CART PROVIDER - GLOBAL STATE
// ==========================================

class CartProvider extends ChangeNotifier {
  final List<Product> _cartItems = [];

  // List of selected products
  List<Product> get items =>
      List.unmodifiable(_cartItems);

  // Number of products
  int get count => _cartItems.length;

  // Total price
  double get totalPrice {
    return _cartItems.fold<double>(
      0.0,
      (sum, product) => sum + product.price,
    );
  }

  // Check if product is in cart
  bool isInCart(Product product) {
    return _cartItems.any(
      (item) => item.id == product.id,
    );
  }

  // Add or remove product
  void toggleItem(Product product) {
    if (isInCart(product)) {
      _cartItems.removeWhere(
        (item) => item.id == product.id,
      );
    } else {
      _cartItems.add(product);
    }

    notifyListeners();
  }

  // Remove one product
  void removeItem(Product product) {
    _cartItems.removeWhere(
      (item) => item.id == product.id,
    );

    notifyListeners();
  }

  // Clear the whole cart
  void clearAll() {
    _cartItems.clear();

    notifyListeners();
  }
}

// ==========================================
// 3. SCREEN 1 - PRODUCT CATALOG
// ==========================================

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  static const List<Product> products = [
    Product(
      id: 1,
      name: 'iPhone 16 Pro',
      price: 1299,
      icon: Icons.phone_iphone,
    ),
    Product(
      id: 2,
      name: 'MacBook Air M3',
      price: 1199,
      icon: Icons.laptop_mac,
    ),
    Product(
      id: 3,
      name: 'AirPods Pro 2',
      price: 249,
      icon: Icons.headphones,
    ),
    Product(
      id: 4,
      name: 'Apple Watch Ultra',
      price: 799,
      icon: Icons.watch,
    ),
    Product(
      id: 5,
      name: 'iPad Air',
      price: 699,
      icon: Icons.tablet_mac,
    ),
    Product(
      id: 6,
      name: 'Magic Keyboard',
      price: 159,
      icon: Icons.keyboard,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            tooltip: 'Open Cart',

            icon: Badge(
              label: Text('${cart.count}'),
              isLabelVisible: cart.count > 0,
              child: const Icon(
                Icons.shopping_cart,
                size: 28,
              ),
            ),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,

        itemBuilder: (context, index) {
          final product = products[index];

          final inCart = cart.isInCart(product);

          return Card(
            margin: const EdgeInsets.only(bottom: 10),

            child: ListTile(
              leading: Icon(
                product.icon,
                size: 30,
                color: inCart
                    ? Colors.green
                    : Colors.blueAccent,
              ),

              title: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                '\$${product.price.toStringAsFixed(2)}',
              ),

              trailing: SizedBox(
                width: 112,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                  ),

                  onPressed: () {
                    context
                        .read<CartProvider>()
                        .toggleItem(product);
                  },

                  child: Text(
                    inCart ? 'Remove' : 'Add to Cart',
                    style: TextStyle(
                      fontSize: 12,
                      color: inCart
                          ? Colors.red
                          : Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. SCREEN 2 - SHOPPING CART
// ==========================================

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // List of selected products
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty!',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,

                    itemBuilder: (context, index) {
                      final product = cart.items[index];

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            product.icon,
                            color: Colors.green,
                          ),

                          title: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          subtitle: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                          ),

                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),

                            onPressed: () {
                              context
                                  .read<CartProvider>()
                                  .removeItem(product);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Total price and Clear All button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  const Divider(),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Total Price:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '\$${cart.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: cart.items.isEmpty
                          ? null
                          : () {
                              context
                                  .read<CartProvider>()
                                  .clearAll();
                            },

                      icon: const Icon(
                        Icons.delete_sweep,
                      ),

                      label: const Text(
                        'Clear All',
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
