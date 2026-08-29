import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mapa para llevar la cantidad de cada producto (por id)
  late Map<String, int> _quantities;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _quantities = {};
    for (var product in widget.cartItems) {
      _quantities[product.id] = (_quantities[product.id] ?? 0) + 1;
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    double sum = 0.0;
    _quantities.forEach((id, qty) {
      final product = widget.cartItems.firstWhere((p) => p.id == id);
      sum += product.price * qty;
    });
    setState(() {
      _total = sum;
    });
  }

  void _increment(String productId) {
    setState(() {
      _quantities[productId] = (_quantities[productId] ?? 0) + 1;
      _calculateTotal();
    });
  }

  void _decrement(String productId) {
    setState(() {
      if (_quantities[productId] != null && _quantities[productId]! > 1) {
        _quantities[productId] = _quantities[productId]! - 1;
      } else {
        _quantities.remove(productId);
      }
      _calculateTotal();
    });
  }

  // Obtener lista de productos con repetición según cantidades
  List<Product> _getExpandedProductList() {
    List<Product> expanded = [];
    _quantities.forEach((id, qty) {
      final product = widget.cartItems.firstWhere((p) => p.id == id);
      for (int i = 0; i < qty; i++) {
        expanded.add(product);
      }
    });
    return expanded;
  }

  void _confirmPurchase() {
    if (_quantities.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El carrito está vacío')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: Text('Total a pagar: \$${_total.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Crear la orden en memoria
              final userId = DataService.users.first.id; // usuario actual
              final products = _getExpandedProductList();
              OrderService.createOrder(userId, products, _total);

              // Limpiar carrito
              setState(() {
                _quantities.clear();
                _calculateTotal();
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Compra realizada con éxito!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uniqueProducts = _quantities.keys.map((id) {
      return widget.cartItems.firstWhere((p) => p.id == id);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _quantities.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('Tu carrito está vacío', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: uniqueProducts.length,
                    itemBuilder: (context, index) {
                      final product = uniqueProducts[index];
                      final qty = _quantities[product.id]!;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            'Precio: \$${product.price.toStringAsFixed(2)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _decrement(product.id),
                              ),
                              Text(
                                qty.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _increment(product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16)),
                          Text(
                            '\$${_total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _confirmPurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text('Comprar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
