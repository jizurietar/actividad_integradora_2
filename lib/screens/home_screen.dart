import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/data_service.dart';
import '../services/order_service.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _currentUser;

  // Carrito local (lista de productos seleccionados)
  final List<Product> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    // Tomamos el primer usuario de la lista (en una app real usaríamos el email guardado)
    // Como simplificación, usamos el primero (Ana)
    _currentUser = DataService.users.first;
  }

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al carrito'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goToCart() {
    Navigator.pushNamed(context, AppRoutes.cart, arguments: _cart);
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Limpiar sesión guardada en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');

      // Navegar a la pantalla de login y eliminar el historial
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.orders);
            },
            tooltip: 'Mis órdenes',
          ),
          GestureDetector(
            onTap: _logout, // Al tocar el avatar, ejecuta el logout
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(_currentUser.avatarUrl),
            ),
          ),
          const SizedBox(width: 8),
          /*CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(_currentUser.avatarUrl),
          ),
          const SizedBox(width: 8),*/
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: DataService.products.length,
        itemBuilder: (context, index) {
          final product = DataService.products[index];
          return ProductCard(
            product: product,
            onAddToCart: () => _addToCart(product),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCart,
        backgroundColor: AppColors.secondary,
        child: Badge(
          label: Text(_cart.length.toString()),
          child: const Icon(Icons.shopping_cart, color: AppColors.primary),
        ),
      ),
    );
  }
}
