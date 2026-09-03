import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];
  final Map<String, int> _quantities = {};

  List<Product> get items => List.unmodifiable(_items);
  Map<String, int> get quantities => Map.unmodifiable(_quantities);

  double get total {
    double sum = 0;
    _quantities.forEach((id, qty) {
      final product = _items.firstWhere((p) => p.id == id);
      sum += product.price * qty;
    });
    return sum;
  }

  int get itemCount => _quantities.values.fold(0, (sum, qty) => sum + qty);

  void addToCart(Product product) {
    debugPrint('Adding product to cart: ${product.name}');
    if (_items.any((p) => p.id == product.id)) {
      _quantities[product.id] = (_quantities[product.id] ?? 0) + 1;
    } else {
      _items.add(product);
      _quantities[product.id] = 1;
    }
    notifyListeners();
  }

  void increment(String productId) {
    debugPrint('Incrementing product in cart: $productId');
    _quantities[productId] = (_quantities[productId] ?? 0) + 1;
    notifyListeners();
  }

  void decrement(String productId) {
    debugPrint('Decrementing product in cart: $productId');
    if (_quantities[productId] != null && _quantities[productId]! > 1) {
      _quantities[productId] = _quantities[productId]! - 1;
    } else {
      _quantities.remove(productId);
      _items.removeWhere((p) => p.id == productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _quantities.clear();
    notifyListeners();
  }

  List<Product> getExpandedProductList() {
    List<Product> expanded = [];
    _quantities.forEach((id, qty) {
      final product = _items.firstWhere((p) => p.id == id);
      for (int i = 0; i < qty; i++) {
        expanded.add(product);
      }
    });
    return expanded;
  }
}
